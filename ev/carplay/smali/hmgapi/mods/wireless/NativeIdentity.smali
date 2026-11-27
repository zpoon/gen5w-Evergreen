.class public final Lhmgapi/mods/wireless/NativeIdentity;
.super Ljava/lang/Object;
.source "NativeIdentity.java"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 6
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static native configure([BIIIII[B)I
.end method

.method public static load()V
    .registers 1

    const-string v0, "/system/lib/libcarplayidentity.so"

    .line 7
    invoke-static {v0}, Ljava/lang/System;->load(Ljava/lang/String;)V

    return-void
.end method

.method public static native shutdown()V
.end method
