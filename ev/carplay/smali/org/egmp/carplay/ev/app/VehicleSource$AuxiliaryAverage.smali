.class final Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;
.super Ljava/lang/Object;
.source "VehicleSource.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lorg/egmp/carplay/ev/app/VehicleSource;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "AuxiliaryAverage"
.end annotation


# instance fields
.field private averaged:Z

.field private count:I

.field private published:I

.field private started:J

.field private sum:J


# direct methods
.method constructor <init>(I)V
    .registers 4

    .line 37
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-wide/16 v0, -0x1

    .line 34
    iput-wide v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    .line 37
    iput p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->published:I

    return-void
.end method


# virtual methods
.method hasAverage()Z
    .registers 2

    .line 48
    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->averaged:Z

    return v0
.end method

.method update(Ljava/lang/Integer;J)I
    .registers 13

    .line 39
    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    const/4 v2, 0x0

    const-wide/16 v3, 0x0

    cmp-long v5, v0, v3

    if-gez v5, :cond_c

    iput-wide p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    goto :goto_16

    :cond_c
    cmp-long v5, p2, v0

    if-gez v5, :cond_16

    .line 40
    iput-wide p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    iput-wide v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->sum:J

    iput v2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->count:I

    .line 41
    :cond_16
    :goto_16
    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    sub-long v0, p2, v0

    const-wide v5, 0xdf8475800L

    const/4 v7, 0x1

    cmp-long v8, v0, v5

    if-ltz v8, :cond_49

    .line 42
    iget v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->count:I

    if-lez v0, :cond_43

    iget-wide v5, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->sum:J

    long-to-double v5, v5

    int-to-double v0, v0

    invoke-static {v5, v6}, Ljava/lang/Double;->isNaN(D)Z

    invoke-static {v0, v1}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr v5, v0

    const-wide/high16 v0, 0x4039000000000000L    # 25.0

    div-double/2addr v5, v0

    invoke-static {v5, v6}, Ljava/lang/Math;->round(D)J

    move-result-wide v0

    const-wide/16 v5, 0x19

    mul-long v0, v0, v5

    long-to-int v1, v0

    iput v1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->published:I

    iput-boolean v7, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->averaged:Z

    .line 43
    :cond_43
    iput-wide p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->started:J

    iput-wide v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->sum:J

    iput v2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->count:I

    :cond_49
    if-eqz p1, :cond_69

    .line 45
    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1

    if-ltz p1, :cond_61

    const/16 p2, 0x7530

    if-gt p1, p2, :cond_61

    iget-wide p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->sum:J

    int-to-long v0, p1

    add-long/2addr p2, v0

    iput-wide p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->sum:J

    iget p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->count:I

    add-int/2addr p1, v7

    iput p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->count:I

    goto :goto_69

    :cond_61
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "auxiliary sample"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 46
    :cond_69
    :goto_69
    iget p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->published:I

    return p1
.end method
