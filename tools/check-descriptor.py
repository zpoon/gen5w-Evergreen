#!/usr/bin/env python3
"""Check the package's NEMESIS.data against the rules NEMESIS 1.16 enforces
(an install with these wrong is refused), and that its os= list covers every
car in patches/cars, so the Package Store shows supported cars as compatible.

    tools/check-descriptor.py [NEMESIS.data] [patches/cars]
"""
import fnmatch
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
desc = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "packages/wireless-carplay-aa/NEMESIS.data")
cars = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "patches/cars")

kv, section = {}, ""
for line in open(desc, encoding="utf-8"):
    line = line.strip()
    if not line or line[0] in "#;":
        continue
    if line.startswith("["):
        section = line.strip("[]")
        continue
    if section == "nemesis" and "=" in line:
        k, v = line.split("=", 1)
        v = v.strip()
        if len(v) >= 2 and v[0] == '"' and v[-1] == '"':
            v = v[1:-1]
        kv[k.strip()] = v

dotted = re.compile(r"\d+(\.\d+)*")
errs = []
if not dotted.fullmatch(kv.get("version", "")):
    errs.append("version must be dotted numbers")
if not dotted.fullmatch(kv.get("package-version", "")):
    errs.append("package-version must be dotted numbers, got %r" % kv.get("package-version"))
if len(kv.get("short-desc", "")) > 64:
    errs.append("short-desc is over 64 characters")
if len(kv.get("detailed-desc", "")) > 256:
    errs.append("detailed-desc is over 256 characters")
pid = kv.get("id", "")
if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,63}", pid) or ".." in pid:
    errs.append("bad id %r" % pid)

os_items = [i.strip() for i in kv.get("os", "any").split(",") if i.strip()]
if "any" not in os_items:
    for line in open(cars, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        prefix = line.split()[0]
        if prefix.endswith("."):
            ok = any(i.startswith(prefix) for i in os_items)
        else:
            ok = any(fnmatch.fnmatchcase(prefix, i) for i in os_items)
        if not ok:
            errs.append("os= has no entry for %s (patches/cars)" % prefix)

if errs:
    sys.exit("NEMESIS.data: " + "; ".join(errs))
print("NEMESIS.data ok: %s %s" % (pid, kv["package-version"]))
