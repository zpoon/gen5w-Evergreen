package com.google.android.projection.protocol;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.os.Binder;
import android.os.IBinder;
import android.os.Parcel;
import android.os.SystemClock;
import android.util.Log;

import com.hkmc.cluster.NavigationCluster;
import com.hkmc.cluster.NavigationClusterListener;

/**
 * Read-only car access shared by EvModelSender (AA sessions) and EvDriveLog
 * (always on), so the two never read the same signal twice in a row.
 *
 * Every call is a getter (docs/DATA-SOURCES.md); nothing here writes to the
 * car. Every method catches everything and returns "unknown" (-1 / NaN /
 * null): this runs inside GPM, where an uncaught exception kills Android
 * Auto. Any thread.
 *
 * Binder transaction numbers come from the car's own interface classes, by
 * method name (tx(): IHEVService$Stub.TRANSACTION_getHEVStatus and so on), so
 * a firmware whose framework numbers its methods differently can't send a
 * read to another method. A name that isn't found makes that read "unknown".
 * The telematics interface (hscan) is in com.hkmc.ext.hcan, which GPM may not
 * load: then the numbers verified on the Ioniq 5 US 260507 (0x0b, 0xd6) are
 * used only if that library is byte for byte the 260507 one (HCAN_MD5).
 * No VIN is read (Evergreen collects no per-car identity).
 *
 * Sources (numbers as on the Ioniq 5 US 260507):
 *  - HEV getHEVStatus(flag) (com.hkmc.micom.hev txn 3), cached per flag so a
 *    second caller within maxAgeMs gets the same value without a binder call
 *  - hscan (tm_hscan_service): getCarSpeed 0x0b, getXEV_Bms_GDS_SOH 0xd6
 *  - the nav battery packet via NavigationCluster.requestBatteryInfoReq()
 *    (pack min temp, outside temp, EV_AVLBL_ENRG, DTE), requested at most
 *    every NAV_POLL_MS whoever asks; the listener stays registered for the
 *    life of the process
 *  - DATC IDATCService.getVRClimateStatus(flag) (txn 0x29), a pure getter
 *    over the service's caches, and isUnitCelsius(unit) (txn 6)
 *  - BCM drive mode: a passive IBCMListener (registerBCMListener txn 1). The
 *    service pushes the cached mode on registration and every change. We
 *    never call getDriveMode() (txn 0xc): that sends a MICOM request and the
 *    reply can show the drive-mode pop-up.
 *  - GPS altitude: LocationManager.getLastKnownLocation("gps"); only the
 *    altitude leaves this class, never position or time.
 */
final class EvCar {
    private static final String TAG = "EvCar";

    static final int HEV_INVALID16 = 0xffff;

    private static final String HEV_SERVICE = "com.hkmc.micom.hev";
    private static final String HEV_TOKEN = "com.hkmc.hev.IHEVService";
    private static final String HEV_GET_HEV_STATUS = "getHEVStatus";

    private static final String HCAN_SERVICE = "tm_hscan_service";
    private static final String HCAN_TOKEN =
            "com.hkmc.telematics.hscan.tm_interface.ITM_HSCANService";
    private static final String HCAN_GET_CAR_SPEED = "getCarSpeed";        // (B)F, 0x0b on 260507
    private static final String HCAN_GET_SOH = "getXEV_Bms_GDS_SOH";       // ()I, 0xd6 on 260507
    // com.hkmc.ext.hcan.odex of the Ioniq 5 US 260507, where 0x0b and 0xd6 were verified
    static final String HCAN_ODEX = "/system/framework/com.hkmc.ext.hcan.odex";
    static final String HCAN_MD5 = "c4638b2befbabce418d2664f4e7ec304";

