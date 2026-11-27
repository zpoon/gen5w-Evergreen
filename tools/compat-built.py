#!/usr/bin/env python3
"""Keep docs/data/compat.json's "built" lists in step with the patch sets.

usage: compat-built.py [--check]

For each car on the compatibility page, "built" lists the md5 of every file our
package installs on it (from patches/<set>/manifest and patches/common/optional;
"code" lines are left out, as their result APK depends on the car's own stock APK),
so the page can tell a unit that already runs Leafia from one with unknown files.
The cars table (patches/cars) maps the car's product prefix to its patch set.
With --check nothing is written; it exits 1 if compat.json is out of date (CI).
At a release: compat-built.py --release v<package-version> (adds it to released.json).
"""
import json, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
COMPAT = os.path.join(ROOT, 'docs', 'data', 'compat.json')
PATCHES = os.path.join(ROOT, 'patches')


def manifest_lines(path):
    if not os.path.exists(path):
        return []
    out = []
    for l in open(path):
        p = l.split()
        if len(p) == 5 and not p[0].startswith('#'):
            out.append(p)
    return out


def built_for(patch_set):
    built = {}
    lines = manifest_lines(os.path.join(PATCHES, patch_set, 'manifest'))
    lines += manifest_lines(os.path.join(PATCHES, 'common', 'optional'))
    for part, kind, name, _patch, md5 in lines:
        if kind == 'code':
            # built from the car's own .odex: the md5 is of the dex, not of the APK
            # the car ends up with (that depends on its stock APK)
            continue
        f = '/system/app/%s.apk' % name if kind == 'app' else '/system/lib/%s' % name
        if md5 not in built.setdefault(f, []):
            built[f].append(md5)
    return {f: sorted(v) for f, v in sorted(built.items())}


def universal():
    path = os.path.join(PATCHES, 'universal', 'manifest')
    if not os.path.exists(path):
        return {}
    apps, files = {}, {}
    for l in open(path):
        p = l.split()
        if len(p) != 6 or p[0].startswith('#'):
            continue
        part, kind, name, code = p[:4]
        if kind == 'app':
            key = '/system/app/%s.odex' % name
            apps.setdefault(key, set()).add(code)
        else:
            files.setdefault('/system/lib/%s' % name, set()).add(code)
    return {'code': {k: sorted(v) for k, v in sorted(apps.items())},
            'files': {k: sorted(v) for k, v in sorted(files.items())}}


# ---- builds from releases: docs/data/released.json ----
# The page counts a file as ours if it is on "built" (what this commit installs) or
# on the car's released.json list (what any tagged release installed on it), so a
# car that hasn't updated yet isn't told it needs a build. Written only by
# --release <tag>, from that tag's own cars table and manifests (git show); normal
# runs and --check never touch it, so CI needs no tags.
RELEASED = os.path.join(ROOT, 'docs', 'data', 'released.json')


def git_show(tag, path):
    import subprocess
    r = subprocess.run(['git', '-C', ROOT, 'show', '%s:%s' % (tag, path)],
                       capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else ''


def tag_lines(tag, path):
    return [p for p in (l.split() for l in git_show(tag, path).splitlines())
            if len(p) == 5 and not p[0].startswith('#')]


def released_for(tag, patch_set):
    """{file: [md5...]} our package installed on a car of <patch_set> in <tag>"""
    out = {}
    lines = tag_lines(tag, 'patches/%s/manifest' % patch_set) + tag_lines(tag, 'patches/common/optional')
    for _part, kind, name, _patch, md5 in lines:
        if kind not in ('app', 'file'):
            continue  # "code" lines: the result depends on the car's own stock APK
        f = '/system/app/%s.apk' % name if kind == 'app' else '/system/lib/%s' % name
        out.setdefault(f, set()).add(md5)
    return out


def add_release(tag):
    if not git_show(tag, 'patches/cars'):
        sys.exit('%s: no patches/cars at that tag (fetch the tags?)' % tag)
    sets = {}
    for l in git_show(tag, 'patches/cars').splitlines():
        p = l.split()
        if len(p) >= 2 and not p[0].startswith('#'):
            sets[p[0]] = p[1]
    db = json.load(open(COMPAT, encoding='utf-8'))
    rel = json.load(open(RELEASED, encoding='utf-8')) if os.path.exists(RELEASED) else {}
    rel.setdefault('releases', [])
    cars = rel.setdefault('cars', {})
    for v in db['variants']:
        prefixes = v['product_prefix'] if isinstance(v['product_prefix'], list) else [v['product_prefix']]
        found = set()
        for p in prefixes:
            within = [c for c in sets if p.startswith(c)]
            found |= {sets[max(within, key=len)]} if within else {sets[c] for c in sets if c.startswith(p)}
        if len(found) != 1:
            continue  # not in that release, or ambiguous there
        mine = cars.setdefault(v['id'], {})
        for f, md5s in released_for(tag, found.pop()).items():
            mine[f] = sorted(set(mine.get(f, [])) | md5s)
    if tag not in rel['releases']:
        rel['releases'].append(tag)
    rel['cars'] = {k: dict(sorted(cars[k].items())) for k in sorted(cars) if cars[k]}
    open(RELEASED, 'w', encoding='utf-8').write(json.dumps(rel, indent=2, ensure_ascii=False) + '\n')
    print('docs/data/released.json: added %s' % tag)


def main():
    if sys.argv[1:2] == ['--release']:
        for tag in sys.argv[2:]:
            add_release(tag)
        return
    check = '--check' in sys.argv[1:]
    sets = {}
    for l in open(os.path.join(PATCHES, 'cars')):
        p = l.split()
        if len(p) >= 2 and not p[0].startswith('#'):
            sets[p[0]] = p[1]
    raw = open(COMPAT, encoding='utf-8').read()
    db = json.loads(raw)
    for v in db['variants']:
        prefixes = v['product_prefix'] if isinstance(v['product_prefix'], list) else [v['product_prefix']]
        found = set()
        for p in prefixes:
            within = [c for c in sets if p.startswith(c)]
            found |= {sets[max(within, key=len)]} if within else {sets[c] for c in sets if c.startswith(p)}
        if len(found) > 1:
            sys.exit('%s: product prefixes map to several patch sets %s' % (v['id'], sorted(found)))
        b = built_for(found.pop()) if found else {}
        if b:
            v['built'] = b
        else:
            v.pop('built', None)
    # the universal build (patches/universal/manifest): for each app, the code md5s
    # (the dex inside its stock odex, as the kit's "code" lines report) we have
    # patches for; for each file, its stock md5s. A car matching all of them gets
    # the full build without a patch set of its own.
    uni = universal()
    if uni:
        db['universal'] = uni
    else:
        db.pop('universal', None)
    new = json.dumps(db, indent=2, ensure_ascii=False) + '\n'
    if new == raw:
        print('compat.json built lists are up to date')
        return
    if check:
        sys.exit('docs/data/compat.json "built" lists are out of date: run tools/compat-built.py')
    open(COMPAT, 'w', encoding='utf-8').write(new)
    print('updated docs/data/compat.json')


if __name__ == '__main__':
    main()
