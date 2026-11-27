/* SPDX-License-Identifier: GPL-3.0-or-later
 * Generic owner of the verified libiap2session identification serializer gate.
 * Vehicle and theme facts arrive through the Wireless mod's public Java API.
 */
#include <jni.h>
typedef unsigned int u32;
typedef unsigned short u16;
typedef void *(*Lookup)(u16,u16,u16 *,void *,int *);
typedef u32 (*Builder)(u32,u32,u32,u32,u32,void *,u32,const char *,Lookup);
typedef int (*Mutex)(void *);
typedef struct {u16 used,id,type,pad;u32 init,length,done,children;} Param;
typedef const Param *(*Children)(u16,u16,u16 *,void *,int *);
extern void *dlopen(const char *,int);
extern void *dlsym(void *,const char *);

static const Param *root_table,*info_table,*status_table;
static Lookup root_lookup,info_lookup,status_lookup;
static Builder raw_builder;
static u32 *hook_mailbox;
static int (*protect_page)(void *,u32,int);
static Mutex lock_mutex,unlock_mutex;
static u32 identity_mutex;
static int configured,has_vehicle,has_theme;
static char display_name[321];
static char theme[97];
static u32 dc_w,ac_w,engine=2,connector,dc_connector,ac_connector;
static Param info_copy[9],status_copy[15];
#define WIRELESS_GROUP 24
#define WIRELESS_MAX 8
static Children stock_children;
static Lookup wireless_lookup;
static Param wireless_copy[WIRELESS_MAX+2];