    private static final String DATC_SERVICE = "com.hkmc.micom.datc";
    private static final String DATC_TOKEN = "com.hkmc.datc.IDATCService";
    private static final String DATC_IS_UNIT_CELSIUS = "isUnitCelsius";            // 0x06 on 260507
    private static final String DATC_GET_VR_CLIMATE_STATUS = "getVRClimateStatus"; // 0x29 on 260507
    // DATCFlag values getVRClimateStatus answers (DATCService.smali)
    static final int DATC_TEMP = 0x2;         // driver set temp, display unit
    static final int DATC_BLOWER_LEVEL = 0x5; // MainBlowerDisp
    static final int DATC_BLOWER_MODE = 0x6;  // ModeDisp (vent/floor/def...)
    static final int DATC_AUTO = 0x8;         // AutoDisp
    static final int DATC_AC = 0x9;           // AcDisp
    static final int DATC_OP_STATE = 0xc;     // OpSts
    static final int DATC_TEMP_UNIT = 0xd;    // TempUnit raw

    private static final String BCM_SERVICE = "com.hkmc.micom.bcm";
    private static final String BCM_TOKEN = "com.hkmc.bcm.IBCMService";
    private static final String BCM_LISTENER = "com.hkmc.bcm.IBCMListener";
    private static final String BCM_REGISTER_LISTENER = "registerBCMListener";      // 1 on 260507
    private static final String BCM_ON_DRIVE_MODE_CHANGED = "onDriveModeChanged";  // 0x11 on 260507

    // Navigation.BATTERY_INFO_RX packet indices (see
    // com.hkmc.micom.protocol.Navigation$BATTERY_INFO_RX).
    private static final int IDX_MIN_BATT_TEMP = 1;   // XEV_MIN_BATT_TEMP, C
    private static final int IDX_EV_AVLBL_ENRG = 2;   // EV_AVLBL_ENRG, 2 Wh steps
    private static final int IDX_OUT_TEMP = 4;        // DATC_OUT_TEMP_SNSR raw
    private static final int IDX_DTE_BASE = 6;        // VCU_DTE_BASE, km
    private static final int IDX_DTE_ADD = 7;         // VCU_DTE_ADD, km
    private static final long NAV_FRESH_MS = 30000;
    private static final long NAV_POLL_MS = 4000;
    private static final long GPS_FRESH_NS = 10000L * 1000000L;

    private static volatile IBinder sHev;
    private static volatile IBinder sHcan;
    private static volatile IBinder sDatc;

    private static final Object CACHE_LOCK = new Object();
    private static final int[] sHevVal = new int[256];
    private static final long[] sHevAt = new long[256];  // 0 = never read

    private static volatile int sSohRaw = Integer.MIN_VALUE;  // until > 0

    private EvCar() {}

    static long now() {
        return SystemClock.elapsedRealtime();
    }

    // ---- HEV -------------------------------------------------------------------

    /**
     * getHEVStatus(flag), reusing a value read less than maxAgeMs ago (by any
     * caller). -1 on failure (failures are not cached).
     */
    static int hev(int flag, long maxAgeMs) {
        if (flag >= 0 && flag < sHevVal.length && maxAgeMs > 0) {
            synchronized (CACHE_LOCK) {
                long at = sHevAt[flag];
                if (at != 0 && now() - at < maxAgeMs) {
                    return sHevVal[flag];
                }
            }
        }
        int v = hevRead(flag);
        if (v >= 0 && flag >= 0 && flag < sHevVal.length) {
            synchronized (CACHE_LOCK) {
                sHevVal[flag] = v;
                sHevAt[flag] = now();
            }
        }
        return v;
    }

    /** IHEVService.getHEVStatus(flag) via binder transaction 3, -1 on failure. */
    private static int hevRead(int flag) {
        try {
            IBinder b = sHev;
            if (b == null) {
                b = service(HEV_SERVICE);
                if (b == null) {
                    return -1;
                }
                sHev = b;
            }
            int tx = tx(HEV_TOKEN, HEV_GET_HEV_STATUS);
            if (tx < 0) {
                return -1;
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(HEV_TOKEN);
                data.writeInt(flag);
                if (!b.transact(tx, data, reply, 0)) {
                    return -1;
                }
                reply.readException();
                return reply.readInt();
            } finally {
                data.recycle();
                reply.recycle();
            }
        } catch (Throwable t) {
            sHev = null;
            return -1;
        }
    }

    // ---- hscan -----------------------------------------------------------------

    /** Display speed in km/h (hscan getCarSpeed unit 0), NaN if unknown. */
    static float speedKph() {
        float v = hscanFloat(hscanTx(HCAN_GET_CAR_SPEED, 0x0b), 0);
        return Float.isNaN(v) || v < 0 || v > 400 ? Float.NaN : v;
    }

