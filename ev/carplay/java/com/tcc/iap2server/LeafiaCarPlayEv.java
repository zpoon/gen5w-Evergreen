package com.tcc.iap2server;
// SPDX-License-Identifier: GPL-3.0-or-later
// Evergreen: CarPlay EV routing for Apple Maps, built into Iap2ServerApp. Adapted from
// isaacwisdom/egmp-carplay-ev-routing (EvRouting, AppProvider; GPL-3.0-or-later) and the
// identification installer of Open-HMG/hmgapi-wireless-cp-aa, without HMG-API: Iap2Service
// calls onCreate/onDestroy, Iap2InitInformationMsg.checkSupportsFeatures calls identity().

import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import com.tcc.iap2.IIap2Listener;
import com.tcc.iap2.IIap2Service;
import com.tcc.iap2.Iap2ListenerInfo;
import com.tcc.iap2.Iap2NotiMsg;
import hmgapi.mods.wireless.NativeIdentity;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.security.MessageDigest;
import org.egmp.carplay.ev.app.NativeBridge;
import org.egmp.carplay.ev.app.Subscription;
import org.egmp.carplay.ev.app.VehicleSource;
import org.json.JSONArray;
import org.json.JSONObject;

public final class LeafiaCarPlayEv {
    static final String TAG = "Leafia";
    static final String LIB_EV = "/system/lib/libcarplayev.so";
    static final String LIB_ID = "/system/lib/libcarplayidentity.so";
    static final String SESSION = "/system/lib/libiap2session.so";
    // libiap2session.so with the identification gate (recipes/carplay-ev-identification.recipe on
    // stock fc7cb675...): installed by part 2 only with the EV build
    static final String SESSION_EV_MD5 = "b32703e6d702009da1cca02f4088ad58";
    // automotive.odex / automotive-service.odex SHA-256 the EV code's reads were checked
    // against (the same list as GPM's Precond.HkmcVehicle; notes/ev-vehicle-commands.md)
    static final String[][] FRAMEWORKS = {
        {"dd72e04bce0a2b4bda1506308ac21f91002c1436553b8156c345cc4313661338","3cf40fb00854c63afa49abea1dad18a0afcbc0dd68b17de9ed7ea3f5aeab4222"}, // Hyundai Ioniq 5 US 260507
        {"c52e0825956880d627b32979022705a618200f059476c094d729133d1ff6a3be","bf17e682d1beb349ae8ef2acaae6d6e908fe42e88853d7145ee16b29bb4d9ec1"}, // Hyundai Ioniq 5 US 260903
        {"b9e7e02b81e1a8cfcf767c6b8bbb28bcf1d2c411a208fbf6a465e7f0c662774a","8af745b41aa28f490953d61531215cd94e059f104b31f6236a8f6c7af23b8062"}, // Kia EV6 US 260507
        {"347d05034e6b25e38f8d0446a6e9f02f4c8f5b786c09e583a500235613514c18","80bc04d04822464cfedb8878592f04eab8b16351be7aef6c70ff1ec9aa14d021"}, // Kia EV6 Canada 260206
    };

    private static boolean checked, ok, identityArmed;
    private static String profile, profileName;
    private static Provider provider;

    private LeafiaCarPlayEv() {}

    /** files, library build, framework and a profile for this car; checked once per process */
    static synchronized boolean ready() {
        if (checked) return ok;
        checked = true;
        try {
            String why = check();
            if (why != null) { Log.i(TAG, "CarPlay EV: off (" + why + ")"); return false; }
            ok = true;
            Log.i(TAG, "CarPlay EV: on, profile " + profileName);
        } catch (Throwable t) {
            Log.w(TAG, "CarPlay EV: off (check failed: " + t + ")");
        }
        return ok;
    }

    private static String check() throws Exception {
        if (!new File(LIB_EV).isFile() || !new File(LIB_ID).isFile()) return "EV build not installed";
        if (!SESSION_EV_MD5.equals(digest("MD5", SESSION))) return "libiap2session.so is not the EV build";
        String fw = digest("SHA-256", "/system/framework/automotive.odex");
        String svc = digest("SHA-256", "/system/framework/automotive-service.odex");
        boolean known = false;
        for (String[] p : FRAMEWORKS) if (p[0].equals(fw) && p[1].equals(svc)) known = true;
        if (!known) return "framework is not a checked one";
        String product = (String) Class.forName("android.os.SystemProperties")
                .getMethod("get", String.class).invoke(null, "ro.build.product");
        String[] p = LeafiaCarPlayEvProfiles.forProduct(product);
        if (p == null) return "no profile for " + product;
        profileName = p[0];
        profile = p[1];
        return null;
    }

