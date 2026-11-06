#!/usr/bin/env python3
"""Does the EV build fit a car? Compares a Leafia kit report (LEAFIA-REPORT.txt, or an
issue body with one pasted in) with ev/car-reference, the Ioniq 5 US 260507 files the
EV build was made and checked on.

  tools/ev-check.py LEAFIA-REPORT.txt      (or - for stdin)

Needs a report from a kit that lists automotive-service.odex and com.hkmc.ext.hcan.odex
(kits after 2026-11-06). Exit 0 = every file matches, 1 = something differs or is missing,
2 = bad input. Reads hashes only; works without any stock files.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REF = os.path.join(ROOT, 'ev', 'car-reference')
JAVA = os.path.join(ROOT, 'ev', 'gpm-ev', 'src', 'com', 'google', 'android', 'projection',
                    'protocol', 'EvCar.java')


def reference():
    ref = []
    for l in open(REF):
        p = l.split()
        if len(p) == 3 and not p[0].startswith('#'):
            ref.append(tuple(p))
    return ref


def check_reference(ref):
    """the hcan md5 here must be the one the EV code checks"""
    m = re.search(r'HCAN_MD5\s*=\s*"([0-9a-f]{32})"', open(JAVA).read())
    hcan = [h for k, f, h in ref if f.endswith('com.hkmc.ext.hcan.odex')]
    if not m or hcan != [m.group(1)]:
        sys.exit('ev/car-reference: hcan md5 %s does not match EvCar.HCAN_MD5 %s'
                 % (hcan, m and m.group(1)))


def parse(text):
    product, files, codes = None, {}, {}
    for l in text.splitlines():
        l = l.strip()
        m = re.match(r'prop ro\.build\.product=(\S+)', l)
        if m:
            product = m.group(1)
        m = re.match(r'(file|code) (\S+) (md5=([0-9a-f]{32})|none|missing|absent)', l)
        if m:
            (files if m.group(1) == 'file' else codes)[m.group(2)] = m.group(4)
    return product, files, codes


WHAT = {
    'framework': 'vehicle framework',
    'code': 'GPM app code',
    'file': 'Android Auto library',
}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    ref = reference()
    check_reference(ref)
    text = sys.stdin.read() if sys.argv[1] == '-' else open(sys.argv[1], encoding='utf-8', errors='replace').read()
    product, files, codes = parse(text)
    if not product:
        print('no "prop ro.build.product=" line: not a Leafia kit report')
        return 2
    print('car: %s' % product)
    bad = {'framework': [], 'code': [], 'file': []}
    old_kit = False
    for kind, path, want in ref:
        have = (codes if kind == 'code' else files).get(path, 'unreported')
        if path not in (codes if kind == 'code' else files):
            if kind == 'framework':
                old_kit = True
        state = 'same' if have == want else ('not in report' if have == 'unreported' else 'differs')
        print('  %-9s %-45s %s' % (kind, path, state))
        if state != 'same':
            bad[kind].append(path)
    print()
    if old_kit:
        print('This report is from an older kit that doesn\'t list every framework file: '
              'run the current Leafia kit and send its report.')
        return 1
    if not any(bad.values()):
        print('EV build fits: the same framework, GPM code and Android Auto library as the '
              'Ioniq 5 US 260507. No new vehicle-command review is needed; the car still needs '
              'its own energy model if it isn\'t an Ioniq 5 with the same battery, and a car test.')
        return 0
    if bad['framework']:
        print('The vehicle framework differs: the EV code would stay off (it reads and sends '
              'nothing on another framework). Adding it needs that car\'s framework files '
              '(port kit), its command numbers found and checked, and a vehicle-command review.')
    if bad['code']:
        print('The GPM app code differs: the EV GPM has to be rebuilt onto this car\'s GPM '
              '(port kit stock files).')
    if bad['file']:
        print('The Android Auto library differs: the EV library patch has to be ported to it '
              'by hand (port kit stock files).')
    return 1


if __name__ == '__main__':
    sys.exit(main())