    /** BMS SOH raw; re-read until it reports a value (it reads 0 at boot). */
    static int sohRaw() {
        int s = sSohRaw;
        if (s <= 0) {
            int v = hscanInt(hscanTx(HCAN_GET_SOH, 0xd6));
            if (v != s) {
                Log.i(TAG, "BMS SOH raw: " + v);
            }
            sSohRaw = v;
            s = v;
        }
        return s;
    }

    private static IBinder hscan() throws Exception {
        IBinder b = sHcan;
        if (b == null) {
            b = service(HCAN_SERVICE);
            sHcan = b;
        }
        return b;
    }

    /** hscan float getter with one byte argument, NaN on failure. */
    private static float hscanFloat(int txn, int arg) {
        if (txn < 0) {
            return Float.NaN;
        }
        try {
            IBinder b = hscan();
            if (b == null) {
                return Float.NaN;
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(HCAN_TOKEN);
                data.writeByte((byte) arg);
                if (!b.transact(txn, data, reply, 0)) {
                    return Float.NaN;
                }
                reply.readException();
                return reply.readFloat();
            } finally {
                data.recycle();
                reply.recycle();
            }
        } catch (Throwable t) {
            sHcan = null;
            return Float.NaN;
        }
    }

    /** hscan int getter without arguments, -1 on failure. */
    private static int hscanInt(int txn) {
        if (txn < 0) {
            return -1;
        }
        try {
            IBinder b = hscan();
            if (b == null) {
                return -1;
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(HCAN_TOKEN);
                if (!b.transact(txn, data, reply, 0)) {
                    return -1;
                }
                reply.readException();
                return reply.readInt();
            } finally {
                data.recycle();
                reply.recycle();
            }
        } catch (Throwable t) {
            sHcan = null;
            return -1;
        }
    }

    // ---- nav battery packet ----------------------------------------------------

    private static final Object NAV_LOCK = new Object();
    private static NavigationCluster sNavCluster;
    private static long sNavPolledAt;
    private static volatile long sNavPacketAt;
    private static volatile int sPackTempC = Integer.MIN_VALUE;
    private static volatile int sOutTempRaw = Integer.MIN_VALUE;
    private static volatile int sAvlblEnrg = -1;
    private static volatile int sDteBase = -1;
    private static volatile int sDteAdd = -1;

    private static final NavigationClusterListener sNavListener =
            new NavigationClusterListener() {
                @Override
                public void onHandleBatteryInfoResp(int[] d) {
                    try {
                        if (d == null || d.length <= IDX_DTE_ADD) {
                            return;
                        }
                        sPackTempC = (byte) d[IDX_MIN_BATT_TEMP];
                        sOutTempRaw = d[IDX_OUT_TEMP] & 0xff;
                        sAvlblEnrg = d[IDX_EV_AVLBL_ENRG];
                        sDteBase = d[IDX_DTE_BASE];
                        sDteAdd = d[IDX_DTE_ADD];
                        sNavPacketAt = now();
                    } catch (Throwable t) {
                        // never disturb GPM
                    }
                }
            };

    /** Ask for a fresh nav battery packet unless one was asked for recently. */
    static void pollNav() {
        try {
            synchronized (NAV_LOCK) {
                long n = now();
                if (sNavPolledAt != 0 && n - sNavPolledAt < NAV_POLL_MS) {
                    return;
                }
                sNavPolledAt = n;
                if (sNavCluster == null) {
                    Context ctx = appContext();
                    if (ctx == null) {
                        return;
                    }
                    NavigationCluster nc = new NavigationCluster(ctx);
                    nc.addListener(sNavListener);
                    sNavCluster = nc;
                    Log.i(TAG, "nav cluster listener registered");
                }
                try {
                    sNavCluster.requestBatteryInfoReq();
                } catch (Throwable t) {
                    // keep the listener; retry next poll
                    Log.w(TAG, "nav battery request failed: " + t);
                }
            }
        } catch (Throwable t) {
            Log.w(TAG, "nav cluster unavailable: " + t);
        }
    }

