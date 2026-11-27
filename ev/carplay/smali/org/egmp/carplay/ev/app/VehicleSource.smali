.class public final Lorg/egmp/carplay/ev/app/VehicleSource;
.super Ljava/lang/Object;
.source "VehicleSource.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;,
        Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;
    }
.end annotation


# static fields
.field static final AUXILIARY_ROUND_W:I = 0x19

.field static final AUXILIARY_WINDOW_NS:J = 0xdf8475800L

.field static final CAPACITY_TOLERANCE_WH:I = 0x3e8


# instance fields
.field public final acW:I

.field private adapter:Ljava/lang/Object;

.field private final auxiliaryAverage:Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;

.field private batterySelectionEvent:Ljava/lang/String;

.field private batterySource:Ljava/lang/String;

.field private binder:Ljava/lang/Object;

.field private final capacityProfiles:Lorg/json/JSONObject;

.field private charging:Ljava/lang/String;

.field private final consumption:Ljava/lang/String;

.field public final dcW:I

.field public final displayName:Ljava/lang/String;

.field private maxWh:I

.field private final minWh:I

.field private final service:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Ljava/lang/Object;Ljava/lang/String;)V
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const/4 v0, 0x0

    .line 50
    invoke-direct {p0, p1, p2, v0}, Lorg/egmp/carplay/ev/app/VehicleSource;-><init>(Ljava/lang/Object;Ljava/lang/String;I)V

    return-void
.end method

