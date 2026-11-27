.class public final Lorg/egmp/carplay/ev/app/NativeBridge;
.super Ljava/lang/Object;
.source "NativeBridge.java"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 7
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static load(Ljava/lang/String;)V
    .registers 1

    .line 8
    invoke-static {p0}, Ljava/lang/System;->load(Ljava/lang/String;)V

    return-void
.end method

.method public static native open()I
.end method

.method public static native reset()V
.end method

.method public static native send(J[I[B[B)I
.end method

.method public static native shutdown()V
.end method

.method public static native stop(J)I
.end method
