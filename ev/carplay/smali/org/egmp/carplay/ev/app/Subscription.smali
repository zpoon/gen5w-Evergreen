.class public final Lorg/egmp/carplay/ev/app/Subscription;
.super Ljava/lang/Object;
.source "Subscription.java"


# instance fields
.field private active:Z

.field private closed:Z

.field private component:I

.field private epoch:J


# direct methods
.method public constructor <init>()V
    .registers 1

    .line 4
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public declared-synchronized close()V
    .registers 2

    monitor-enter p0

    const/4 v0, 0x1

    .line 18
    :try_start_2
    iput-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->closed:Z

    invoke-virtual {p0}, Lorg/egmp/carplay/ev/app/Subscription;->stop()V
    :try_end_7
    .catchall {:try_start_2 .. :try_end_7} :catchall_9

    monitor-exit p0

    return-void

    :catchall_9
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized connected(I)V
    .registers 6

    monitor-enter p0

    .line 9
    :try_start_1
    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->closed:Z
    :try_end_3
    .catchall {:try_start_1 .. :try_end_3} :catchall_19

    if-eqz v0, :cond_7

    monitor-exit p0

    return-void

    .line 10
    :cond_7
    :try_start_7
    iget v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->component:I

    if-eq v0, p1, :cond_17

    const/4 v0, 0x0

    iput-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->active:Z

    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J

    const-wide/16 v2, 0x1

    add-long/2addr v0, v2

    iput-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J

    iput p1, p0, Lorg/egmp/carplay/ev/app/Subscription;->component:I
    :try_end_17
    .catchall {:try_start_7 .. :try_end_17} :catchall_19

    .line 11
    :cond_17
    monitor-exit p0

    return-void

    :catchall_19
    move-exception p1

    monitor-exit p0

    throw p1
.end method

.method public declared-synchronized current(J)Z
    .registers 6

    monitor-enter p0

    const-wide/16 v0, 0x0

    cmp-long v2, p1, v0

    if-eqz v2, :cond_1a

    .line 19
    :try_start_7
    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->active:Z

    if-eqz v0, :cond_1a

    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->closed:Z

    if-nez v0, :cond_1a

    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J
    :try_end_11
    .catchall {:try_start_7 .. :try_end_11} :catchall_17

    cmp-long v2, p1, v0

    if-nez v2, :cond_1a

    const/4 p1, 0x1

    goto :goto_1b

    :catchall_17
    move-exception p1

    monitor-exit p0

    throw p1

    :cond_1a
    const/4 p1, 0x0

    :goto_1b
    monitor-exit p0

    return p1
.end method

.method public declared-synchronized disconnected(I)Z
    .registers 4

    monitor-enter p0

    .line 15
    :try_start_1
    iget v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->component:I
    :try_end_3
    .catchall {:try_start_1 .. :try_end_3} :catchall_12

    const/4 v1, 0x0

    if-eqz v0, :cond_a

    if-eq p1, v0, :cond_a

    monitor-exit p0

    return v1

    .line 16
    :cond_a
    :try_start_a
    iput v1, p0, Lorg/egmp/carplay/ev/app/Subscription;->component:I

    invoke-virtual {p0}, Lorg/egmp/carplay/ev/app/Subscription;->stop()V
    :try_end_f
    .catchall {:try_start_a .. :try_end_f} :catchall_12

    monitor-exit p0

    const/4 p1, 0x1

    return p1

    :catchall_12
    move-exception p1

    monitor-exit p0

    throw p1
.end method

.method public declared-synchronized start()J
    .registers 5

    monitor-enter p0

    .line 12
    :try_start_1
    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->closed:Z
    :try_end_3
    .catchall {:try_start_1 .. :try_end_3} :catchall_1b

    if-eqz v0, :cond_9

    monitor-exit p0

    const-wide/16 v0, 0x0

    return-wide v0

    :cond_9
    :try_start_9
    iget-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->active:Z

    if-nez v0, :cond_17

    const/4 v0, 0x1

    iput-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->active:Z

    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J

    const-wide/16 v2, 0x1

    add-long/2addr v0, v2

    iput-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J

    :cond_17
    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J
    :try_end_19
    .catchall {:try_start_9 .. :try_end_19} :catchall_1b

    monitor-exit p0

    return-wide v0

    :catchall_1b
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public declared-synchronized stop()V
    .registers 5

    monitor-enter p0

    const/4 v0, 0x0

    .line 13
    :try_start_2
    iput-boolean v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->active:Z

    iget-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J

    const-wide/16 v2, 0x1

    add-long/2addr v0, v2

    iput-wide v0, p0, Lorg/egmp/carplay/ev/app/Subscription;->epoch:J
    :try_end_b
    .catchall {:try_start_2 .. :try_end_b} :catchall_d

    monitor-exit p0

    return-void

    :catchall_d
    move-exception v0

    monitor-exit p0

    throw v0
.end method