static void copy(char *d,const char *s,u32 n){while(n--)*d++=*s++;}
static int string_ok(const char *s,u32 n){if(!s || !n)return 0;for(u32 i=0;i<n;i++)if(!s[i])return 0;return 1;}
static int set_handler(u32 value){
    if(!hook_mailbox || !protect_page)return -18;
    void *page=(void*)((u32)hook_mailbox&~4095U);
    if(protect_page(page,4096,7))return -19;
    __atomic_store_n(hook_mailbox,value,__ATOMIC_RELEASE);
    if(protect_page(page,4096,5)){
        __atomic_store_n(hook_mailbox,0,__ATOMIC_RELEASE);protect_page(page,4096,5);return -19;
    }
    return 0;
}
static void connector_dc(u16 a,u16 b,u32 c,void *d){(void)a;(void)b;(void)c;(void)d;connector=dc_connector;}
static void connector_ac(u16 a,u16 b,u32 c,void *d){(void)a;(void)b;(void)c;(void)d;connector=ac_connector;}
static void *info_value(u16 id,u16 type,u16 *n,void *key,int *more){
    if(more)*more=0;
    if(id==2)return &engine;
    if(id==6 || id==8)return display_name;
    if(id==11)return &connector;
    if(id==12)return &dc_w;
    if(id==14)return &ac_w;
    return info_lookup(id,type,n,key,more);
}
static void *status_value(u16 id,u16 type,u16 *n,void *key,int *more){return status_lookup(id,type,n,key,more);}
static void *wireless_value(u16 id,u16 type,u16 *n,void *key,int *more){
    if(id==5 || id==6){if(more)*more=0;return theme;}
    return wireless_lookup(id,type,n,key,more);
}
static Param parameter(u16 id,u16 type);
static const Param *identity_children(u16 id,u16 type,u16 *count,void *key,int *more){
    (void)type;(void)key;if(more)*more=0;
    if(id==20){*count=9;return info_copy;}
    if(id==21){*count=15;return status_copy;}
    if(id==WIRELESS_GROUP && stock_children){
        u32 n=0;const Param *stock=stock_children(id,type,(u16*)&n,key,more);
        if(!stock || n>WIRELESS_MAX){*count=(u16)n;return stock;}
        for(u32 i=0;i<n;i++)wireless_copy[i]=stock[i];
        wireless_copy[n]=parameter(5,12);wireless_copy[n+1]=parameter(6,10);
        *count=(u16)(n+2);if(more)*more=0;return wireless_copy;
    }
    return 0;
}
static void *identity_value(u16 id,u16 type,u16 *n,void *key,int *more){
    if(id==20){if(more)*more=0;return (void*)info_value;}
    if(id==21){if(more)*more=0;return (void*)status_value;}
    if(id==WIRELESS_GROUP && has_theme && wireless_lookup){if(more)*more=0;return (void*)wireless_value;}
    return root_lookup(id,type,n,key,more);
}
static Param parameter(u16 id,u16 type){Param p={1,id,type,0,0,0,0,0};return p;}
static u32 identity_builder(u32 handle,u32 session,u32 a,u32 b,u32 command,void *table,u32 count,const char *name,Lookup lookup){
    if(!__atomic_load_n(&configured,__ATOMIC_ACQUIRE) || command!=0x1d01 || table!=root_table || count!=24)
        return raw_builder(handle,session,a,b,command,table,count,name,lookup);
    if(lock_mutex(&identity_mutex))return 0;
    Param root[24];for(u32 i=0;i<24;i++){
        root[i]=root_table[i];
        if(has_vehicle && (root[i].id==20 || root[i].id==21)){root[i].used=1;root[i].children=(u32)identity_children;}
        else if(has_theme && root[i].id==WIRELESS_GROUP && wireless_lookup && root[i].children){
            stock_children=(Children)root[i].children;root[i].children=(u32)identity_children;
        }
    }
    u32 result=raw_builder(handle,session,a,b,command,root,24,name,identity_value);
    unlock_mutex(&identity_mutex);return result;
}
static Builder recipe_original(Builder entry){
    if(!entry)return 0;u16 *p=(u16*)((u32)entry&~1U);
    if((p[0]&0xf800)!=0xf000 || (p[1]&0xd000)!=0x9000)return 0;
    u32 s=(p[0]>>10)&1,j1=(p[1]>>13)&1,j2=(p[1]>>11)&1;
    u32 bits=(s<<24)|((!(j1^s))<<23)|((!(j2^s))<<22)|((p[0]&1023)<<12)|((p[1]&2047)<<1);
    int delta=(int)(bits<<7)>>7;char *gate=(char*)p+4+delta;u32 *header=(u32*)(gate+16);
    if(header[0]!=0x45564731 || header[1]!=1 || header[2]<32 || header[2]>128 || header[3]!=0)return 0;
    hook_mailbox=&header[3];return (Builder)((u32)(gate+header[2])|1);
}
static int bind(void){
    void *lib=dlopen("/system/lib/libiap2session.so",2),*c=dlopen("/system/lib/libc.so",2);
    if(!lib || !c)return -10;
    protect_page=dlsym(c,"mprotect");lock_mutex=dlsym(c,"pthread_mutex_lock");unlock_mutex=dlsym(c,"pthread_mutex_unlock");
    raw_builder=recipe_original(dlsym(lib,"iAP2SessionPacketMakePacketUsingParamListNew"));
    root_table=dlsym(lib,"iAP2IdenInfoMsgList");root_lookup=dlsym(lib,"_Z26iAP2ControlIden_GetPointerttPtPvPi");
    info_lookup=dlsym(lib,"_Z41iAP2ControlIden_VehicleInfoIdenGetPointerttPtPvPi");
    status_lookup=dlsym(lib,"iAP2ControlIden_VehicleStatusGetPointer");
    wireless_lookup=dlsym(lib,"iAP2ControlIden_WirelessGetPointer");
    const Param *(*get_info)(u32*)=dlsym(lib,"iAP2ControlIden_GetVehicleInfoParamList");
    const Param *(*get_status)(u32*)=dlsym(lib,"iAP2ControlIden_GetVehicleStatusParamList");
    if(!protect_page || !lock_mutex || !unlock_mutex)return -20;
    if(!raw_builder)return -21;
    if(!root_table || !root_lookup)return -22;
    if(!info_lookup || !get_info)return -23;
    if(!status_lookup || !get_status)return -24;
    u32 n=0;info_table=get_info(&n);if(n!=5 || !info_table)return -25;
    status_table=get_status(&n);if(n!=13 || !status_table)return -26;
    return 0;
}
static int configure(const char *name,u32 len,int engine_type,int dc_type,u32 dc,int ac_type,u32 ac,const char *theme_id,u32 theme_len){
    if(!hook_mailbox){int rc=bind();if(rc)return rc;}
    int vehicle=len!=0,themed=theme_len!=0;
    if(!vehicle && !themed)return -12;
    if(vehicle && (!string_ok(name,len) || len>320 || engine_type<0 || engine_type>3 || dc_type<0 || dc_type>1 || ac_type!=2
            || !dc || dc>1000000 || !ac || ac>1000000))return -12;
    if(themed){
        if(!wireless_lookup || !string_ok(theme_id,theme_len) || theme_len>96)return wireless_lookup?-12:-18;
        for(u32 i=0;i<theme_len;i++)if(theme_id[i]<0x21 || theme_id[i]>0x7e)return -12;
    }
    if(lock_mutex(&identity_mutex))return -15;
    has_vehicle=vehicle;has_theme=themed;
    copy(theme,theme_id,theme_len);theme[theme_len]=0;
    if(vehicle){
        copy(display_name,name,len);display_name[len]=0;engine=(u32)engine_type;dc_connector=(u32)dc_type;ac_connector=(u32)ac_type;dc_w=dc;ac_w=ac;
        for(u32 i=0;i<5;i++){
            info_copy[i]=info_table[i];
            if(info_copy[i].id==2 || info_copy[i].id==6 || info_copy[i].id==8){info_copy[i].used=1;info_copy[i].init=info_copy[i].length=info_copy[i].done=0;}
        }
        info_copy[5]=parameter(11,8);info_copy[5].init=(u32)connector_dc;
        info_copy[6]=parameter(11,8);info_copy[6].init=(u32)connector_ac;
        info_copy[7]=parameter(12,6);info_copy[8]=parameter(14,6);
        for(u32 i=0;i<13;i++){status_copy[i]=status_table[i];u16 id=status_copy[i].id;if(id==3 || id==6 || id==11 || id==15)status_copy[i].used=1;}
        status_copy[13]=parameter(21,12);status_copy[14]=parameter(30,12);
    }
    __atomic_store_n(&configured,1,__ATOMIC_RELEASE);int result=set_handler((u32)identity_builder);
    if(result)__atomic_store_n(&configured,0,__ATOMIC_RELEASE);
    unlock_mutex(&identity_mutex);return result;
}