    /** end of Iap2InitInformationMsg.checkSupportsFeatures(), before the identification is built */
    public static void identity() {
        try {
            if (!ready()) return;
            synchronized (LeafiaCarPlayEv.class) {
                if (!identityArmed) {
                    JSONObject p = new JSONObject(profile);
                    String name = p.getJSONObject("vehicle").getString("display_name");
                    int dc = 0, ac = 0;
                    JSONArray cs = p.getJSONArray("connectors");
                    for (int i = 0; i < cs.length(); i++) {
                        JSONObject c = cs.getJSONObject(i);
                        if ("ccs1".equals(c.getString("type"))) dc = c.getInt("maximum_power_w");
                        else if ("j1772".equals(c.getString("type"))) ac = c.getInt("maximum_power_w");
                    }
                    NativeIdentity.load();
                    // engine 2 = electric; DC connector 0 = CCS, AC connector 2 (identity.c)
                    int rc = NativeIdentity.configure(name.getBytes("UTF-8"), 2, 0, dc, 2, ac, new byte[0]);
                    if (rc != 0) { Log.w(TAG, "CarPlay EV: identification not armed (" + rc + ")"); return; }
                    identityArmed = true;
                    Log.i(TAG, "CarPlay EV: identification armed: " + name + ", DC " + dc + " W, AC " + ac + " W");
                }
            }
            Class<?> m = Class.forName("com.tcc.iap2server.Iap2InitInformationMsg");
            set(m, "iAP2UsedVehicelInformation", 1);
            set(m, "iAP2UsedVehicleStatus", 1);
        } catch (Throwable t) {
            Log.w(TAG, "CarPlay EV: identification failed: " + t);
        }
    }

    /** end of Iap2Service.onCreate() */
    public static void onCreate(Object service) {
        try {
            if (!ready()) return;
            synchronized (LeafiaCarPlayEv.class) {
                if (provider != null) return;
                Provider next = new Provider(service, profile);
                provider = next;
                try { next.start(); } catch (Throwable t) { provider = null; next.close(); throw t; }
            }
            Log.i(TAG, "CarPlay EV: listener registered");
        } catch (Throwable t) {
            Log.w(TAG, "CarPlay EV: start failed: " + t);
        }
    }

    /** start of Iap2Service.onDestroy() */
    public static void onDestroy() {
        try {
            synchronized (LeafiaCarPlayEv.class) {
                if (provider != null) { provider.close(); provider = null; }
            }
        } catch (Throwable t) {
            Log.w(TAG, "CarPlay EV: stop failed: " + t);
        }
    }

    static Object lock() throws Exception { return field("mLock").get(null); }
    static long handle() throws Exception { return field("mHandleIap2").getLong(null); }
    private static Field field(String name) throws Exception {
        Field f = Class.forName("com.tcc.iap2server.Iap2Service").getDeclaredField(name);
        f.setAccessible(true);
        return f;
    }
    private static void set(Class<?> c, String name, int v) throws Exception {
        Field f = c.getDeclaredField(name);
        f.setAccessible(true);
        f.setInt(null, v);
    }
    static String digest(String alg, String path) throws Exception {
        MessageDigest md = MessageDigest.getInstance(alg);
        InputStream in = new FileInputStream(path);
        try {
            byte[] b = new byte[65536];
            int n;
            while ((n = in.read(b)) > 0) md.update(b, 0, n);
        } finally { in.close(); }
        StringBuilder sb = new StringBuilder();
        for (byte x : md.digest()) sb.append(String.format("%02x", x & 0xff));
        return sb.toString();
    }