    static boolean navFresh() {
        long at = sNavPacketAt;
        return at != 0 && now() - at < NAV_FRESH_MS;
    }

    /** XEV_MIN_BATT_TEMP from a fresh packet, Integer.MIN_VALUE if unknown. */
    static int packMinC() {
        return navFresh() ? sPackTempC : Integer.MIN_VALUE;
    }

    /** DATC_OUT_TEMP_SNSR raw from a fresh packet, -1 if unknown. */
    static int outTempRaw() {
        int raw = sOutTempRaw;
        return navFresh() && raw >= 0 ? raw : -1;
    }

    /** Outside temp in C (raw x 0.5 - 40), NaN if unknown/invalid. */
    static float outsideTempC() {
        int raw = outTempRaw();
        if (raw < 0 || raw >= 0xfe) {
            return Float.NaN;
        }
        return raw * 0.5f - 40f;
    }

    /** EV_AVLBL_ENRG from a fresh packet, -1 if unknown. */
    static int navAvlblEnrg() {
        return navFresh() ? sAvlblEnrg : -1;
    }

    /** VCU_DTE_BASE + VCU_DTE_ADD (km) from a fresh packet, -1 if unknown. */
    static int dteRaw() {
        int b = sDteBase;
        return navFresh() && b >= 0 ? b + sDteAdd : -1;
    }

    static String navSummary() {
        return "pack=" + (navFresh() ? String.valueOf(sPackTempC) : "?")
                + "C, out raw " + sOutTempRaw + ", dte=" + sDteBase + "+" + sDteAdd + "km";
    }

    // ---- energy ----------------------------------------------------------------

    /**
     * BMS remaining usable energy raw (HEV 0x31 ENERGYMAP_1000MS, 2 Wh steps;
     * falls back to a fresh nav packet's EV_AVLBL_ENRG, the same signal).
     * -1 if neither is valid.
     */
    static int energyRaw(long maxAgeMs, int maxRaw) {
        int raw = hev(0x31, maxAgeMs);
        if (raw <= 0 || raw >= HEV_INVALID16) {
            raw = navAvlblEnrg();
        }
        if (raw <= 0 || raw >= HEV_INVALID16 || raw > maxRaw) {
            return -1;
        }
        return raw;
    }

    // ---- DATC (climate) --------------------------------------------------------

    private static IBinder datc() throws Exception {
        IBinder b = sDatc;
        if (b == null) {
            b = service(DATC_SERVICE);
            sDatc = b;
        }
        return b;
    }

    /** IDATCService.getVRClimateStatus(flag); NaN on failure or invalid (< 0). */
    /**
     * Climate getter results are cached for CLIMATE_CACHE_MS: each call makes
     * the DATC service write a debug line to logcat, and at ~7 calls per row
     * that would flush the head unit's ~1 min log buffer. Settings change
     * rarely, so 30 s resolution is plenty.
     */
    private static final long CLIMATE_CACHE_MS = 30000;
    private static final java.util.HashMap<Integer, Float> sClimate =
            new java.util.HashMap<Integer, Float>();
    private static final java.util.HashMap<Integer, Long> sClimateAt =
            new java.util.HashMap<Integer, Long>();

    static synchronized float climate(int flag) {
        long now = android.os.SystemClock.uptimeMillis();
        Integer k = Integer.valueOf(flag);
        Long at = sClimateAt.get(k);
        if (at != null && now - at.longValue() < CLIMATE_CACHE_MS) {
            return sClimate.get(k).floatValue();
        }
        float v = climateUncached(flag);
        sClimate.put(k, Float.valueOf(v));
        sClimateAt.put(k, Long.valueOf(now));
        return v;
    }

    private static float climateUncached(int flag) {
        try {
            int tx = tx(DATC_TOKEN, DATC_GET_VR_CLIMATE_STATUS);
            IBinder b = tx < 0 ? null : datc();
            if (b == null) {
                return Float.NaN;
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(DATC_TOKEN);
                data.writeInt(flag);
                if (!b.transact(tx, data, reply, 0)) {
                    return Float.NaN;
                }
                reply.readException();
                float v = reply.readFloat();
                return v < 0 || Float.isNaN(v) || Float.isInfinite(v) ? Float.NaN : v;
            } finally {
                data.recycle();
                reply.recycle();
            }
        } catch (Throwable t) {
            sDatc = null;
            return Float.NaN;
        }
    }

