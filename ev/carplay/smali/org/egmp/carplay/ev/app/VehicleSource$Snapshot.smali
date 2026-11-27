.class public final Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;
.super Ljava/lang/Object;
.source "VehicleSource.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lorg/egmp/carplay/ev/app/VehicleSource;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Snapshot"
.end annotation


# instance fields
.field public final auxiliarySource:Ljava/lang/String;

.field public final auxiliaryW:D

.field public final batterySource:Ljava/lang/String;

.field public final charging:[B

.field public final consumption:[B

.field public final values:[I


# direct methods
.method constructor <init>([I[B[BLjava/lang/String;DLjava/lang/String;)V
    .registers 8

    .line 19
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    iput-object p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->charging:[B

    iput-object p3, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->consumption:[B

    iput-object p4, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->auxiliarySource:Ljava/lang/String;

    iput-wide p5, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->auxiliaryW:D

    iput-object p7, p0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->batterySource:Ljava/lang/String;

    return-void
.end method
