#!/usr/bin/env python3
"""Make universal patches from one car's patch set and its stock files.

A car's patch set rebuilds each modified app from that car's exact stock .odex.
But an .odex is the app's (optimised) dex plus a header with checksums of the
framework it was made against, so cars with the same app code have the same dex
inside different .odex files. A universal patch starts from that dex instead
(`lpatch odexdex`), so it fits every car whose app code is the same, whatever
its framework. The installer uses these for cars that have no patch set of
their own (scripts/universal.sh).

usage: mkuniversal.py <stock dir> <patch set> [--patches DIR]
  <stock dir>  the car's stock tree (a port kit's LEAFIA/private/stock/):
               app/<App>.apk + app/<App>.odex + lib/libautoreceiver_infobank.so
  <patch set>  the set in patches/ the stock files belong to (e.g. neev)

Writes patches/universal/<App>.<part>.<code md5 prefix>.lpd and its line in
patches/universal/manifest:
  <part> app <App> <md5 of the dex inside the stock .odex> universal/<file> <md5 of the result dex>
and copies the set's library lines (the library has no wrapper, so its own patch
already fits every car with that stock library):
  <part> file <library> <md5 of the stock library> <patch> <md5 of the result>
Lines for the same code are replaced, so running it again is safe.
Needs the host lpatch (tools/lpatch/build.sh) and tools/requirements.txt.
"""
import hashlib, os, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LPATCH = os.path.join(HERE, 'lpatch', 'lpatch-host')


def md5(p):
    return hashlib.md5(open(p, 'rb').read()).hexdigest()


def lp(*args):
    r = subprocess.run([LPATCH] + list(args), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if r.returncode != 0:
        sys.exit('lpatch %s failed: %s%s' % (args[0], r.stdout, r.stderr))
    return r.stdout


def main():
    a = [x for x in sys.argv[1:] if not x.startswith('--')]
    patches = os.path.join(ROOT, 'patches')
    if '--patches' in sys.argv:
        patches = sys.argv[sys.argv.index('--patches') + 1]
        a = [x for x in a if x != patches]
    if len(a) != 2:
        sys.exit(__doc__)
    stock, pset = a
    if not os.access(LPATCH, os.X_OK):
        sys.exit('build the host lpatch first: tools/lpatch/build.sh')
    manifest = os.path.join(patches, pset, 'manifest')
    stock_list = dict(l.split() for l in open(os.path.join(patches, pset, 'stock')) if l.strip())
    for f, want in stock_list.items():
        d = 'lib' if f.endswith('.so') else 'app'
        if md5(os.path.join(stock, d, f)) != want:
            sys.exit('%s/%s is not the stock file of patches/%s' % (d, f, pset))
    udir = os.path.join(patches, 'universal')
    os.makedirs(udir, exist_ok=True)
    umf = os.path.join(udir, 'manifest')
    lines = [l.rstrip('\n') for l in open(umf)] if os.path.exists(umf) else []
    new = []
    with tempfile.TemporaryDirectory() as t:
        for l in open(manifest):
            p = l.split()
            if len(p) != 5 or p[0].startswith('#') or p[0].endswith('+ev'):
                continue   # EV builds stay per car: they depend on the car's framework and battery
            part, kind, name, patch, want = p
            if kind == 'file':
                new.append((('file', part, name, stock_list[name]), '%s file %s %s %s %s' % (part, name, stock_list[name], patch, want)))
                continue
            odex = os.path.join(stock, 'app', name + '.odex')
            code = os.path.join(t, name + '.code.dex')
            lp('odexdex', odex, code)
            built = os.path.join(t, '%s.%s.dex' % (name, part))
            lp('delta', os.path.join(patches, patch), odex, built)   # the set's own build of this app
            cm, dm = md5(code), md5(built)
            fname = '%s.%s.%s.lpd' % (name, part.split('_', 1)[1], cm[:8])
            subprocess.run([sys.executable, os.path.join(HERE, 'mkdelta.py'), code, built, os.path.join(udir, fname)],
                           check=True, stdout=subprocess.DEVNULL)
            lp('delta', os.path.join(udir, fname), code, os.path.join(t, 'check.dex'))   # round trip
            new.append((('app', part, name, cm), '%s app %s %s universal/%s %s' % (part, name, cm, fname, dm)))
            print('%s %s: code %s -> universal/%s' % (part, name, cm, fname))
    keys = {k for k, _ in new}
    def key(l):
        p = l.split()
        return (p[1], p[0], p[2], p[3]) if len(p) == 6 else None
    kept = [l for l in lines if l.startswith('#') or not l.strip() or key(l) not in keys]
    if not any(l.startswith('#') for l in kept):
        kept = ['# Universal patches (tools/mkuniversal.py): for cars without a patch set of their own.',
                '# app lines: <part> app <App> <md5 of the dex inside the stock .odex> <patch> <md5 of the result dex>',
                '# file lines: <part> file <library> <md5 of the stock library> <patch> <md5 of the result>',
                '# A car gets the full build only if every app and the library match a line here.'] + kept
    open(umf, 'w').write('\n'.join(kept + [l for _, l in new]) + '\n')
    print('patches/universal/manifest: %d line(s) from %s' % (len(new), pset))


if __name__ == '__main__':
    main()