    /** AppProvider from egmp-carplay-ev-routing: a CarPlayEV listener on the iAP2 service and a
     * worker sending the EV status every ten seconds while the iPhone subscribes */
    static final class Provider {
        private final Object service;
        private final VehicleSource source;
        private final Subscription subscription = new Subscription();
        private IIap2Service binder;
        private Thread worker;
        private long workerToken;
        private boolean closed;
        private String lastFailure;
        private final IIap2Listener listener = new IIap2Listener.Stub() {
            public void connected(int component, String serial) { subscription.connected(component); }
            public void disconnected(int component) { if (subscription.disconnected(component)) release(); }
            public void notify(int what, int a, int b, Iap2NotiMsg msg) {
                if (what == 15) begin();
                else if (what == 16) { subscription.stop(); release(); }
            }
        };

        Provider(Object service, String profile) throws Exception {
            this.service = service;
            source = new VehicleSource(service, profile, 0);
        }

        void start() throws Throwable {
            NativeBridge.load(LIB_EV);
            int opened = NativeBridge.open();
            if (opened != 0) throw new IllegalStateException("native open=" + opened);
            Object raw = service.getClass().getMethod("onBind", Intent.class).invoke(service, new Intent());
            binder = IIap2Service.Stub.asInterface((IBinder) raw);
            Iap2ListenerInfo info = new Iap2ListenerInfo();
            info.onSetListenerName("CarPlayEV");
            info.onSetSupportType(0x100);
            if (!binder.Iap2SvcInit(listener, info)) throw new IllegalStateException("listener refused");
        }

        private synchronized void begin() {
            final long token = subscription.start();
            if (token == 0) return;
            if (worker != null && worker.isAlive() && workerToken == token) return;
            if (worker != null) worker.interrupt();
            workerToken = token;
            worker = new Thread(new Runnable() {
                public void run() {
                    try {
                        while (subscription.current(token)) {
                            try {
                                VehicleSource.Snapshot s = source.poll();
                                String selection = source.takeBatterySelectionEvent();
                                if (selection != null) Log.i(TAG, "CarPlay EV: " + selection);
                                synchronized (lock()) {
                                    if (!subscription.current(token)) return;
                                    int rc = NativeBridge.send(handle(), s.values, s.charging, s.consumption);
                                    Log.i(TAG, statusLine(rc, s));
                                }
                                lastFailure = null;
                            } catch (Throwable error) {
                                String m = message(error);
                                if (!m.equals(lastFailure)) {
                                    Log.w(TAG, "CarPlay EV: status unavailable, will retry: " + m);
                                    lastFailure = m;
                                }
                            }
                            Thread.sleep(10000);
                        }
                    } catch (InterruptedException ended) {
                        Thread.currentThread().interrupt();
                    }
                }
            }, "LeafiaCarPlayEv");
            worker.setDaemon(true);
            worker.start();
        }

        private static String message(Throwable error) {
            Throwable c = error;
            while (c.getCause() != null && c.getCause() != c) c = c.getCause();
            return c.getMessage() == null ? c.getClass().getSimpleName() : c.getMessage();
        }

        // SOC, range and energy only: no place names or identity
        private static String statusLine(int rc, VehicleSource.Snapshot s) {
            String live = s.values[7] == 1
                    ? "soc " + (s.values[3] / 1000) + "% range " + s.values[4] + " km energy " + s.values[2] + " Wh"
                    : "soc/range unavailable";
            String full = s.values[8] == 1 ? " full range " + s.values[6] + " km" : "";
            return "CarPlay EV: status sent (" + rc + "): " + live + full + ", auxiliary " + s.auxiliaryW + " W ("
                    + s.auxiliarySource + ")" + (s.values[5] == 1 ? ", low battery" : "");
        }

        private void release() {
            try { synchronized (lock()) { NativeBridge.reset(); } }
            catch (Throwable error) { Log.w(TAG, "CarPlay EV: release: " + error); }
        }

        synchronized void close() {
            if (closed) return;
            closed = true;
            subscription.close();
            if (worker != null) worker.interrupt();
            release();
            try { synchronized (lock()) { NativeBridge.shutdown(); } }
            catch (Throwable error) { Log.w(TAG, "CarPlay EV: native shutdown: " + error); }
            if (binder != null) {
                try { binder.Iap2SvcStopMain(listener); }
                catch (Throwable error) { Log.w(TAG, "CarPlay EV: listener unregister: " + error); }
            }
        }
    }
}