JNIEXPORT jint JNICALL Java_hmgapi_mods_wireless_NativeIdentity_configure(JNIEnv *env,jclass cls,jbyteArray name,jint engine_type,jint dc_type,jint dc,jint ac_type,jint ac,jbyteArray theme_id){
    (void)cls;if(!name || !theme_id)return -12;jsize n=(*env)->GetArrayLength(env,name),t=(*env)->GetArrayLength(env,theme_id);
    if(n>320 || t>96)return -12;char bytes[321],theme_bytes[97];
    if(n)(*env)->GetByteArrayRegion(env,name,0,n,(jbyte*)bytes);
    if(t)(*env)->GetByteArrayRegion(env,theme_id,0,t,(jbyte*)theme_bytes);
    if((*env)->ExceptionCheck(env))return -12;
    return configure(bytes,(u32)n,engine_type,dc_type,(u32)dc,ac_type,(u32)ac,theme_bytes,(u32)t);
}
JNIEXPORT void JNICALL Java_hmgapi_mods_wireless_NativeIdentity_shutdown(JNIEnv *env,jclass cls){
    (void)env;(void)cls;__atomic_store_n(&configured,0,__ATOMIC_RELEASE);if(hook_mailbox)set_handler(0);
}
void __aeabi_memclr(void *dest,u32 n){volatile unsigned char *p=dest;while(n--)*p++=0;}
_Static_assert(sizeof(void*)==4,"HU ABI is ARM32");
_Static_assert(sizeof(Param)==24,"native table ABI");