    /** IDATCService.isUnitCelsius(unit): 1 yes, 0 no, -1 unknown. */
    static int climateUnitIsCelsius(int unitRaw) {
        try {
            int tx = tx(DATC_TOKEN, DATC_IS_UNIT_CELSIUS);
            IBinder b = tx < 0 ? null : datc();
            if (b == null) {
                return -1;
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(DATC_TOKEN);
                data.writeInt(unitRaw);
                if (!b.transact(tx, data, reply, 0)) {
                    return -1;
                }
                reply.readException();
                return reply.readInt() != 0 ? 1 : 0;
            } finally {
                data.recycle();
                reply.recycle();
            }
        } catch (Throwable t) {
            sDatc = null;
            return -1;
        }
    }

    // ---- BCM drive mode (passive listener) --------------------------------------

    private static volatile int sDriveMode = -1;
    private static volatile int sBcmLtxDriveMode = -1;
    private static volatile IBinder sBcmRegisteredWith;
    private static Binder sBcmListener;
    private static long sBcmTriedAt;

    /**
     * Last drive mode the BCM service pushed (BCMConstants.DriveMode: 0
     * default, 1 normal, 2 sport, 3 eco, 4 snow), -1 unknown. Registers the
     * listener on first use and again if the BCM service restarted (tried at
     * most once a minute).
     */
    static int driveMode() {
        try {
            IBinder reg = sBcmRegisteredWith;
            if (reg == null || !reg.isBinderAlive()) {
                long n = now();
                if (sBcmTriedAt == 0 || n - sBcmTriedAt >= 60000) {
                    sBcmTriedAt = n;
                    registerBcm();
                }
            }
        } catch (Throwable t) {
            // unknown
        }
        return sDriveMode;
    }

    private static void registerBcm() {
        try {
            sDriveMode = -1;
            int tx = tx(BCM_TOKEN, BCM_REGISTER_LISTENER);
            sBcmLtxDriveMode = tx(BCM_LISTENER, BCM_ON_DRIVE_MODE_CHANGED);
            if (tx < 0 || sBcmLtxDriveMode < 0) {
                return;
            }
            IBinder bcm = service(BCM_SERVICE);
            if (bcm == null || !BCM_TOKEN.equals(bcm.getInterfaceDescriptor())) {
                return;
            }
            if (sBcmListener == null) {
                sBcmListener = new BcmListener();
            }
            Parcel data = Parcel.obtain();
            Parcel reply = Parcel.obtain();
            try {
                data.writeInterfaceToken(BCM_TOKEN);
                data.writeStrongBinder(sBcmListener);
                data.writeStrongBinder(new Binder());
                if (!bcm.transact(tx, data, reply, 0)) {
                    return;
                }
                reply.readException();
            } finally {
                data.recycle();
                reply.recycle();
            }
            sBcmRegisteredWith = bcm;
            Log.i(TAG, "BCM listener registered (drive mode " + sDriveMode + ")");
        } catch (Throwable t) {
            Log.w(TAG, "BCM listener not registered: " + t);
        }
    }

    /**
     * IBCMListener on the wire: only onDriveModeChanged(int) is read; every
     * other callback (all void) is acknowledged and ignored. Runs on binder
     * threads and only stores an int.
     */
    private static final class BcmListener extends Binder {
        @Override
        protected boolean onTransact(int code, Parcel data, Parcel reply, int flags) {
            try {
                if (code >= FIRST_CALL_TRANSACTION && code <= LAST_CALL_TRANSACTION) {
                    if (code == sBcmLtxDriveMode) {
                        data.enforceInterface(BCM_LISTENER);
                        int m = data.readInt();
                        sDriveMode = m >= 0 && m <= 0xff ? m : -1;
                    }
                    if (reply != null) {
                        reply.writeNoException();
                    }
                    return true;
                }
                return super.onTransact(code, data, reply, flags);
            } catch (Throwable t) {
                return false;
            }
        }
    }

    // ---- GPS altitude ----------------------------------------------------------

