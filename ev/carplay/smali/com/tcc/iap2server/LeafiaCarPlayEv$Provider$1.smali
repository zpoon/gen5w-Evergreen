.class Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;
.super Lcom/tcc/iap2/IIap2Listener$Stub;
.source "LeafiaCarPlayEv.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;


# direct methods
.method constructor <init>(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V
    .registers 2

    .line 176
    iput-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    invoke-direct {p0}, Lcom/tcc/iap2/IIap2Listener$Stub;-><init>()V

    return-void
.end method


# virtual methods
.method public connected(ILjava/lang/String;)V
    .registers 3

    .line 177
    iget-object p2, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;
    invoke-static {p2}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;

    move-result-object p2

    invoke-virtual {p2, p1}, Lorg/egmp/carplay/ev/app/Subscription;->connected(I)V

    return-void
.end method

.method public disconnected(I)V
    .registers 3

    .line 178
    iget-object v0, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;
    invoke-static {v0}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;

    move-result-object v0

    invoke-virtual {v0, p1}, Lorg/egmp/carplay/ev/app/Subscription;->disconnected(I)Z

    move-result p1

    if-eqz p1, :cond_11

    iget-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # invokes: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->release()V
    invoke-static {p1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$100(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V

    :cond_11
    return-void
.end method

.method public notify(IIILcom/tcc/iap2/Iap2NotiMsg;)V
    .registers 5

    const/16 p2, 0xf

    if-ne p1, p2, :cond_a

    .line 180
    iget-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # invokes: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->begin()V
    invoke-static {p1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$200(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V

    goto :goto_1c

    :cond_a
    const/16 p2, 0x10

    if-ne p1, p2, :cond_1c

    .line 181
    iget-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # getter for: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->subscription:Lorg/egmp/carplay/ev/app/Subscription;
    invoke-static {p1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$000(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)Lorg/egmp/carplay/ev/app/Subscription;

    move-result-object p1

    invoke-virtual {p1}, Lorg/egmp/carplay/ev/app/Subscription;->stop()V

    iget-object p1, p0, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider$1;->this$0:Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;

    # invokes: Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->release()V
    invoke-static {p1}, Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;->access$100(Lcom/tcc/iap2server/LeafiaCarPlayEv$Provider;)V

    :cond_1c
    :goto_1c
    return-void
.end method
