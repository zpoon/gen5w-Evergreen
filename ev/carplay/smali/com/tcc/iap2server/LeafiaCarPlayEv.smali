.class public final Lcom/tcc/iap2server/LeafiaCarPlayEv;
.super Ljava/lang/Object;
.source "LeafiaCarPlayEv.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;
    }
.end annotation


# static fields
.field static final FRAMEWORKS:[[Ljava/lang/String;

.field static final LIB_EV:Ljava/lang/String; = "/system/lib/libcarplayev.so"

.field static final LIB_ID:Ljava/lang/String; = "/system/lib/libcarplayidentity.so"

.field static final SESSION:Ljava/lang/String; = "/system/lib/libiap2session.so"

.field static final SESSION_EV_MD5:Ljava/lang/String; = "b32703e6d702009da1cca02f4088ad58"

.field static final TAG:Ljava/lang/String; = "Leafia"

.field private static checked:Z

.field private static identityArmed:Z

.field private static ok:Z

.field private static profile:Ljava/lang/String;

.field private static profileName:Ljava/lang/String;

.field private static provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;


# direct methods
.method static constructor <clinit>()V
    .registers 6

    const/4 v0, 0x4

    new-array v0, v0, [[Ljava/lang/String;

    const/4 v1, 0x2

    new-array v2, v1, [Ljava/lang/String;

    const-string v3, "dd72e04bce0a2b4bda1506308ac21f91002c1436553b8156c345cc4313661338"

    const/4 v4, 0x0

    aput-object v3, v2, v4

    const-string v3, "3cf40fb00854c63afa49abea1dad18a0afcbc0dd68b17de9ed7ea3f5aeab4222"

    const/4 v5, 0x1

    aput-object v3, v2, v5

    aput-object v2, v0, v4

    new-array v2, v1, [Ljava/lang/String;

    const-string v3, "c52e0825956880d627b32979022705a618200f059476c094d729133d1ff6a3be"

    aput-object v3, v2, v4

    const-string v3, "bf17e682d1beb349ae8ef2acaae6d6e908fe42e88853d7145ee16b29bb4d9ec1"

    aput-object v3, v2, v5

    aput-object v2, v0, v5

    new-array v2, v1, [Ljava/lang/String;

    const-string v3, "b9e7e02b81e1a8cfcf767c6b8bbb28bcf1d2c411a208fbf6a465e7f0c662774a"

    aput-object v3, v2, v4

    const-string v3, "8af745b41aa28f490953d61531215cd94e059f104b31f6236a8f6c7af23b8062"

    aput-object v3, v2, v5

    aput-object v2, v0, v1

    new-array v1, v1, [Ljava/lang/String;

    const-string v2, "347d05034e6b25e38f8d0446a6e9f02f4c8f5b786c09e583a500235613514c18"

    aput-object v2, v1, v4

    const-string v2, "80bc04d04822464cfedb8878592f04eab8b16351be7aef6c70ff1ec9aa14d021"

    aput-object v2, v1, v5

    const/4 v2, 0x3

    aput-object v1, v0, v2

    .line 37
    sput-object v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->FRAMEWORKS:[[Ljava/lang/String;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 48
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static check()Ljava/lang/String;
    .registers 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 66
    new-instance v0, Ljava/io/File;

    const-string v1, "/system/lib/libcarplayev.so"

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result v0

    if-eqz v0, :cond_9e

    new-instance v0, Ljava/io/File;

    const-string v1, "/system/lib/libcarplayidentity.so"

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result v0

    if-nez v0, :cond_1c

    goto/16 :goto_9e

    :cond_1c
    const-string v0, "MD5"

    const-string v1, "/system/lib/libiap2session.so"

    .line 67
    invoke-static {v0, v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->digest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "b32703e6d702009da1cca02f4088ad58"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2f

    const-string v0, "libiap2session.so is not the EV build"

    return-object v0

    :cond_2f
    const-string v0, "/system/framework/automotive.odex"

    const-string v1, "SHA-256"

    .line 68
    invoke-static {v1, v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->digest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v2, "/system/framework/automotive-service.odex"

    .line 69
    invoke-static {v1, v2}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->digest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 71
    sget-object v2, Lcom/tcc/iap2server/LeafiaCarPlayEv;->FRAMEWORKS:[[Ljava/lang/String;

    array-length v3, v2

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    :goto_43
    const/4 v7, 0x1

    if-ge v5, v3, :cond_5c

    aget-object v8, v2, v5

    aget-object v9, v8, v4

    invoke-virtual {v9, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_59

    aget-object v8, v8, v7

    invoke-virtual {v8, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_59

    const/4 v6, 0x1

    :cond_59
    add-int/lit8 v5, v5, 0x1

    goto :goto_43

    :cond_5c
    if-nez v6, :cond_61

    const-string v0, "framework is not a checked one"

    return-object v0

    :cond_61
    const-string v0, "android.os.SystemProperties"

    .line 73
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    new-array v1, v7, [Ljava/lang/Class;

    const-class v2, Ljava/lang/String;

    aput-object v2, v1, v4

    const-string v2, "get"

    .line 74
    invoke-virtual {v0, v2, v1}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    new-array v1, v7, [Ljava/lang/Object;

    const-string v2, "ro.build.product"

    aput-object v2, v1, v4

    const/4 v2, 0x0

    invoke-virtual {v0, v2, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 75
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEvProfiles;->forProduct(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v1

    if-nez v1, :cond_95

    .line 76
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "no profile for "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 77
    :cond_95
    aget-object v0, v1, v4

    sput-object v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->profileName:Ljava/lang/String;

    .line 78
    aget-object v0, v1, v7

    sput-object v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->profile:Ljava/lang/String;

    return-object v2

    :cond_9e
    :goto_9e
    const-string v0, "EV build not installed"

    return-object v0
.end method

.method static digest(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 153
    invoke-static {p0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object p0

    .line 154
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p1}, Ljava/io/FileInputStream;-><init>(Ljava/lang/String;)V

    const/high16 p1, 0x10000

    :try_start_b
    new-array p1, p1, [B

    .line 158
    :goto_d
    invoke-virtual {v0, p1}, Ljava/io/InputStream;->read([B)I

    move-result v1

    const/4 v2, 0x0

    if-lez v1, :cond_18

    invoke-virtual {p0, p1, v2, v1}, Ljava/security/MessageDigest;->update([BII)V
    :try_end_17
    .catchall {:try_start_b .. :try_end_17} :catchall_46

    goto :goto_d

    .line 159
    :cond_18
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    .line 160
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    .line 161
    invoke-virtual {p0}, Ljava/security/MessageDigest;->digest()[B

    move-result-object p0

    array-length v0, p0

    const/4 v1, 0x0

    :goto_26
    if-ge v1, v0, :cond_41

    aget-byte v3, p0, v1

    const/4 v4, 0x1

    new-array v4, v4, [Ljava/lang/Object;

    and-int/lit16 v3, v3, 0xff

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    aput-object v3, v4, v2

    const-string v3, "%02x"

    invoke-static {v3, v4}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    add-int/lit8 v1, v1, 0x1

    goto :goto_26

    .line 162
    :cond_41
    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    :catchall_46
    move-exception p0

    .line 159
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V

    goto :goto_4c

    :goto_4b
    throw p0

    :goto_4c
    goto :goto_4b
.end method

.method private static field(Ljava/lang/String;)Ljava/lang/reflect/Field;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "com.tcc.iap2server.Iap2Service"

    .line 143
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0, p0}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0

    const/4 v0, 0x1

    .line 144
    invoke-virtual {p0, v0}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    return-object p0
.end method

.method static handle()J
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "mHandleIap2"

    .line 141
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->field(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->getLong(Ljava/lang/Object;)J

    move-result-wide v0

    return-wide v0
.end method

.method public static identity()V
    .registers 15

    .line 85
    :try_start_0
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->ready()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 86
    :cond_7
    const-class v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;

    monitor-enter v0
    :try_end_a
    .catchall {:try_start_0 .. :try_end_a} :catchall_d7

    .line 87
    :try_start_a
    sget-boolean v1, Lcom/tcc/iap2server/LeafiaCarPlayEv;->identityArmed:Z

    const/4 v2, 0x1

    if-nez v1, :cond_c2

    .line 88
    new-instance v1, Lorg/json/JSONObject;

    sget-object v3, Lcom/tcc/iap2server/LeafiaCarPlayEv;->profile:Ljava/lang/String;

    invoke-direct {v1, v3}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string v3, "vehicle"

    .line 89
    invoke-virtual {v1, v3}, Lorg/json/JSONObject;->getJSONObject(Ljava/lang/String;)Lorg/json/JSONObject;

    move-result-object v3

    const-string v4, "display_name"

    invoke-virtual {v3, v4}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "connectors"

    .line 91
    invoke-virtual {v1, v4}, Lorg/json/JSONObject;->getJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v1

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v13, 0x0

    const/4 v14, 0x0

    .line 92
    :goto_2c
    invoke-virtual {v1}, Lorg/json/JSONArray;->length()I

    move-result v6

    if-ge v5, v6, :cond_62

    .line 93
    invoke-virtual {v1, v5}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v6

    const-string v7, "ccs1"

    const-string v8, "type"

    .line 94
    invoke-virtual {v6, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_4b

    const-string v7, "maximum_power_w"

    invoke-virtual {v6, v7}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v13

    goto :goto_5f

    :cond_4b
    const-string v7, "j1772"

    const-string v8, "type"

    .line 95
    invoke-virtual {v6, v8}, Lorg/json/JSONObject;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_5f

    const-string v7, "maximum_power_w"

    invoke-virtual {v6, v7}, Lorg/json/JSONObject;->getInt(Ljava/lang/String;)I

    move-result v14

    :cond_5f
    :goto_5f
    add-int/lit8 v5, v5, 0x1

    goto :goto_2c

    .line 97
    :cond_62
    invoke-static {}, Lhmgapi/mods/wireless/NativeIdentity;->load()V

    const-string v1, "UTF-8"

    .line 99
    invoke-virtual {v3, v1}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v6

    const/4 v7, 0x2

    const/4 v8, 0x0

    const/4 v10, 0x2

    new-array v12, v4, [B

    move v9, v13

    move v11, v14

    invoke-static/range {v6 .. v12}, Lhmgapi/mods/wireless/NativeIdentity;->configure([BIIIII[B)I

    move-result v1

    if-eqz v1, :cond_95

    const-string v2, "Leafia"

    .line 100
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "CarPlay EV: identification not armed ("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ")"

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    monitor-exit v0

    return-void

    .line 101
    :cond_95
    sput-boolean v2, Lcom/tcc/iap2server/LeafiaCarPlayEv;->identityArmed:Z

    const-string v1, "Leafia"

    .line 102
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "CarPlay EV: identification armed: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v3, ", DC "

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v13}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, " W, AC "

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v14}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v3, " W"

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v1, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 104
    :cond_c2
    monitor-exit v0
    :try_end_c3
    .catchall {:try_start_a .. :try_end_c3} :catchall_d4

    :try_start_c3
    const-string v0, "com.tcc.iap2server.Iap2InitInformationMsg"

    .line 105
    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    const-string v1, "iAP2UsedVehicelInformation"

    .line 106
    invoke-static {v0, v1, v2}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->set(Ljava/lang/Class;Ljava/lang/String;I)V

    const-string v1, "iAP2UsedVehicleStatus"

    .line 107
    invoke-static {v0, v1, v2}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->set(Ljava/lang/Class;Ljava/lang/String;I)V
    :try_end_d3
    .catchall {:try_start_c3 .. :try_end_d3} :catchall_d7

    goto :goto_eb

    :catchall_d4
    move-exception v1

    .line 104
    :try_start_d5
    monitor-exit v0
    :try_end_d6
    .catchall {:try_start_d5 .. :try_end_d6} :catchall_d4

    :try_start_d6
    throw v1
    :try_end_d7
    .catchall {:try_start_d6 .. :try_end_d7} :catchall_d7

    :catchall_d7
    move-exception v0

    const-string v1, "Leafia"

    .line 109
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "CarPlay EV: identification failed: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_eb
    return-void
.end method

.method static lock()Ljava/lang/Object;
    .registers 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    const-string v0, "mLock"

    .line 140
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->field(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method public static onCreate(Ljava/lang/Object;)V
    .registers 4

    .line 116
    :try_start_0
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->ready()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 117
    :cond_7
    const-class v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;

    monitor-enter v0
    :try_end_a
    .catchall {:try_start_0 .. :try_end_a} :catchall_30

    .line 118
    :try_start_a
    sget-object v1, Lcom/tcc/iap2server/LeafiaCarPlayEv;->provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    if-eqz v1, :cond_10

    monitor-exit v0

    return-void

    .line 119
    :cond_10
    new-instance v1, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    sget-object v2, Lcom/tcc/iap2server/LeafiaCarPlayEv;->profile:Ljava/lang/String;

    invoke-direct {v1, p0, v2}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;-><init>(Ljava/lang/Object;Ljava/lang/String;)V

    .line 120
    sput-object v1, Lcom/tcc/iap2server/LeafiaCarPlayEv;->provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;
    :try_end_19
    .catchall {:try_start_a .. :try_end_19} :catchall_2d

    .line 121
    :try_start_19
    invoke-virtual {v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->start()V
    :try_end_1c
    .catchall {:try_start_19 .. :try_end_1c} :catchall_25

    .line 122
    :try_start_1c
    monitor-exit v0
    :try_end_1d
    .catchall {:try_start_1c .. :try_end_1d} :catchall_2d

    :try_start_1d
    const-string p0, "Leafia"

    const-string v0, "CarPlay EV: listener registered"

    .line 123
    invoke-static {p0, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_24
    .catchall {:try_start_1d .. :try_end_24} :catchall_30

    goto :goto_44

    :catchall_25
    move-exception p0

    const/4 v2, 0x0

    .line 121
    :try_start_27
    sput-object v2, Lcom/tcc/iap2server/LeafiaCarPlayEv;->provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    invoke-virtual {v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->close()V

    throw p0

    :catchall_2d
    move-exception p0

    .line 122
    monitor-exit v0
    :try_end_2f
    .catchall {:try_start_27 .. :try_end_2f} :catchall_2d

    :try_start_2f
    throw p0
    :try_end_30
    .catchall {:try_start_2f .. :try_end_30} :catchall_30

    :catchall_30
    move-exception p0

    const-string v0, "Leafia"

    .line 125
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "CarPlay EV: start failed: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_44
    return-void
.end method

.method public static onDestroy()V
    .registers 4

    .line 132
    :try_start_0
    const-class v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;

    monitor-enter v0
    :try_end_3
    .catchall {:try_start_0 .. :try_end_3} :catchall_12

    .line 133
    :try_start_3
    sget-object v1, Lcom/tcc/iap2server/LeafiaCarPlayEv;->provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    if-eqz v1, :cond_d

    invoke-virtual {v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->close()V

    const/4 v1, 0x0

    sput-object v1, Lcom/tcc/iap2server/LeafiaCarPlayEv;->provider:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    .line 134
    :cond_d
    monitor-exit v0

    goto :goto_26

    :catchall_f
    move-exception v1

    monitor-exit v0
    :try_end_11
    .catchall {:try_start_3 .. :try_end_11} :catchall_f

    :try_start_11
    throw v1
    :try_end_12
    .catchall {:try_start_11 .. :try_end_12} :catchall_12

    :catchall_12
    move-exception v0

    const-string v1, "Leafia"

    .line 136
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "CarPlay EV: stop failed: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_26
    return-void
.end method

.method static declared-synchronized ready()Z
    .registers 6

    const-string v0, "CarPlay EV: on, profile "

    const-string v1, "CarPlay EV: off ("

    const-string v2, "CarPlay EV: off (check failed: "

    const-class v3, Lcom/tcc/iap2server/LeafiaCarPlayEv;

    monitor-enter v3

    .line 52
    :try_start_9
    sget-boolean v4, Lcom/tcc/iap2server/LeafiaCarPlayEv;->checked:Z

    if-eqz v4, :cond_11

    sget-boolean v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->ok:Z
    :try_end_f
    .catchall {:try_start_9 .. :try_end_f} :catchall_64

    monitor-exit v3

    return v0

    :cond_11
    const/4 v4, 0x1

    .line 53
    :try_start_12
    sput-boolean v4, Lcom/tcc/iap2server/LeafiaCarPlayEv;->checked:Z
    :try_end_14
    .catchall {:try_start_12 .. :try_end_14} :catchall_64

    .line 55
    :try_start_14
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->check()Ljava/lang/String;

    move-result-object v5

    if-eqz v5, :cond_33

    const-string v0, "Leafia"

    .line 56
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ")"

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_30
    .catchall {:try_start_14 .. :try_end_30} :catchall_49

    monitor-exit v3

    const/4 v0, 0x0

    return v0

    .line 57
    :cond_33
    :try_start_33
    sput-boolean v4, Lcom/tcc/iap2server/LeafiaCarPlayEv;->ok:Z

    const-string v1, "Leafia"

    .line 58
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    sget-object v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->profileName:Ljava/lang/String;

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_48
    .catchall {:try_start_33 .. :try_end_48} :catchall_49

    goto :goto_60

    :catchall_49
    move-exception v0

    :try_start_4a
    const-string v1, "Leafia"

    .line 60
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v0, ")"

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 62
    :goto_60
    sget-boolean v0, Lcom/tcc/iap2server/LeafiaCarPlayEv;->ok:Z
    :try_end_62
    .catchall {:try_start_4a .. :try_end_62} :catchall_64

    monitor-exit v3

    return v0

    :catchall_64
    move-exception v0

    monitor-exit v3

    throw v0
.end method

.method private static set(Ljava/lang/Class;Ljava/lang/String;I)V
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/String;",
            "I)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 148
    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0

    const/4 p1, 0x1

    .line 149
    invoke-virtual {p0, p1}, Ljava/lang/reflect/Field;->setAccessible(Z)V

    const/4 p1, 0x0

    .line 150
    invoke-virtual {p0, p1, p2}, Ljava/lang/reflect/Field;->setInt(Ljava/lang/Object;I)V

    return-void
.end method