    /**
     * Altitude (m) of the last GPS fix if it is under 10 s old and has one,
     * NaN otherwise. Only the altitude is used; the position and time of the
     * fix never leave this method.
     */
    static double gpsAltitudeM() {
        try {
            Context ctx = appContext();
            if (ctx == null) {
                return Double.NaN;
            }
            LocationManager lm = (LocationManager) ctx.getSystemService(
                    Context.LOCATION_SERVICE);
            if (lm == null) {
                return Double.NaN;
            }
            Location l = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER);
            if (l == null || !l.hasAltitude()) {
                return Double.NaN;
            }
            long age = SystemClock.elapsedRealtimeNanos() - l.getElapsedRealtimeNanos();
            if (age < 0 || age > GPS_FRESH_NS) {
                return Double.NaN;
            }
            return l.getAltitude();
        } catch (Throwable t) {
            return Double.NaN;
        }
    }

    // ---- transaction numbers, by method name ------------------------------------

    private static final java.util.HashMap<String, Integer> sTx =
            new java.util.HashMap<String, Integer>();

    /**
     * The binder transaction number of iface.method, from the car's own
     * interface class (iface$Stub.TRANSACTION_method); -1 if it isn't there.
     * Looked up once per name.
     */
    static int tx(String iface, String method) {
        String k = iface + "." + method;
        synchronized (sTx) {
            Integer v = sTx.get(k);
            if (v != null) {
                return v.intValue();
            }
        }
        int n = stubTx(iface, method);
        synchronized (sTx) {
            sTx.put(k, Integer.valueOf(n));
        }
        Log.i(TAG, "transaction " + k + " = " + (n < 0 ? "not found (reads unknown)" : String.valueOf(n)));
        return n;
    }

    static int stubTx(String iface, String method) {
        try {
            Class<?> c = Class.forName(iface + "$Stub", false, EvCar.class.getClassLoader());
            java.lang.reflect.Field f = c.getDeclaredField("TRANSACTION_" + method);
            f.setAccessible(true);
            int n = f.getInt(null);
            return n >= 1 && n <= 0x00ffffff ? n : -1;
        } catch (Throwable t) {
            return -1;
        }
    }

    private static volatile Boolean sHcanKnown;  // null = not checked yet

    /**
     * hscan's number for method: by name, or, when GPM can't see the telematics
     * interface class, the number verified on the Ioniq 5 US 260507, only if
     * com.hkmc.ext.hcan.odex is that firmware's file; -1 otherwise.
     */
    static int hscanTx(String method, int verified260507) {
        int n = tx(HCAN_TOKEN, method);
        if (n >= 0) {
            return n;
        }
        Boolean known = sHcanKnown;
        if (known == null) {
            boolean ok = HCAN_MD5.equals(md5(HCAN_ODEX));
            known = Boolean.valueOf(ok);
            sHcanKnown = known;
            Log.i(TAG, "telematics library " + (ok ? "is" : "isn't") + " the Ioniq 5 US 260507 one");
        }
        return known.booleanValue() ? verified260507 : -1;
    }

    /** md5 of a file, lower-case hex; "" if it can't be read. */
    static String md5(String path) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
            java.io.FileInputStream in = new java.io.FileInputStream(path);
            try {
                byte[] buf = new byte[16384];
                int n;
                while ((n = in.read(buf)) != -1) {
                    md.update(buf, 0, n);
                }
            } finally {
                in.close();
            }
            StringBuilder sb = new StringBuilder();
            for (byte x : md.digest()) {
                sb.append(Character.forDigit((x >> 4) & 0xf, 16)).append(Character.forDigit(x & 0xf, 16));
            }
            return sb.toString();
        } catch (Throwable t) {
            return "";
        }
    }

    // ---- helpers ---------------------------------------------------------------

    private static IBinder service(String name) throws Exception {
        return (IBinder) Class.forName("android.os.ServiceManager")
                .getMethod("getService", String.class)
                .invoke(null, name);
    }

    static Context appContext() {
        try {
            return (Context) Class.forName("android.app.ActivityThread")
                    .getMethod("currentApplication")
                    .invoke(null);
        } catch (Throwable t) {
            return null;
        }
    }
}
