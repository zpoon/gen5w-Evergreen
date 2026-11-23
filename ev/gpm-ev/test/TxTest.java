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
        check(Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_SHA256,
                Precond.HkmcVehicle.SERVICE_SHA256), "260507 framework verified");
        pass++;
        check(Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_260903_SHA256,
                Precond.HkmcVehicle.SERVICE_260903_SHA256), "260903 framework verified");
        pass++;
        check(!Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_SHA256,
                Precond.HkmcVehicle.SERVICE_260903_SHA256), "mismatched framework rejected");
        pass++;
        check(!Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_260903_SHA256,
                Precond.HkmcVehicle.SERVICE_SHA256), "reverse mismatched framework rejected");
        pass++;
        check(Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_EV6_SHA256,
                Precond.HkmcVehicle.SERVICE_EV6_SHA256), "Kia EV6 US 260507 framework verified");
        pass++;
        check(!Precond.HkmcVehicle.isVerifiedFramework(
                Precond.HkmcVehicle.FRAMEWORK_EV6_SHA256,
                Precond.HkmcVehicle.SERVICE_SHA256), "EV6 framework with the Ioniq 5 service rejected");
        pass++;
        check(Precond.HkmcVehicle.FRAMEWORK_EV6_SHA256.equals("b9e7e02b81e1a8cfcf767c6b8bbb28bcf1d2c411a208fbf6a465e7f0c662774a")
                && Precond.HkmcVehicle.SERVICE_EV6_SHA256.equals("8af745b41aa28f490953d61531215cd94e059f104b31f6236a8f6c7af23b8062")
                && EvCar.HCAN_EV6_MD5.equals("b9ed02d077649b7c2a589d665f33e2e0"),
                "EV6 automotive / automotive-service SHA-256 and hcan md5");
        pass++;
        check(EvModelSender.roadCar("CVEV.USA.0000.V015.012.260507") == 0
                && EvModelSender.ROAD_CAR_A_N[0] == 180.0f && EvModelSender.ROAD_CAR_C[0] == 0.40f,
                "Kia EV6 gets its own road load");
        pass++;
        check(EvModelSender.roadCar("NEEV23.USA.0000.V015.012.260507") == -1
                && EvModelSender.roadCar("") == -1 && EvModelSender.roadCar(null) == -1,
                "other cars keep the model's road load");
        pass++;
        check(!Precond.HkmcVehicle.isVerifiedFramework(
                "0000000000000000000000000000000000000000000000000000000000000000",
                "0000000000000000000000000000000000000000000000000000000000000000"), "unknown framework rejected");
        pass++;
        // the 260903 values as the US 260903 framework files have them, so a slip in a constant
        // fails here rather than turning the EV code off on that firmware
        check(Precond.HkmcVehicle.FRAMEWORK_260903_SHA256.equals("c52e0825956880d627b32979022705a618200f059476c094d729133d1ff6a3be")
                && Precond.HkmcVehicle.SERVICE_260903_SHA256.equals("bf17e682d1beb349ae8ef2acaae6d6e908fe42e88853d7145ee16b29bb4d9ec1"),
                "260903 automotive / automotive-service SHA-256");
        pass++;
        check(EvCar.HCAN_260903_MD5.equals("1cab9265954bbf48a5dddb67a1e6f2bc"), "260903 com.hkmc.ext.hcan.odex md5");
        pass++;
        System.out.println("TxTest: " + pass + " passed");
    }

    static void check(boolean ok, String what) {
        if (!ok) {
            throw new AssertionError(what);
        }
    }
}
