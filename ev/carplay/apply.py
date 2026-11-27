#!/usr/bin/env python3
"""apply.py <Iap2ServerApp smali dir>: add CarPlay EV routing to an Iap2ServerApp build.

Copies ev/carplay/smali/ (build-java.sh) into the tree and adds three calls:
  Iap2Service.onCreate()          before its return-void:  LeafiaCarPlayEv.onCreate(this)
  Iap2Service.onDestroy()         first:                   LeafiaCarPlayEv.onDestroy()
  Iap2InitInformationMsg.checkSupportsFeatures()  before its return-void:  LeafiaCarPlayEv.identity()
LeafiaCarPlayEv does nothing unless the EV build is installed (libcarplayev.so,
libcarplayidentity.so, the gated libiap2session.so) on a checked framework.
Iap2ServerApp isn't obfuscated, so the names are the stock ones. Already applied: says so, exit 0.
"""
import os, re, shutil, sys

HERE = os.path.dirname(os.path.abspath(__file__))
E = 'Lcom/tcc/iap2server/LeafiaCarPlayEv;'


def method(s, sig):
    m = re.search(r'^\.method %s\n.*?^\.end method\n' % re.escape(sig), s, re.S | re.M)
    if not m:
        sys.exit('apply: method %s not found' % sig)
    return m


def before_returns(s, sig, call):
    m = method(s, sig)
    body = m.group(0)
    n = body.count('\n    return-void\n')
    if n != 1:
        sys.exit('apply: %s has %d return-void, expected 1' % (sig, n))
    nb = body.replace('\n    return-void\n', '\n    %s\n\n    return-void\n' % call)
    return s[:m.start()] + nb + s[m.end():]


def first(s, sig, call):
    m = method(s, sig)
    body = m.group(0)
    r = re.search(r'^    \.registers \d+\n', body, re.M)
    if not r:
        sys.exit('apply: %s has no .registers' % sig)
    nb = body[:r.end()] + '\n    %s\n' % call + body[r.end():]
    return s[:m.start()] + nb + s[m.end():]


def main():
    root = sys.argv[1]
    svc = os.path.join(root, 'com/tcc/iap2server/Iap2Service.smali')
    msg = os.path.join(root, 'com/tcc/iap2server/Iap2InitInformationMsg.smali')
    s = open(svc).read()
    if E in s:
        print('apply: already')
        return
    src = os.path.join(HERE, 'smali')
    for dp, _, fs in os.walk(src):
        for f in fs:
            rel = os.path.relpath(os.path.join(dp, f), src)
            dst = os.path.join(root, rel)
            if os.path.exists(dst):
                sys.exit('apply: %s is already in the tree' % rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copyfile(os.path.join(dp, f), dst)
    s = before_returns(s, 'public onCreate()V', 'invoke-static {p0}, %s->onCreate(Ljava/lang/Object;)V' % E)
    s = first(s, 'public onDestroy()V', 'invoke-static {}, %s->onDestroy()V' % E)
    open(svc, 'w').write(s)
    m = open(msg).read()
    m = before_returns(m, 'public checkSupportsFeatures()V', 'invoke-static {}, %s->identity()V' % E)
    open(msg, 'w').write(m)
    print('apply: CarPlay EV added')


if __name__ == '__main__':
    main()
