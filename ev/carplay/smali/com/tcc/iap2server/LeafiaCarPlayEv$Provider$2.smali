.class Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;
.super Ljava/lang/Object;
.source "LeafiaCarPlayEv.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->begin()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

.field final synthetic val$token:J


# direct methods
.method constructor <init>(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;J)V
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 208
    iput-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    iput-wide p2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->val$token:J

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 8

    .line 211
    :goto_0
    :try_start_0
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;

    move-result-object v0

    iget-wide v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->val$token:J

    invoke-virtual {v0, v1, v2}, Lorg/egmp/carplay/ev/app/Subscription;->current(J)Z

    move-result v0
    :try_end_c
    .catch Ljava/lang/InterruptedException; {:try_start_0 .. :try_end_c} :catch_a4

    if-eqz v0, :cond_ab

    .line 213
    :try_start_e
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->source:Lorg/egmp/carplay/ev/app/VehicleSource;
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$300(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/VehicleSource;

    move-result-object v0

    invoke-virtual {v0}, Lorg/egmp/carplay/ev/app/VehicleSource;->poll()Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;

    move-result-object v0

    .line 214
    iget-object v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->source:Lorg/egmp/carplay/ev/app/VehicleSource;
    invoke-static {v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$300(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/VehicleSource;

    move-result-object v1

    invoke-virtual {v1}, Lorg/egmp/carplay/ev/app/VehicleSource;->takeBatterySelectionEvent()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_3a

    const-string v2, "Leafia"

    .line 215
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "CarPlay EV: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 216
    :cond_3a
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->lock()Ljava/lang/Object;

    move-result-object v1

    monitor-enter v1
    :try_end_3f
    .catchall {:try_start_e .. :try_end_3f} :catchall_71

    .line 217
    :try_start_3f
    iget-object v2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;
    invoke-static {v2}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;

    move-result-object v2

    iget-wide v3, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->val$token:J

    invoke-virtual {v2, v3, v4}, Lorg/egmp/carplay/ev/app/Subscription;->current(J)Z

    move-result v2

    if-nez v2, :cond_4f

    monitor-exit v1

    return-void

    .line 218
    :cond_4f
    invoke-static {}, Lcom/tcc/iap2server/LeafiaCarPlayEv;->handle()J

    move-result-wide v2

    iget-object v4, v0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->values:[I

    iget-object v5, v0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->charging:[B

    iget-object v6, v0, Lorg/egmp/carplay/ev/app/VehicleSource$Snapshot;->consumption:[B

    invoke-static {v2, v3, v4, v5, v6}, Lorg/egmp/carplay/ev/app/NativeBridge;->send(J[I[B[B)I

    move-result v2

    const-string v3, "Leafia"

    .line 219
    # invokes: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->statusLine(ILorg/egmp/carplay/ev/app/VehicleSource$Snapshot;)Ljava/lang/String;
    invoke-static {v2, v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$400(ILorg/egmp/carplay/ev/app/VehicleSource$Snapshot;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v3, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 220
    monitor-exit v1
    :try_end_67
    .catchall {:try_start_3f .. :try_end_67} :catchall_6e

    .line 221
    :try_start_67
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    const/4 v1, 0x0

    # setter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->lastFailure:Ljava/lang/String;
    invoke-static {v0, v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$502(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;Ljava/lang/String;)Ljava/lang/String;
    :try_end_6d
    .catchall {:try_start_67 .. :try_end_6d} :catchall_71

    goto :goto_9d

    :catchall_6e
    move-exception v0

    .line 220
    :try_start_6f
    monitor-exit v1
    :try_end_70
    .catchall {:try_start_6f .. :try_end_70} :catchall_6e

    :try_start_70
    throw v0
    :try_end_71
    .catchall {:try_start_70 .. :try_end_71} :catchall_71

    :catchall_71
    move-exception v0

    .line 223
    :try_start_72
    # invokes: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->message(Ljava/lang/Throwable;)Ljava/lang/String;
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$600(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object v0

    .line 224
    iget-object v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->lastFailure:Ljava/lang/String;
    invoke-static {v1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$500(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_9d

    const-string v1, "Leafia"

    .line 225
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "CarPlay EV: status unavailable, will retry: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 226
    iget-object v1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$2;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # setter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->lastFailure:Ljava/lang/String;
    invoke-static {v1, v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$502(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;Ljava/lang/String;)Ljava/lang/String;

    :cond_9d
    :goto_9d
    const-wide/16 v0, 0x2710

    .line 229
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_end_a2
    .catch Ljava/lang/InterruptedException; {:try_start_72 .. :try_end_a2} :catch_a4

    goto/16 :goto_0

    .line 232
    :catch_a4
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Thread;->interrupt()V

    :cond_ab
    return-void
.end method
