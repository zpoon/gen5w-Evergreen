.class final Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;
.super Ljava/lang/Object;
.source "LeafiaCarPlayEv.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/tcc/iap2server/LeafiaCarPlayEv;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Provider"
.end annotation


# instance fields
.field private binder:Lcom/tcc/iap2/IIap2Service;

.field private closed:Z

.field private lastFailure:Ljava/lang/String;

.field private final listener:Lcom/tcc/iap2/IIap2Listener;

.field private final service:Ljava/lang/Object;

.field private final source:Lorg/egmp/carplay/ev/app/VehicleSource;

.field private final subscription:Lorg/egmp/carplay/ev/app/Subscription;

.field private worker:Ljava/lang/Thread;

.field private workerToken:J


# direct methods
.method constructor <init>(Ljava/lang/Object;Ljava/lang/String;)V
    .registers 5
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 185
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 170
    new-instance v0, Lorg/egmp/carplay/ev/app/Subscription;

    invoke-direct {v0}, Lorg/egmp/carplay/ev/app/Subscription;-><init>()V

    iput-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;

    .line 176
    new-instance v0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;

    invoke-direct {v0, p0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;-><init>(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V

    iput-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->listener:Lcom/tcc/iap2/IIap2Listener;

    .line 186
    iput-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->service:Ljava/lang/Object;

    .line 187
    new-instance v0, Lorg/egmp/carplay/ev/app/VehicleSource;

    const/4 v1, 0x0

    invoke-direct {v0, p1, p2, v1}, Lorg/egmp/carplay/ev/app/VehicleSource;-><init>(Ljava/lang/Object;Ljava/lang/String;I)V

    iput-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->source:Lorg/egmp/carplay/ev/app/VehicleSource;

    return-void
.end method

.method static synthetic access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;
    .registers 1

    .line 167
    iget-object p0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;

    return-object p0
.end method

.method static synthetic access$100(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V
    .registers 1

    .line 167
    invoke-direct {p0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->release()V

    return-void
.end method

.method static synthetic access$200(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V
    .registers 1

    .line 167
    invoke-direct {p0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->begin()V

    return-void
.end method

.method static synthetic access$300(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/VehicleSource;
    .registers 1

    .line 167
    iget-object p0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->source:Lorg/egmp/carplay/ev/app/VehicleSource;

    return-object p0
.end method

.method static synthetic access$400(ILorg/egmp/carplay/ev/app/VehicleSource$Snapshot;)Ljava/lang/String;
    .registers 2

    .line 167
    invoke-static {p0, p1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->statusLine(ILorg/egmp/carplay/ev/app/VehicleSource$Snapshot;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static synthetic access$500(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Ljava/lang/String;
    .registers 1

    .line 167
    iget-object p0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->lastFailure:Ljava/lang/String;

    return-object p0
.end method

.method static synthetic access$502(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;Ljava/lang/String;)Ljava/lang/String;
    .registers 2

    .line 167
    iput-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->lastFailure:Ljava/lang/String;

    return-object p1
.end method

.method static synthetic access$600(Ljava/lang/Throwable;)Ljava/lang/String;
    .registers 1

    .line 167
    invoke-static {p0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->message(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private declared-synchronized begin()V
    .registers 6

    monitor-enter p0

    .line 203
    :try_start_1
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;

    invoke-virtual {v0}, Lorg/egmp/carplay/ev/app/Subscription;->start()J

    move-result-wide v0
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_43

    const-wide/16 v2, 0x0

    cmp-long v4, v0, v2

    if-nez v4, :cond_f

    .line 204
    monitor-exit p0

    return-void

    .line 205
    :cond_f
    :try_start_f
    iget-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->worker:Ljava/lang/Thread;

    if-eqz v2, :cond_21

    invoke-virtual {v2}, Ljava/lang/Thread;->isAlive()Z

    move-result v2

    if-eqz v2, :cond_21

    iget-wide v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->workerToken:J
    :try_end_1b
    .catchall {:try_start_f .. :try_end_1b} :catchall_43

    cmp-long v4, v2, v0

    if-nez v4, :cond_21

    monitor-exit p0

    return-void

    .line 206
    :cond_21
    :try_start_21
    iget-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->worker:Ljava/lang/Thread;

    if-eqz v2, :cond_28

    invoke-virtual {v2}, Ljava/lang/Thread;->interrupt()V

    .line 207
    :cond_28
    iput-wide v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->workerToken:J

    .line 208
    new-instance v2, Ljava/lang/Thread;

    new-instance v3, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;

    invoke-direct {v3, p0, v0, v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;-><init>(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;J)V

    const-string v0, "LeafiaCarPlayEv"

    invoke-direct {v2, v3, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    iput-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->worker:Ljava/lang/Thread;

    const/4 v0, 0x1

    .line 236
    invoke-virtual {v2, v0}, Ljava/lang/Thread;->setDaemon(Z)V

    .line 237
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->worker:Ljava/lang/Thread;

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V
    :try_end_41
    .catchall {:try_start_21 .. :try_end_41} :catchall_43

    .line 238
    monitor-exit p0

    return-void

    :catchall_43
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method private static message(Ljava/lang/Throwable;)Ljava/lang/String;
    .registers 2

    .line 242
    :goto_0
    invoke-virtual {p0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v0

    if-eqz v0, :cond_11

    invoke-virtual {p0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object v0

    if-eq v0, p0, :cond_11

    invoke-virtual {p0}, Ljava/lang/Throwable;->getCause()Ljava/lang/Throwable;

    move-result-object p0

    goto :goto_0

    .line 243
    :cond_11
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object v0

    if-nez v0, :cond_20

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object p0

    goto :goto_24

    :cond_20
    invoke-virtual {p0}, Ljava/lang/Throwable;->getMessage()Ljava/lang/String;

    move-result-object p0

    :goto_24
    return-object p0
.end method

.method private release()V
    .registers 5

    .line 257
    :try_start_0
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->lock()Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0
    :try_end_5
    .catchall {:try_start_0 .. :try_end_5} :catchall_d

    :try_start_5
    invoke-static {}, Lorg/egmp/carplay/ev/app/NativeBridge;->reset()V

    monitor-exit v0

    goto :goto_21

    :catchall_a
    move-exception v1

    monitor-exit v0
    :try_end_c
    .catchall {:try_start_5 .. :try_end_c} :catchall_a

    :try_start_c
    throw v1
    :try_end_d
    .catchall {:try_start_c .. :try_end_d} :catchall_d

    :catchall_d
    move-exception v0

    const-string v1, "Leafia"

    .line 258
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "CarPlay EV: release: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :goto_21
    return-void
.end method

.method private static statusLine(ILorg/egmp/carplay/ev/app/VehicleSource$Snapshot;)Ljava/lang/String;
    .registers 9

    .line 248
    iget-object v0, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 v1, 0x7

    aget v0, v0, v1

    const/4 v1, 0x1

    if-ne v0, v1, :cond_3d

    .line 249
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v2, "soc "

    invoke-direct {v0, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v2, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 v3, 0x3

    aget v2, v2, v3

    div-int/lit16 v2, v2, 0x3e8

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, "% range "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 v3, 0x4

    aget v2, v2, v3

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " km energy "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v2, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 v3, 0x2

    aget v2, v2, v3

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, " Wh"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto :goto_3f

    :cond_3d
    const-string v0, "soc/range unavailable"

    .line 251
    :goto_3f
    iget-object v2, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/16 v3, 0x8

    aget v2, v2, v3

    const-string v3, ""

    if-ne v2, v1, :cond_62

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v4, " full range "

    invoke-direct {v2, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v4, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 v5, 0x6

    aget v4, v4, v5

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, " km"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    goto :goto_63

    :cond_62
    move-object v2, v3

    .line 252
    :goto_63
    new-instance v4, Ljava/lang/StringBuilder;

    const-string v5, "CarPlay EV: status sent ("

    invoke-direct {v4, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p0, "): "

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, ", auxiliary "

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-wide v5, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->auxiliaryW:D

    invoke-virtual {v4, v5, v6}, Ljava/lang/StringBuilder;->append(D)Ljava/lang/StringBuilder;

    const-string p0, " W ("

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p0, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->auxiliarySource:Ljava/lang/String;

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, ")"

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 253
    iget-object p0, p1, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    const/4 p1, 0x5

    aget p0, p0, p1

    if-ne p0, v1, :cond_9a

    const-string v3, ", low battery"

    :cond_9a
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method declared-synchronized close()V
    .registers 5

    monitor-enter p0

    .line 262
    :try_start_1
    iget-boolean v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->closed:Z
    :try_end_3
    .catchall {:try_start_1 .. :try_end_3} :catchall_60

    if-eqz v0, :cond_7

    monitor-exit p0

    return-void

    :cond_7
    const/4 v0, 0x1

    .line 263
    :try_start_8
    iput-boolean v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->closed:Z

    .line 264
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;

    invoke-virtual {v0}, Lorg/egmp/carplay/ev/app/Subscription;->close()V

    .line 265
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->worker:Ljava/lang/Thread;

    if-eqz v0, :cond_16

    invoke-virtual {v0}, Ljava/lang/Thread;->interrupt()V

    .line 266
    :cond_16
    invoke-direct {p0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->release()V
    :try_end_19
    .catchall {:try_start_8 .. :try_end_19} :catchall_60

    .line 267
    :try_start_19
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->lock()Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0
    :try_end_1e
    .catchall {:try_start_19 .. :try_end_1e} :catchall_26

    :try_start_1e
    invoke-static {}, Lorg/egmp/carplay/ev/app/NativeBridge;->shutdown()V

    monitor-exit v0

    goto :goto_3d

    :catchall_23
    move-exception v1

    monitor-exit v0
    :try_end_25
    .catchall {:try_start_1e .. :try_end_25} :catchall_23

    :try_start_25
    throw v1
    :try_end_26
    .catchall {:try_start_25 .. :try_end_26} :catchall_26

    :catchall_26
    move-exception v0

    :try_start_27
    const-string v1, "Leafia"

    .line 268
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "CarPlay EV: native shutdown: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 269
    :goto_3d
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->binder:Lcom/tcc/iap2/IIap2Service;
    :try_end_3f
    .catchall {:try_start_27 .. :try_end_3f} :catchall_60

    if-eqz v0, :cond_5e

    .line 270
    :try_start_41
    iget-object v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->listener:Lcom/tcc/iap2/IIap2Listener;

    invoke-interface {v0, v1}, Lcom/tcc/iap2/IIap2Service;->Iap2SvcStopMain(Lcom/tcc/iap2/IIap2Listener;)Z
    :try_end_46
    .catchall {:try_start_41 .. :try_end_46} :catchall_47

    goto :goto_5e

    :catchall_47
    move-exception v0

    :try_start_48
    const-string v1, "Leafia"

    .line 271
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "CarPlay EV: listener unregister: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_5e
    .catchall {:try_start_48 .. :try_end_5e} :catchall_60

    .line 273
    :cond_5e
    :goto_5e
    monitor-exit p0

    return-void

    :catchall_60
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method start()V
    .registers 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Throwable;
        }
    .end annotation

    const-string v0, "/system/lib/libcarplayev.so"

    .line 191
    invoke-static {v0}, Lorg/egmp/carplay/ev/app/NativeBridge;->load(Ljava/lang/String;)V

    .line 192
    invoke-static {}, Lorg/egmp/carplay/ev/app/NativeBridge;->open()I

    move-result v0

    if-nez v0, :cond_58

    .line 194
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->service:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    const/4 v1, 0x1

    new-array v2, v1, [Ljava/lang/Class;

    const-class v3, Landroid/content/Intent;

    const/4 v4, 0x0

    aput-object v3, v2, v4

    const-string v3, "onBind"

    invoke-virtual {v0, v3, v2}, Ljava/lang/Class;->getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    move-result-object v0

    iget-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->service:Ljava/lang/Object;

    new-array v1, v1, [Ljava/lang/Object;

    new-instance v3, Landroid/content/Intent;

    invoke-direct {v3}, Landroid/content/Intent;-><init>()V

    aput-object v3, v1, v4

    invoke-virtual {v0, v2, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 195
    check-cast v0, Landroid/os/IBinder;

    invoke-static {v0}, Lcom/tcc/iap2/IIap2Service$Stub;->asInterface(Landroid/os/IBinder;)Lcom/tcc/iap2/IIap2Service;

    move-result-object v0

    iput-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->binder:Lcom/tcc/iap2/IIap2Service;

    .line 196
    new-instance v0, Lcom/tcc/iap2/Iap2ListenerInfo;

    invoke-direct {v0}, Lcom/tcc/iap2/Iap2ListenerInfo;-><init>()V

    const-string v1, "CarPlayEV"

    .line 197
    invoke-virtual {v0, v1}, Lcom/tcc/iap2/Iap2ListenerInfo;->onSetListenerName(Ljava/lang/String;)V

    const/16 v1, 0x100

    .line 198
    invoke-virtual {v0, v1}, Lcom/tcc/iap2/Iap2ListenerInfo;->onSetSupportType(I)V

    .line 199
    iget-object v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->binder:Lcom/tcc/iap2/IIap2Service;

    iget-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->listener:Lcom/tcc/iap2/IIap2Listener;

    invoke-interface {v1, v2, v0}, Lcom/tcc/iap2/IIap2Service;->Iap2SvcInit(Lcom/tcc/iap2/IIap2Listener;Lcom/tcc/iap2/Iap2ListenerInfo;)Z

    move-result v0

    if-eqz v0, :cond_50

    return-void

    :cond_50
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "listener refused"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 193
    :cond_58
    new-instance v1, Ljava/lang/IllegalStateException;

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "native open="

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1
.end method
