package hmgapi.mods.wireless;
// SPDX-License-Identifier: GPL-3.0-or-later
/** Evergreen: the JNI boundary of libcarplayidentity.so (native/identity/identity.c, from
 * Open-HMG/hmgapi-wireless-cp-aa), declared under the class name its native functions use. */
public final class NativeIdentity {
    private NativeIdentity() {}
    public static void load() { System.load("/system/lib/libcarplayidentity.so"); }
    public static native int configure(byte[] displayName, int engineType, int dcConnector,
            int dcPowerW, int acConnector, int acPowerW, byte[] themeIdentity);
    public static native void shutdown();
}
