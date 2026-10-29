# bytes.py <stock modules> <our modules> <out dir>: compare each module byte by byte with stock's.
# Writes <out>/bytes.tsv: module, status, the sections holding differing bytes. The status is "identical",
# "identical but the build ID" (only .note.gnu.build-id differs), "identical but the build ID and the BTF" (every
# other section's contents are stock's; only for the kernel's own modules), "identical but the build ID and the
# kernel's header lines" (only line numbers in __bug_table differ, each from a kernel header by the lines stock's
# kernel tree has more, below), or "differs".
#
# The build ID is a hash the linker takes of the whole module before its debugging information is stripped,
# and that information names the directories of the machine that built it; stock's builder is unknown.
# The kernel's own modules also carry BTF, written against the BTF of the kernel they were built with: Xiaomi's
# own tree (4d05d8779bfd), not published, and not the GKI kernel on the phone (checked against its
# /sys/kernel/btf/vmlinux), so their type numbers cannot be stock's.
# The same tree's headers are not all the GKI kernel's: a BUG_ON() or WARN_ON() in a header records the header's
# line in the module, and where stock's lines are later by a fixed count throughout, that count is listed here.
import os, struct, sys
from elf import Elf

HEADER_LINES = {'include/ufs/ufshcd.h': 3}  # stock's BUG_ON()s at 1349 and 1359, the GKI kernel's at 1346 and 1356

stock_root, ours_root, out = sys.argv[1:4]

def kos(root):
    r = {}
    for part in ('vendor_ramdisk', 'vendor_dlkm', '.'):
        d = os.path.join(root, part)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith('.ko'): r.setdefault(f, os.path.join(d, f))
    return r

def sections(d):
    shoff, = struct.unpack_from('<Q', d, 0x28)
    es, n, si = struct.unpack_from('<HHH', d, 0x3a)
    sh = [struct.unpack_from('<IIQQQQIIQQ', d, shoff + i * es) for i in range(n)]
    so = sh[si][4]
    name = lambda o: d[so + o:d.index(b'\0', so + o)].decode()
    # (name, file offset, size in the file); NOBITS sections take no room in the file
    return [(name(s[0]), s[4], 0 if s[1] == 8 else s[5]) for s in sh], shoff, es * n

def where(d, offs):
    secs, shoff, shsize = sections(d)
    r = set()
    for o in offs:
        hit = [n for n, off, sz in secs if off <= o < off + sz]
        r |= set(hit) or {'section headers' if shoff <= o < shoff + shsize else 'ELF header' if o < 64 else 'padding'}
    return r

def same_but(a, b, allowed):
    sa = {n: a[off:off + sz] for n, off, sz in sections(a)[0]}
    sb = {n: b[off:off + sz] for n, off, sz in sections(b)[0]}
    return set(sa) == set(sb) and all(sa[n] == sb[n] for n in sa if n not in allowed)

def header_lines_only(sp, op):
    """Every differing entry of __bug_table differs only in its line, by HEADER_LINES of the header it names."""
    a, b = Elf(sp), Elf(op)
    ia = [i for i, x in enumerate(a.sh) if x['name'] == '__bug_table']; ib = [i for i, x in enumerate(b.sh) if x['name'] == '__bug_table']
    if len(ia) != 1 or len(ib) != 1: return False
    sa, sb = a.sh[ia[0]], b.sh[ib[0]]
    if sa['size'] != sb['size'] or sa['size'] % 12: return False  # struct bug_entry: two offsets, line, flags
    rel = {o: (i, ad) for o, t, i, ad in a.rela.get(ia[0], [])}
    for e in range(0, sa['size'], 12):
        x, y = a.d[sa['off'] + e:sa['off'] + e + 12], b.d[sb['off'] + e:sb['off'] + e + 12]
        if x == y: continue
        if x[:8] != y[:8] or x[10:] != y[10:] or e + 4 not in rel: return False
        f = a.target(*rel[e + 4]).strip('"')
        if struct.unpack_from('<H', x, 8)[0] - struct.unpack_from('<H', y, 8)[0] != HEADER_LINES.get(f): return False
    return True

S, O = kos(stock_root), kos(ours_root)
with open(os.path.join(out, 'bytes.tsv'), 'w') as f:
    for m in sorted(S):
        if m not in O: continue
        a, b = open(S[m], 'rb').read(), open(O[m], 'rb').read()
        if a == b:
            f.write(f'{m}\tidentical\t\n'); continue
        if b'.BTF\0' in a and same_but(a, b, {'.note.gnu.build-id', '.BTF', '.shstrtab'}):
            f.write(f'{m}\tidentical but the build ID and the BTF\t\n'); continue
        if len(a) != len(b):
            sa = {n: sz for n, _, sz in sections(a)[0]}; sb = {n: sz for n, _, sz in sections(b)[0]}
            diff = sorted(n for n in set(sa) | set(sb) if sa.get(n) != sb.get(n))
            f.write(f'{m}\tdiffers\tsize of {",".join(diff) or "the file"}\n'); continue
        offs = [i for i in range(len(a)) if a[i] != b[i]]
        secs = where(a, offs)
        if secs == {'.note.gnu.build-id'}: f.write(f'{m}\tidentical but the build ID\t\n')
        elif secs - {'.note.gnu.build-id'} == {'__bug_table'} and header_lines_only(S[m], O[m]):
            f.write(f"{m}\tidentical but the build ID and the kernel's header lines\t\n")
        else: f.write(f'{m}\tdiffers\t{",".join(sorted(secs - {".note.gnu.build-id"}))}\n')
