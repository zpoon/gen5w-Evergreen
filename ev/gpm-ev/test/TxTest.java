package com.google.android.projection.protocol;

/**
 * EvCar looks binder transaction numbers up by method name in the car's own
 * interface classes (test/fake stands in for IHEVService), and a name it can't
 * find makes that read unknown instead of guessing a number.
 */
public final class TxTest {
    public static void main(String[] a) {
        int pass = 0;
        check(EvCar.tx("com.hkmc.hev.IHEVService", "getHEVStatus") == 3, "found by name");
        pass++;
        check(EvCar.tx("com.hkmc.hev.IHEVService", "noSuchMethod") == -1, "missing method");
        pass++;
        check(EvCar.tx("com.hkmc.datc.IDATCService", "getVRClimateStatus") == -1, "missing interface");
        pass++;
        // hscan: no interface class and no 260507 library file here: unknown, not 0x0b
        check(EvCar.hscanTx("getCarSpeed", 0x0b) == -1, "hscan without class or verified library");
        pass++;
        check(EvCar.md5("/nonexistent").equals(""), "md5 of a missing file");
        pass++;
        // without the car's services every read is unknown, never a guess
        check(EvCar.hev(0x31, 1000) == -1 && Float.isNaN(EvCar.climate(EvCar.DATC_TEMP)), "reads unknown");
        pass++;
        System.out.println("TxTest: " + pass + " passed");
    }

    static void check(boolean ok, String what) {
        if (!ok) {
            throw new AssertionError(what);
        }
    }
}
