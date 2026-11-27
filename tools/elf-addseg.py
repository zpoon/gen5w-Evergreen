#!/usr/bin/env python3
"""Apply an in-memory native recipe (HMG-API's MemRecipe format) to an ARM32 library file.

usage: elf-addseg.py <stock .so> <recipe> <out .so>

HMG-API maps a recipe's `segment` next to the loaded library at run time. Evergreen patches
files, so this puts the segment into the file instead: a new read+execute PT_LOAD after the
library's last segment, holding a copy of the program header table (PT_PHDR points at it)
and then the segment code. `rel32` and `branch` are resolved against that address, `patch`
lines are written as given, and every `verify` region must hold the stock bytes first (its
"after" md5 is checked too, unless it is "-"). Same input, same output.

Recipe lines (offsets are library file offsets; the first PT_LOAD maps file offset 0 at 0):
  id <name> / file <path> / native <md5> ...   ignored here
  verify <off> <len> <md5 before> <md5 after|->
  patch <off> <hex>
  segment <preferred off> <hex>     placed at the first page-aligned address after the library
  rel32 <seg off> <seg anchor> <lib off>   u32 at seg off := addr(lib off) - addr(seg anchor)
  branch <off> <seg off>            Thumb-2 B.W (T4) from the library into the segment
"""
import hashlib, struct, sys

PT_LOAD, PT_PHDR = 1, 6
PAGE = 0x1000


def md5(b):
    return hashlib.md5(b).hexdigest()


def parse(path):
    r = {'verify': [], 'patch': [], 'segment': None, 'rel32': [], 'branch': []}
    for line in open(path):
        w = line.split()
        if not w or w[0].startswith('#'):
            continue
        if w[0] == 'verify':
            r['verify'].append((int(w[1], 0), int(w[2], 0), w[3], w[4]))
        elif w[0] == 'patch':
            r['patch'].append((int(w[1], 0), bytes.fromhex(w[2])))
        elif w[0] == 'segment':
            r['segment'] = bytes.fromhex(w[2])
        elif w[0] == 'rel32':
            r['rel32'].append((int(w[1], 0), int(w[2], 0), int(w[3], 0)))
        elif w[0] == 'branch':
            r['branch'].append((int(w[1], 0), int(w[2], 0)))
        elif w[0] in ('id', 'file', 'native'):
            pass
        else:
            sys.exit('elf-addseg: unknown recipe line: ' + line.strip())
    if (r['rel32'] or r['branch']) and r['segment'] is None:
        sys.exit('elf-addseg: rel32/branch without a segment')
    return r


def bw(src, dst):
    """Thumb-2 B.W (T4) at address src to dst"""
    off = dst - (src + 4)
    if off % 2 or not -(1 << 24) <= off < (1 << 24):
        sys.exit('elf-addseg: branch out of range 0x%x -> 0x%x' % (src, dst))
    v = off & 0x1ffffff
    s = (v >> 24) & 1
    i1 = (v >> 23) & 1
    i2 = (v >> 22) & 1
    imm10 = (v >> 12) & 0x3ff
    imm11 = (v >> 1) & 0x7ff
    j1 = (~(i1 ^ s)) & 1
    j2 = (~(i2 ^ s)) & 1
    hw1 = 0xf000 | (s << 10) | imm10
    hw2 = 0x9000 | (j1 << 13) | (j2 << 11) | imm11
    return struct.pack('<HH', hw1, hw2)


def main():
    src, rec, out = sys.argv[1:4]
    d = bytearray(open(src, 'rb').read())
    r = parse(rec)
    if d[:4] != b'\x7fELF' or d[4] != 1 or d[5] != 1:
        sys.exit('elf-addseg: not a little-endian ELF32 file')
    e_phoff, = struct.unpack_from('<I', d, 0x1c)
    e_phentsize, e_phnum = struct.unpack_from('<HH', d, 0x2a)
    ph = [list(struct.unpack_from('<8I', d, e_phoff + i * e_phentsize)) for i in range(e_phnum)]
    loads = [p for p in ph if p[0] == PT_LOAD]
    if not loads or loads[0][1] != 0 or loads[0][2] != 0:
        sys.exit('elf-addseg: first PT_LOAD must map file offset 0 at address 0')
    text = loads[0]
    # every verify region holds the stock bytes
    for off, n, before, after in r['verify']:
        if md5(d[off:off + n]) != before:
            sys.exit('elf-addseg: verify 0x%x: not the stock bytes (%s)' % (off, md5(d[off:off + n])))
    for off, _ in r['patch'] + [(b[0], None) for b in r['branch']]:
        if off + 4 > text[4]:
            sys.exit('elf-addseg: 0x%x is outside the code segment' % off)
    if r['segment'] is not None:
        end_va = max(p[2] + p[5] for p in loads)
        seg_va = (end_va + PAGE - 1) & ~(PAGE - 1)
        file_end = (len(d) + PAGE - 1) & ~(PAGE - 1)
        # keep offset == vaddr (mod page) for the new PT_LOAD
        seg_off = file_end + ((seg_va - file_end) % PAGE)
        new_phnum = e_phnum + 1
        phdr_size = new_phnum * e_phentsize
        code_at = (phdr_size + 15) & ~15          # segment code after the header table
        code = bytearray(r['segment'])
        for at, anchor, lib in r['rel32']:
            v = (lib - (seg_va + code_at + anchor)) & 0xffffffff
            struct.pack_into('<I', code, at, v)
        size = code_at + len(code)
        # program headers: PT_PHDR moves into the new segment, which is added last
        for p in ph:
            if p[0] == PT_PHDR:
                p[1], p[2], p[3], p[4], p[5] = seg_off, seg_va, seg_va, phdr_size, phdr_size
        ph.append([PT_LOAD, seg_off, seg_va, seg_va, size, size, 5, PAGE])   # R+X
        blob = bytearray(size)
        for i, p in enumerate(ph):
            struct.pack_into('<8I', blob, i * e_phentsize, *p)
        blob[code_at:] = code
        d.extend(b'\0' * (seg_off - len(d)))
        d.extend(blob)
        struct.pack_into('<I', d, 0x1c, seg_off)
        struct.pack_into('<H', d, 0x2c, new_phnum)
        seg_code_va = seg_va + code_at
    for off, b in r['patch']:
        d[off:off + len(b)] = b
    for off, so in r['branch']:
        d[off:off + 4] = bw(off, seg_code_va + so)
    for off, n, before, after in r['verify']:
        if after != '-' and md5(d[off:off + n]) != after:
            sys.exit('elf-addseg: verify 0x%x: patched bytes are not the recipe\'s (%s)' % (off, md5(d[off:off + n])))
    open(out, 'wb').write(d)
    print('elf-addseg: %s -> %s (%s), segment at 0x%x' % (md5(open(src, 'rb').read()), out, md5(d),
                                                           seg_code_va if r['segment'] is not None else 0))


if __name__ == '__main__':
    main()