.method public constructor <init>(Ljava/lang/Object;Ljava/lang/String;I)V
    .registers 12
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 51
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const-string v0, "unresolved"

    .line 26
    iput-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySource:Ljava/lang/String;

    .line 52
    iput-object p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->service:Ljava/lang/Object;

    new-instance p1, Lorg/json/JSONObject;

    invoke-direct {p1, p2}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string p2, "schema_version"

    .line 53
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p2

    const/4 v0, 0x1

    if-ne p2, v0, :cond_18f

    const-string p2, "vehicle"

    .line 54
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p2

    const-string v1, "display_name"

    invoke-virtual {p2, v1}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p2

    iput-object p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->displayName:Ljava/lang/String;

    .line 55
    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    if-eqz v1, :cond_187

    invoke-virtual {p2}, Ljava/lang/String;->length()I

    move-result v1

    const/16 v2, 0x50

    if-gt v1, v2, :cond_187

    const/4 v1, 0x0

    invoke-virtual {p2, v1}, Ljava/lang/String;->indexOf(I)I

    move-result p2

    if-gez p2, :cond_187

    const-string p2, "connectors"

    .line 56
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v2

    .line 57
    invoke-virtual {v2}, Lorg/json/JSONArray;->length()I

    move-result v3

    const/4 v4, 0x2

    if-ne v3, v4, :cond_181

    const/4 p2, 0x0

    const/4 v3, 0x0

    :goto_49
    if-ge v1, v4, :cond_8c

    .line 58
    invoke-virtual {v2, v1}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v5

    const-string v6, "maximum_power_w"

    invoke-virtual {v5, v6}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v6

    const-string v7, "type"

    invoke-virtual {v5, v7}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    if-lt v6, v0, :cond_84

    const v7, 0xf4240

    if-gt v6, v7, :cond_84

    const-string v7, "ccs1"

    .line 60
    invoke-virtual {v5, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_6e

    if-nez p2, :cond_6e

    move p2, v6

    goto :goto_79

    :cond_6e
    const-string v7, "j1772"

    invoke-virtual {v5, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_7c

    if-nez v3, :cond_7c

    move v3, v6

    :goto_79
    add-int/lit8 v1, v1, 0x1

    goto :goto_49

    :cond_7c
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "connector type"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 59
    :cond_84
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "connector power"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 61
    :cond_8c
    iput p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->dcW:I

    iput v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->acW:I

    const-string p2, "battery"

    .line 62
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p2

    const-string v0, "minimum_energy_wh"

    invoke-virtual {p2, v0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p2

    iput p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->minWh:I

    if-nez p2, :cond_179

    const-string p2, "reference_capacity_wh"

    .line 63
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p2

    const v0, 0x12e58

    if-ne p2, v0, :cond_179

    const-string p2, "capacity_profiles"

    .line 64
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p2

    iput-object p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->capacityProfiles:Lorg/json/JSONObject;

    invoke-virtual {p2}, Lorg/json/JSONObject;->length()I

    move-result p2

    if-eqz p2, :cond_171

    const-string p2, "charging_contract"

    .line 65
    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p2

    const-string v0, "consumption_contract"

    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p1

    const-string v0, "model_id"

    .line 66
    invoke-virtual {p2, v0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v1

    const v2, 0xc0000a

    if-ne v1, v2, :cond_169

    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v0

    const v1, 0xc00009

    if-ne v0, v1, :cond_169

    const-string v0, "vehicle_parameters"

    .line 67
    invoke-virtual {p2, v0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p2

    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v1

    const-string v2, "vehicle_energy_axis_wh"

    .line 68
    invoke-virtual {p2, v2}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v2

    invoke-virtual {v2}, Lorg/json/JSONArray;->length()I

    move-result v2

    const/16 v3, 0xb

    if-ne v2, v3, :cond_161

    const-string v2, "vehicle_charge_axis_w"

    invoke-virtual {p2, v2}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v2

    invoke-virtual {v2}, Lorg/json/JSONArray;->length()I

    move-result v2

    if-ne v2, v3, :cond_161

    const-string v2, "energy_w_per_h"

    invoke-virtual {p2, v2}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p2

    invoke-virtual {p2}, Lorg/json/JSONArray;->length()I

    move-result p2

    const/16 v2, 0x15

    if-ne p2, v2, :cond_161

    const-string p2, "vehicle_consumption_values_wh_per_m"

    invoke-virtual {v1, p2}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object p2

    invoke-virtual {p2}, Lorg/json/JSONArray;->length()I

    move-result p2

    const/16 v1, 0xa

    if-ne p2, v1, :cond_161

    .line 69
    invoke-virtual {p1}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object p2

    iput-object p2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->consumption:Ljava/lang/String;

    invoke-static {p2}, Lorg/egmp/carplay/ev/app/VehicleSource;->bounded(Ljava/lang/String;)[B

    .line 70
    invoke-virtual {p1, v0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p1

    const-string p2, "vehicle_auxiliary_power_w"

    invoke-virtual {p1, p2}, Lorg/json/JSONObject;->getDouble(Ljava/lang/String;)D

    move-result-wide p1

    .line 71
    invoke-static {p1, p2}, Ljava/lang/Double;->isNaN(D)Z

    move-result v0

    if-nez v0, :cond_159

    invoke-static {p1, p2}, Ljava/lang/Double;->isInfinite(D)Z

    move-result v0

    if-nez v0, :cond_159

    const-wide/16 v0, 0x0

    cmpg-double v2, p1, v0

    if-ltz v2, :cond_159

    const-wide v0, 0x40dd4c0000000000L    # 30000.0

    cmpl-double v2, p1, v0

    if-gtz v2, :cond_159

    .line 72
    new-instance v0, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;

    invoke-static {p1, p2}, Ljava/lang/Math;->round(D)J

    move-result-wide p1

    long-to-int p2, p1

    invoke-direct {v0, p2}, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;-><init>(I)V

    iput-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->auxiliaryAverage:Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;

    if-eqz p3, :cond_158

    .line 73
    invoke-direct {p0, p3}, Lorg/egmp/carplay/ev/app/VehicleSource;->resolveOverride(I)V

    :cond_158
    return-void

    .line 71
    :cond_159
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "auxiliary default"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 68
    :cond_161
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "contract shape"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 66
    :cond_169
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "contract roles"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 64
    :cond_171
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "capacity profiles"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 63
    :cond_179
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "unsupported reference capacity"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 57
    :cond_181
    new-instance p1, Ljava/lang/IllegalArgumentException;

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 55
    :cond_187
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "display name"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 53
    :cond_18f
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string p2, "profile schema"

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    goto :goto_198

    :goto_197
    throw p1

    :goto_198
    goto :goto_197
.end method

.method static auxiliary(IIII)I
    .registers 5

    if-ltz p0, :cond_2d

    const v0, 0xffff

    if-ge p0, v0, :cond_2d

    if-ltz p1, :cond_2d

    const/16 v0, 0xff

    if-ge p1, v0, :cond_2d

    if-ltz p2, :cond_2d

    if-ge p2, v0, :cond_2d

    if-ltz p3, :cond_2d

    if-ge p3, v0, :cond_2d

    mul-int/lit8 p0, p0, 0x14

    mul-int/lit8 p1, p1, 0xa

    add-int/2addr p0, p1

    mul-int/lit8 p2, p2, 0x14

    add-int/2addr p0, p2

    mul-int/lit8 p3, p3, 0x64

    add-int/2addr p0, p3

    const/16 p1, 0x7530

    if-gt p0, p1, :cond_25

    return p0

    .line 138
    :cond_25
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "auxiliary watts"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 137
    :cond_2d
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "auxiliary raw"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private static bounded(Ljava/lang/String;)[B
    .registers 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "UTF-8"

    .line 116
    invoke-virtual {p0, v0}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v0

    array-length v1, v0

    if-eqz v1, :cond_16

    array-length v1, v0

    const/16 v2, 0x2000

    if-ge v1, v2, :cond_16

    const/4 v1, 0x0

    invoke-virtual {p0, v1}, Ljava/lang/String;->indexOf(I)I

    move-result p0

    if-gez p0, :cond_16

    return-object v0

    :cond_16
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "contract length/NUL"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private static constant(Ljava/lang/String;Ljava/lang/String;)I
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 119
    invoke-static {p0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0

    const/4 p1, 0x1

    invoke-virtual {p0, p1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    const/4 p1, 0x0

    invoke-virtual {p0, p1}, Ljava/lang/reflect/Field;->getInt(Ljava/lang/Object;)I

    move-result p0

    return p0
.end method

.method static displayedSoc(D)I
    .registers 5

    .line 142
    invoke-static {p0, p1}, Ljava/lang/Double;->isNaN(D)Z

    move-result v0

    if-nez v0, :cond_1e

    invoke-static {p0, p1}, Ljava/lang/Double;->isInfinite(D)Z

    move-result v0

    if-nez v0, :cond_1e

    const-wide/16 v0, 0x0

    cmpg-double v2, p0, v0

    if-ltz v2, :cond_1e

    const-wide/high16 v0, 0x4059000000000000L    # 100.0

    cmpl-double v2, p0, v0

    if-gtz v2, :cond_1e

    .line 143
    invoke-static {p0, p1}, Ljava/lang/Math;->floor(D)D

    move-result-wide p0

    double-to-int p0, p0

    return p0

    .line 142
    :cond_1e
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "SOC bounds"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static encode(IILjava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/Integer;Z)Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;
    .registers 17
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v8, "test"

    move v0, p0

    move v1, p1

    move-object v2, p2

    move-object v3, p3

    move-object v4, p4

    move-object v5, p5

    move-object v6, p6

    move/from16 v7, p7

    .line 174
    invoke-static/range {v0 .. v8}, Lorg/egmp/carplay/ev/app/VehicleSource;->encode(IILjava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/Integer;ZLjava/lang/String;)Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;

    move-result-object v0

    return-object v0
.end method

.method static encode(IILjava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/Integer;ZLjava/lang/String;)Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;
    .registers 26
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    move/from16 v0, p1

    const/16 v1, 0x9

    new-array v1, v1, [I

    const/4 v2, 0x0

    aput p0, v1, v2

    const/4 v3, 0x1

    aput v0, v1, v3

    const/4 v4, 0x2

    aput v2, v1, v4

    const/4 v5, 0x3

    aput v2, v1, v5

    const/4 v6, 0x4

    aput v2, v1, v6

    const/4 v7, 0x5

    aput v2, v1, v7

    const/4 v8, 0x6

    aput v2, v1, v8

    const/4 v9, 0x7

    aput v2, v1, v9

    const/16 v10, 0x8

    aput v2, v1, v10

    if-eqz p4, :cond_a5

    if-eqz p5, :cond_a5

    .line 179
    invoke-virtual/range {p4 .. p4}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v11

    invoke-virtual/range {p5 .. p5}, Ljava/lang/Integer;->intValue()I

    move-result v13

    .line 180
    invoke-static {v11, v12}, Ljava/lang/Double;->isNaN(D)Z

    move-result v14

    if-nez v14, :cond_9d

    invoke-static {v11, v12}, Ljava/lang/Double;->isInfinite(D)Z

    move-result v14

    if-nez v14, :cond_9d

    const-wide/16 v14, 0x0

    cmpg-double v16, v11, v14

    if-ltz v16, :cond_9d

    const-wide/high16 v14, 0x4059000000000000L    # 100.0

    cmpl-double v16, v11, v14

    if-gtz v16, :cond_9d

    if-ltz v13, :cond_9d

    const/16 v14, 0x7d0

    if-ge v13, v14, :cond_9d

    const-wide v14, 0x408f400000000000L    # 1000.0

    mul-double v11, v11, v14

    .line 181
    invoke-static {v11, v12}, Ljava/lang/Math;->round(D)J

    move-result-wide v11

    long-to-int v12, v11

    int-to-long v14, v0

    int-to-long v10, v12

    mul-long v14, v14, v10

    const-wide/32 v10, 0xc350

    add-long/2addr v14, v10

    const-wide/32 v10, 0x186a0

    div-long/2addr v14, v10

    long-to-int v0, v14

    aput v0, v1, v4

    aput v12, v1, v5

    aput v13, v1, v6

    const/16 v0, 0x4e20

    if-gt v12, v0, :cond_70

    const/4 v2, 0x1

    :cond_70
    aput v2, v1, v7

    aput v3, v1, v9

    if-lez v12, :cond_a5

    int-to-double v4, v13

    const-wide v6, 0x40f86a0000000000L    # 100000.0

    .line 182
    invoke-static {v4, v5}, Ljava/lang/Double;->isNaN(D)Z

    mul-double v4, v4, v6

    int-to-double v6, v12

    invoke-static {v6, v7}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr v4, v6

    invoke-static {v4, v5}, Ljava/lang/Math;->round(D)J

    move-result-wide v4

    int-to-long v6, v13

    cmp-long v0, v4, v6

    if-ltz v0, :cond_a5

    const-wide/16 v6, 0x7d0

    cmp-long v0, v4, v6

    if-gez v0, :cond_a5

    long-to-int v0, v4

    aput v0, v1, v8

    const/16 v0, 0x8

    aput v3, v1, v0

    goto :goto_a5

    .line 180
    :cond_9d
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "sample"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 184
    :cond_a5
    :goto_a5
    new-instance v0, Lorg/json/JSONObject;

    move-object/from16 v2, p3

    invoke-direct {v0, v2}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string v2, "vehicle_auxiliary_power_w"

    const-string v3, "vehicle_parameters"

    if-eqz p6, :cond_d4

    .line 185
    invoke-virtual/range {p6 .. p6}, Ljava/lang/Integer;->intValue()I

    move-result v4

    if-ltz v4, :cond_cc

    invoke-virtual/range {p6 .. p6}, Ljava/lang/Integer;->intValue()I

    move-result v4

    const/16 v5, 0x7530

    if-gt v4, v5, :cond_cc

    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v4

    invoke-virtual/range {p6 .. p6}, Ljava/lang/Integer;->doubleValue()D

    move-result-wide v5

    invoke-virtual {v4, v2, v5, v6}, Lorg/json/JSONObject;->put(Ljava/lang/String;D)Lorg/json/JSONObject;

    goto :goto_d4

    :cond_cc
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "auxiliary watts"

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 186
    :cond_d4
    :goto_d4
    new-instance v4, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;

    invoke-static/range {p2 .. p2}, Lorg/egmp/carplay/ev/app/VehicleSource;->bounded(Ljava/lang/String;)[B

    move-result-object v5

    invoke-virtual {v0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lorg/egmp/carplay/ev/app/VehicleSource;->bounded(Ljava/lang/String;)[B

    move-result-object v6

    const-string v7, "profile_default"

    if-nez p6, :cond_e7

    goto :goto_eb

    :cond_e7
    if-eqz p7, :cond_eb

    const-string v7, "one_minute_average"

    :cond_eb
    :goto_eb
    invoke-virtual {v0, v3}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v0

    invoke-virtual {v0, v2}, Lorg/json/JSONObject;->getDouble(Ljava/lang/String;)D

    move-result-wide v2

    move-object/from16 p0, v4

    move-object/from16 p1, v1

    move-object/from16 p2, v5

    move-object/from16 p3, v6

    move-object/from16 p4, v7

    move-wide/from16 p5, v2

    move-object/from16 p7, p8

    invoke-direct/range {p0 .. p7}, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;-><init>([I[B[BLjava/lang/String;DLjava/lang/String;)V

    return-object v4
.end method

.method private static flag(Ljava/lang/String;)Ljava/lang/Integer;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "com.hkmc.hev.HEVManager$HEVFlag"

    .line 122
    invoke-static {v0, p0}, Lorg/egmp/carplay/ev/app/VehicleSource;->constant(Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    return-object p0
.end method

.method static fresh(JJ)Z
    .registers 7

    sub-long/2addr p2, p0

    const-wide/16 v0, 0x0

    cmp-long v2, p0, v0

    if-eqz v2, :cond_16

    cmp-long p0, p2, v0

    if-ltz p0, :cond_16

    const-wide p0, 0x37e11d600L

    cmp-long v0, p2, p0

    if-gtz v0, :cond_16

    const/4 p0, 0x1

    goto :goto_17

    :cond_16
    const/4 p0, 0x0

    :goto_17
    return p0
.end method

.method private hev(Ljava/lang/String;Ljava/lang/Integer;)I
    .registers 16
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "recycle"

    .line 124
    invoke-static {p1}, Lorg/egmp/carplay/ev/app/VehicleSource;->tx(Ljava/lang/String;)I

    move-result p1

    const-string v1, "android.os.Parcel"

    .line 125
    invoke-static {v1}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v1

    const-string v2, "android.os.IBinder"

    invoke-static {v2}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v2

    .line 126
    iget-object v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->binder:Ljava/lang/Object;

    const/4 v4, 0x0

    const/4 v5, 0x1

    const/4 v6, 0x0

    if-nez v3, :cond_37

    const-string v3, "android.os.ServiceManager"

    invoke-static {v3}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v3

    new-array v7, v5, [Ljava/lang/Class;

    const-class v8, Ljava/lang/String;

    aput-object v8, v7, v6

    const-string v8, "getService"

    invoke-virtual {v3, v8, v7}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    new-array v7, v5, [Ljava/lang/Object;

    const-string v8, "com.hkmc.micom.hev"

    aput-object v8, v7, v6

    invoke-virtual {v3, v4, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    iput-object v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->binder:Ljava/lang/Object;

    .line 127
    :cond_37
    iget-object v3, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->binder:Ljava/lang/Object;

    if-eqz v3, :cond_10e

    new-array v3, v6, [Ljava/lang/Class;

    const-string v7, "obtain"

    .line 128
    invoke-virtual {v1, v7, v3}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v3

    new-array v8, v6, [Ljava/lang/Object;

    invoke-virtual {v3, v4, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    new-array v8, v6, [Ljava/lang/Class;

    invoke-virtual {v1, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v7

    new-array v8, v6, [Ljava/lang/Object;

    invoke-virtual {v7, v4, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    :try_start_55
    const-string v7, "writeInterfaceToken"

    new-array v8, v5, [Ljava/lang/Class;

    .line 130
    const-class v9, Ljava/lang/String;

    aput-object v9, v8, v6

    invoke-virtual {v1, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v7

    new-array v8, v5, [Ljava/lang/Object;

    const-string v9, "com.hkmc.hev.IHEVService"

    aput-object v9, v8, v6

    invoke-virtual {v7, v3, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    if-eqz p2, :cond_7f

    const-string v7, "writeInt"

    new-array v8, v5, [Ljava/lang/Class;

    .line 131
    sget-object v9, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v9, v8, v6

    invoke-virtual {v1, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v7

    new-array v8, v5, [Ljava/lang/Object;

    aput-object p2, v8, v6

    invoke-virtual {v7, v3, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    .line 132
    :cond_7f
    sget-object p2, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v7, "transact"

    const/4 v8, 0x4

    new-array v9, v8, [Ljava/lang/Class;

    sget-object v10, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    aput-object v10, v9, v6

    aput-object v1, v9, v5

    const/4 v10, 0x2

    aput-object v1, v9, v10

    sget-object v11, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v12, 0x3

    aput-object v11, v9, v12

    invoke-virtual {v2, v7, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v2

    iget-object v7, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->binder:Ljava/lang/Object;

    new-array v8, v8, [Ljava/lang/Object;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    aput-object p1, v8, v6

    aput-object v3, v8, v5

    aput-object v4, v8, v10

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    aput-object p1, v8, v12

    invoke-virtual {v2, v7, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {p2, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_ee

    const-string p1, "readException"

    new-array p2, v6, [Ljava/lang/Class;

    .line 133
    invoke-virtual {v1, p1, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    new-array p2, v6, [Ljava/lang/Object;

    invoke-virtual {p1, v4, p2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    const-string p1, "readInt"

    new-array p2, v6, [Ljava/lang/Class;

    invoke-virtual {v1, p1, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p1

    new-array p2, v6, [Ljava/lang/Object;

    invoke-virtual {p1, v4, p2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1
    :try_end_d7
    .catchall {:try_start_55 .. :try_end_d7} :catchall_f6

    new-array p2, v6, [Ljava/lang/Class;

    .line 134
    invoke-virtual {v1, v0, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p2

    new-array v2, v6, [Ljava/lang/Object;

    invoke-virtual {p2, v3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    new-array p2, v6, [Ljava/lang/Class;

    invoke-virtual {v1, v0, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p2

    new-array v0, v6, [Ljava/lang/Object;

    invoke-virtual {p2, v4, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    return p1

    .line 132
    :cond_ee
    :try_start_ee
    new-instance p1, Ljava/io/IOException;

    const-string p2, "HEV refused"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
    :try_end_f6
    .catchall {:try_start_ee .. :try_end_f6} :catchall_f6

    :catchall_f6
    move-exception p1

    new-array p2, v6, [Ljava/lang/Class;

    .line 134
    invoke-virtual {v1, v0, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p2

    new-array v2, v6, [Ljava/lang/Object;

    invoke-virtual {p2, v3, v2}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    new-array p2, v6, [Ljava/lang/Class;

    invoke-virtual {v1, v0, p2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object p2

    new-array v0, v6, [Ljava/lang/Object;

    invoke-virtual {p2, v4, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    throw p1

    .line 127
    :cond_10e
    new-instance p1, Ljava/io/IOException;

    const-string p2, "HEV unavailable"

    invoke-direct {p1, p2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public static readFile(Ljava/lang/String;)Ljava/lang/String;
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 109
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p0}, Ljava/io/FileInputStream;-><init>(Ljava/lang/String;)V

    .line 110
    :try_start_5
    new-instance p0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {p0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    const/16 v1, 0x1000

    new-array v1, v1, [B

    .line 111
    :goto_e
    invoke-virtual {v0, v1}, Ljava/io/InputStream;->read([B)I

    move-result v2

    const/4 v3, -0x1

    if-eq v2, v3, :cond_2c

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v3

    add-int/2addr v3, v2

    const v4, 0x8000

    if-gt v3, v4, :cond_24

    const/4 v3, 0x0

    invoke-virtual {p0, v1, v3, v2}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_e

    :cond_24
    new-instance p0, Ljava/io/IOException;

    const-string v1, "file too large"

    invoke-direct {p0, v1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 112
    :cond_2c
    new-instance v1, Ljava/lang/String;

    invoke-virtual {p0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object p0

    const-string v2, "UTF-8"

    invoke-direct {v1, p0, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_37
    .catchall {:try_start_5 .. :try_end_37} :catchall_3b

    .line 113
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    return-object v1

    :catchall_3b
    move-exception p0

    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    goto :goto_41

    :goto_40
    throw p0

    :goto_41
    goto :goto_40
.end method

.method private resolveBattery(I)V
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 95
    iget-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->capacityProfiles:Lorg/json/JSONObject;

    invoke-static {v0, p1}, Lorg/egmp/carplay/ev/app/VehicleSource;->selectCapacity(Lorg/json/JSONObject;I)I

    move-result v0

    sub-int v1, v0, p1

    invoke-static {v1}, Ljava/lang/Math;->abs(I)I

    move-result v1

    .line 96
    iget-object v2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->capacityProfiles:Lorg/json/JSONObject;

    invoke-static {v2, v0}, Lorg/egmp/carplay/ev/app/VehicleSource;->selectCharging(Lorg/json/JSONObject;I)Ljava/lang/String;

    move-result-object v2

    iput-object v2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->charging:Ljava/lang/String;

    iput v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    .line 97
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "bms_evenergycapa_reported_"

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "_profile_"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, "_difference_"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    iput-object v2, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySource:Ljava/lang/String;

    .line 98
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "battery profile selected: source=BMS reported="

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh, profile="

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh, difference="

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh"

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySelectionEvent:Ljava/lang/String;

    return-void
.end method

.method private resolveOverride(I)V
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 101
    :try_start_0
    iget-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->capacityProfiles:Lorg/json/JSONObject;

    invoke-static {v0, p1}, Lorg/egmp/carplay/ev/app/VehicleSource;->selectCharging(Lorg/json/JSONObject;I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->charging:Ljava/lang/String;
    :try_end_8
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_8} :catch_30

    .line 103
    iput p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "settings_override_profile_"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySource:Ljava/lang/String;

    .line 104
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "battery profile selected: source=settings override, profile="

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh"

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySelectionEvent:Ljava/lang/String;

    return-void

    .line 102
    :catch_30
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "unsupported battery capacity override capacity_wh="

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " supported="

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->capacityProfiles:Lorg/json/JSONObject;

    invoke-virtual {p1}, Lorg/json/JSONObject;->names()Lorg/json/JSONArray;

    move-result-object p1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method static selectCapacity(Lorg/json/JSONObject;I)I
    .registers 9
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 76
    invoke-virtual {p0}, Lorg/json/JSONObject;->names()Lorg/json/JSONArray;

    move-result-object p0

    if-eqz p0, :cond_71

    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v0

    if-eqz v0, :cond_71

    const/4 v0, 0x0

    const v1, 0x7fffffff

    const/4 v2, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    .line 78
    :goto_13
    invoke-virtual {p0}, Lorg/json/JSONArray;->length()I

    move-result v5

    if-ge v2, v5, :cond_33

    .line 79
    invoke-virtual {p0, v2}, Lorg/json/JSONArray;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v5

    sub-int v6, v5, p1

    invoke-static {v6}, Ljava/lang/Math;->abs(I)I

    move-result v6

    if-ge v6, v1, :cond_2d

    move v4, v5

    move v1, v6

    const/4 v3, 0x0

    goto :goto_30

    :cond_2d
    if-ne v6, v1, :cond_30

    const/4 v3, 0x1

    :cond_30
    :goto_30
    add-int/lit8 v2, v2, 0x1

    goto :goto_13

    :cond_33
    if-nez v3, :cond_3b

    const/16 v0, 0x3e8

    if-le v1, v0, :cond_3a

    goto :goto_3b

    :cond_3a
    return v4

    .line 83
    :cond_3b
    :goto_3b
    new-instance v0, Ljava/io/IOException;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v5, "unexpected BMS energy capacity: reported="

    invoke-direct {v2, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh, nearest profile="

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh, difference="

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " Wh, tolerance=1000 Wh, supported="

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    if-eqz v3, :cond_64

    const-string p0, ", ambiguous tie"

    goto :goto_66

    :cond_64
    const-string p0, ""

    :goto_66
    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 76
    :cond_71
    new-instance p0, Ljava/io/IOException;

    const-string p1, "no capacity profiles"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    goto :goto_7a

    :goto_79
    throw p0

    :goto_7a
    goto :goto_79
.end method

.method static selectCharging(Lorg/json/JSONObject;I)Ljava/lang/String;
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 87
    invoke-static {p1}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lorg/json/JSONObject;->optJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v0

    if-eqz v0, :cond_5b

    const-string p0, "maximum_energy_wh"

    .line 89
    invoke-virtual {v0, p0}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result p0

    if-ne p0, p1, :cond_53

    const-string p0, "charging_contract"

    .line 90
    invoke-virtual {v0, p0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object p0

    const-string v0, "vehicle_parameters"

    invoke-virtual {p0, v0}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v0

    const-string v1, "model_id"

    .line 91
    invoke-virtual {p0, v1}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v1

    const v2, 0xc0000a

    if-ne v1, v2, :cond_3f

    const-string v1, "vehicle_energy_axis_wh"

    invoke-virtual {v0, v1}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v0

    const/16 v1, 0xa

    invoke-virtual {v0, v1}, Lorg/json/JSONArray;->getInt(I)I

    move-result v0

    if-ne v0, p1, :cond_3f

    .line 92
    invoke-virtual {p0}, Lorg/json/JSONObject;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lorg/egmp/carplay/ev/app/VehicleSource;->bounded(Ljava/lang/String;)[B

    return-object p0

    .line 91
    :cond_3f
    new-instance p0, Ljava/io/IOException;

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "invalid capacity profile "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 89
    :cond_53
    new-instance p0, Ljava/io/IOException;

    const-string p1, "capacity profile mismatch"

    invoke-direct {p0, p1}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 88
    :cond_5b
    new-instance v0, Ljava/io/IOException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "unsupported BMS_EVENERGYCAPA capacity_wh="

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, " supported="

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p0}, Lorg/json/JSONObject;->names()Lorg/json/JSONArray;

    move-result-object p0

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static tx(Ljava/lang/String;)I
    .registers 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 121
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "TRANSACTION_"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "com.hkmc.hev.IHEVService$Stub"

    invoke-static {v0, p0}, Lorg/egmp/carplay/ev/app/VehicleSource;->constant(Ljava/lang/String;Ljava/lang/String;)I

    move-result p0

    return p0
.end method


# virtual methods
.method batterySelection()Ljava/lang/String;
    .registers 2

    .line 106
    iget v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    if-nez v0, :cond_7

    const-string v0, "automatic_bms"

    goto :goto_9

    :cond_7
    iget-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySource:Ljava/lang/String;

    :goto_9
    return-object v0
.end method

.method public declared-synchronized poll()Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;
    .registers 20
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    move-object/from16 v1, p0

    const-string v0, "unexpected BMS energy capacity: raw="

    monitor-enter p0

    const/4 v2, 0x2

    const/4 v3, 0x0

    .line 148
    :try_start_7
    iget-object v4, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    const/4 v5, 0x1

    const/4 v6, 0x0

    if-nez v4, :cond_69

    .line 149
    iget-object v4, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->service:Ljava/lang/Object;

    invoke-virtual {v4}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    const-string v7, "getClassLoader"

    new-array v8, v6, [Ljava/lang/Class;

    invoke-virtual {v4, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    iget-object v7, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->service:Ljava/lang/Object;

    new-array v8, v6, [Ljava/lang/Object;

    invoke-virtual {v4, v7, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/ClassLoader;

    const-string v7, "dalvik.system.PathClassLoader"

    .line 150
    invoke-static {v7}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v7

    new-array v8, v2, [Ljava/lang/Class;

    const-class v9, Ljava/lang/String;

    aput-object v9, v8, v6

    const-class v9, Ljava/lang/ClassLoader;

    aput-object v9, v8, v5

    invoke-virtual {v7, v8}, Ljava/lang/Class;->getConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v7

    new-array v8, v2, [Ljava/lang/Object;

    const-string v9, "/system/framework/com.hkmc.ext.hcan.jar"

    aput-object v9, v8, v6

    aput-object v4, v8, v5

    invoke-virtual {v7, v8}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/ClassLoader;

    const-string v7, "com.hkmc.telematics.hscan.tm_interface.TM_HSCANAdapter"

    .line 151
    invoke-virtual {v4, v7}, Ljava/lang/ClassLoader;->loadClass(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v4

    const-string v7, "getDefaultAdapter"

    new-array v8, v5, [Ljava/lang/Class;

    const-string v9, "android.content.Context"

    .line 152
    invoke-static {v9}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v9

    aput-object v9, v8, v6

    invoke-virtual {v4, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    new-array v7, v5, [Ljava/lang/Object;

    iget-object v8, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->service:Ljava/lang/Object;

    aput-object v8, v7, v6

    invoke-virtual {v4, v3, v7}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    iput-object v4, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    .line 154
    :cond_69
    iget-object v4, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    invoke-virtual {v4}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    const-string v7, "remainBatteryPercentage"

    new-array v8, v6, [Ljava/lang/Class;

    invoke-virtual {v4, v7, v8}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v4

    iget-object v7, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    new-array v8, v6, [Ljava/lang/Object;

    invoke-virtual {v4, v7, v8}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    .line 155
    iget-object v7, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    invoke-virtual {v7}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v7

    const-string v8, "ableDriveDistance"

    new-array v9, v5, [Ljava/lang/Class;

    sget-object v10, Ljava/lang/Byte;->TYPE:Ljava/lang/Class;

    aput-object v10, v9, v6

    invoke-virtual {v7, v8, v9}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v7

    iget-object v8, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;

    new-array v5, v5, [Ljava/lang/Object;

    invoke-static {v6}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v9

    aput-object v9, v5, v6

    invoke-virtual {v7, v8, v5}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    .line 156
    instance-of v6, v4, Ljava/lang/Number;

    if-eqz v6, :cond_d5

    instance-of v6, v5, Ljava/lang/Integer;

    if-eqz v6, :cond_d5

    .line 157
    check-cast v4, Ljava/lang/Number;

    invoke-virtual {v4}, Ljava/lang/Number;->doubleValue()D

    move-result-wide v6

    check-cast v5, Ljava/lang/Integer;

    invoke-virtual {v5}, Ljava/lang/Integer;->intValue()I

    move-result v4

    if-ltz v4, :cond_cd

    const/16 v5, 0x7d0

    if-ge v4, v5, :cond_cd

    .line 159
    invoke-static {v6, v7}, Lorg/egmp/carplay/ev/app/VehicleSource;->displayedSoc(D)I

    move-result v5

    int-to-double v5, v5

    invoke-static {v5, v6}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v5
    :try_end_c2
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_c2} :catch_e0
    .catchall {:try_start_7 .. :try_end_c2} :catchall_dd

    :try_start_c2
    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4
    :try_end_c6
    .catch Ljava/lang/Exception; {:try_start_c2 .. :try_end_c6} :catch_cb
    .catchall {:try_start_c2 .. :try_end_c6} :catchall_dd

    :try_start_c6
    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v6
    :try_end_ca
    .catch Ljava/lang/Exception; {:try_start_c6 .. :try_end_ca} :catch_e2
    .catchall {:try_start_c6 .. :try_end_ca} :catchall_dd

    goto :goto_e6

    :catch_cb
    move-object v4, v3

    goto :goto_e2

    .line 158
    :cond_cd
    :try_start_cd
    new-instance v4, Ljava/io/IOException;

    const-string v5, "HSCAN bounds"

    invoke-direct {v4, v5}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v4

    .line 156
    :cond_d5
    new-instance v4, Ljava/io/IOException;

    const-string v5, "HSCAN types"

    invoke-direct {v4, v5}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v4
    :try_end_dd
    .catch Ljava/lang/Exception; {:try_start_cd .. :try_end_dd} :catch_e0
    .catchall {:try_start_cd .. :try_end_dd} :catchall_dd

    :catchall_dd
    move-exception v0

    goto/16 :goto_1bf

    :catch_e0
    move-object v4, v3

    move-object v5, v4

    .line 160
    :catch_e2
    :goto_e2
    :try_start_e2
    iput-object v3, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->adapter:Ljava/lang/Object;
    :try_end_e4
    .catchall {:try_start_e2 .. :try_end_e4} :catchall_dd

    const-wide/16 v6, 0x0

    :goto_e6
    :try_start_e6
    const-string v8, "getCanDBGenerationInfo"

    .line 163
    invoke-direct {v1, v8, v3}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v8

    if-ne v8, v2, :cond_16f

    .line 164
    iget v2, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    if-nez v2, :cond_134

    const-string v2, "getHEVStatus"

    const-string v8, "BMS_EVENERGYCAPA"

    invoke-static {v8}, Lorg/egmp/carplay/ev/app/VehicleSource;->flag(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v8

    invoke-direct {v1, v2, v8}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v2

    int-to-long v8, v2

    const-wide/16 v10, 0x2

    mul-long v8, v8, v10

    const-wide/16 v10, 0x2710

    cmp-long v12, v8, v10

    if-ltz v12, :cond_115

    const-wide/32 v10, 0x30d40

    cmp-long v12, v8, v10

    if-gtz v12, :cond_115

    long-to-int v0, v8

    invoke-direct {v1, v0}, Lorg/egmp/carplay/ev/app/VehicleSource;->resolveBattery(I)V

    goto :goto_134

    :cond_115
    new-instance v10, Ljava/io/IOException;

    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v11, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, ", reported="

    invoke-virtual {v11, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v11, v8, v9}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    const-string v0, " Wh"

    invoke-virtual {v11, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v10, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v10

    :cond_134
    :goto_134
    const-string v0, "getHEVStatus"

    const-string v2, "DATC_CLMTPWRCNSMPTN_W"

    .line 165
    invoke-static {v2}, Lorg/egmp/carplay/ev/app/VehicleSource;->flag(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v2

    invoke-direct {v1, v0, v2}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v0

    const-string v2, "getHEVStatus"

    const-string v8, "PWR_OTHER_ECU"

    invoke-static {v8}, Lorg/egmp/carplay/ev/app/VehicleSource;->flag(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v8

    invoke-direct {v1, v2, v8}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v2

    const-string v8, "getHEVStatus"

    const-string v9, "DATC_BATTERYCOMPPWRCON_W"

    invoke-static {v9}, Lorg/egmp/carplay/ev/app/VehicleSource;->flag(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v9

    invoke-direct {v1, v8, v9}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v8

    const-string v9, "getHEVStatus"

    const-string v10, "XEV_BATHEATPWRMONCON_W"

    invoke-static {v10}, Lorg/egmp/carplay/ev/app/VehicleSource;->flag(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v10

    invoke-direct {v1, v9, v10}, Lorg/egmp/carplay/ev/app/VehicleSource;->hev(Ljava/lang/String;Ljava/lang/Integer;)I

    move-result v9

    invoke-static {v0, v2, v8, v9}, Lorg/egmp/carplay/ev/app/VehicleSource;->auxiliary(IIII)I

    move-result v0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    move-object v2, v0

    move-object v0, v3

    goto :goto_17b

    .line 163
    :cond_16f
    new-instance v0, Ljava/io/IOException;

    const-string v2, "CAN generation"

    invoke-direct {v0, v2}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_177
    .catch Ljava/lang/Exception; {:try_start_e6 .. :try_end_177} :catch_177
    .catchall {:try_start_e6 .. :try_end_177} :catchall_dd

    :catch_177
    move-exception v0

    .line 166
    :try_start_178
    iput-object v3, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->binder:Ljava/lang/Object;

    move-object v2, v3

    .line 167
    :goto_17b
    iget v8, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    if-nez v8, :cond_18e

    new-instance v2, Ljava/io/IOException;

    if-nez v0, :cond_186

    const-string v0, "BMS energy capacity unavailable"

    goto :goto_18a

    :cond_186
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    :goto_18a
    invoke-direct {v2, v0}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 168
    :cond_18e
    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v8

    invoke-static {v6, v7, v8, v9}, Lorg/egmp/carplay/ev/app/VehicleSource;->fresh(JJ)Z

    move-result v0

    if-nez v0, :cond_19b

    move-object v14, v3

    move-object v15, v14

    goto :goto_19d

    :cond_19b
    move-object v15, v4

    move-object v14, v5

    .line 169
    :goto_19d
    iget-object v0, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->auxiliaryAverage:Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;

    invoke-virtual {v0, v2, v8, v9}, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->update(Ljava/lang/Integer;J)I

    move-result v0

    .line 170
    iget v10, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->minWh:I

    iget v11, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->maxWh:I

    iget-object v12, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->charging:Ljava/lang/String;

    iget-object v13, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->consumption:Ljava/lang/String;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v16

    iget-object v0, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->auxiliaryAverage:Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;

    invoke-virtual {v0}, Lorg/egmp/carplay/ev/app/VehicleSource$AuxiliaryAverage;->hasAverage()Z

    move-result v17

    iget-object v0, v1, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySource:Ljava/lang/String;

    move-object/from16 v18, v0

    invoke-static/range {v10 .. v18}, Lorg/egmp/carplay/ev/app/VehicleSource;->encode(IILjava/lang/String;Ljava/lang/String;Ljava/lang/Double;Ljava/lang/Integer;Ljava/lang/Integer;ZLjava/lang/String;)Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;

    move-result-object v0
    :try_end_1bd
    .catchall {:try_start_178 .. :try_end_1bd} :catchall_dd

    monitor-exit p0

    return-object v0

    :goto_1bf
    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized takeBatterySelectionEvent()Ljava/lang/String;
    .registers 3

    monitor-enter p0

    .line 107
    :try_start_1
    iget-object v0, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySelectionEvent:Ljava/lang/String;

    const/4 v1, 0x0

    iput-object v1, p0, Lorg/egmp/carplay/ev/app/VehicleSource;->batterySelectionEvent:Ljava/lang/String;
    :try_end_6
    .catchall {:try_start_1 .. :try_end_6} :catchall_8

    monitor-exit p0

    return-object v0

    :catchall_8
    move-exception v0

    monitor-exit p0

    throw v0
.end method
