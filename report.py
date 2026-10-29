# report.py <stock modules> <our modules> <compare dir>: results.md from fcmp.py's func.tsv and dcmp.py's data.tsv,
# with the notes in notes.tsv (module, note) next to this script.
import os, sys, re

stock_root, ours_root, cdir = sys.argv[1:4]
here = os.path.dirname(os.path.abspath(__file__))

def kos(root):
    r = set()
    for part in ('vendor_ramdisk', 'vendor_dlkm', '.'):
        d = os.path.join(root, part)
        if os.path.isdir(d): r |= {f for f in os.listdir(d) if f.endswith('.ko')}
    return r

stock, ours = kos(stock_root), kos(ours_root)
func = {}
for l in open(os.path.join(cdir, 'func.tsv')).read().splitlines()[1:]:
    m, *n = l.split('\t'); func[m] = list(map(int, n))
data = {}
for l in open(os.path.join(cdir, 'data.tsv')).read().splitlines():
    n, m, *_ = l.split('\t'); data[m] = int(n)
paths = [l.split('\t') for l in open(os.path.join(cdir, 'paths.tsv')).read().splitlines()]
byts = {l.split('\t')[0]: l.split('\t')[1:] for l in open(os.path.join(cdir, 'bytes.tsv')).read().splitlines()}
notes = {}
p = os.path.join(here, 'notes.tsv')
if os.path.exists(p):
    for l in open(p).read().splitlines():
        if l and not l.startswith('#'):
            m, t = l.split('\t', 1); notes[m] = t

LEVELS = ('Byte-identical', "Byte-identical but stock's kernel", 'Code and data identical', 'Code identical', 'Differs')
def status(m):
    b = byts.get(m, [''])[0]
    if b in ('identical but the build ID and the BTF', "identical but the build ID and the kernel's header lines"):
        return "Byte-identical but stock's kernel"
    if b.startswith('identical'): return 'Byte-identical'
    same, differ, only_s, only_o = func[m]
    if differ + only_s + only_o == 0: return 'Code and data identical' if data.get(m, 0) == 0 else 'Code identical'
    return 'Differs'

compared = sorted(func, key=lambda m: (LEVELS.index(status(m)), m))
count = {s: sum(1 for m in compared if status(m) == s) for s in LEVELS}
nosrc = sorted(stock - ours)

print('# Results\n')
print("Made by `verify/compare.sh` from the sources `default.xml` syncs. What the columns mean is in `verify/README.md`.\n")
print('| | Modules |\n| --- | --- |')
print(f'| Stock vendor modules | {len(stock)} |')
print(f"| Built and compared (the synced sources, and the kernel's own modules) | {len(compared)} |")
print(f'| Byte-identical, but for the build ID | {count["Byte-identical"]} |')
print(f"| Byte-identical, but for the build ID and what stock's unpublished kernel decides (the BTF of the kernel's own modules, line numbers from its headers) | {count[LEVELS[1]]} |")
print(f'| Code and data identical: every function and every data object, but not every byte | {count["Code and data identical"]} |')
print(f'| Code identical: every function, but some data objects differ | {count["Code identical"]} |')
print(f'| Differs | {count["Differs"]} |')
print(f'| Stock modules without published source | {len(nosrc)} |')
named = [p for p in paths if p[1]]
bymod = {}
for p in named: bymod.setdefault(p[0], []).append(p)
stock_named = {m for m, ps in bymod.items() if any(p[2] == 'yes' for p in ps)}
built = {m for m in bymod if all(p[3] != '-' for p in bymod[m])}
same = {m for m in built if all(p[2] == p[3] for p in bymod[m])}
abspaths = [l.split('\t') for l in open(os.path.join(cdir, 'abspaths.tsv')).read().splitlines()]
# the device tree blob, when compare.sh is given both
dtb_stock, dtb_ours = os.environ.get('DTB_STOCK', ''), os.environ.get('DTB_OURS', '')
if os.path.isfile(dtb_stock) and os.path.isfile(dtb_ours):
    dtb_same = open(dtb_stock, 'rb').read() == open(dtb_ours, 'rb').read()
    print('\n## Device tree blob\n')
    print('| | |\n| --- | --- |')
    print(f"| `dtb/gold.dtb` of `vendor_boot` (mt6833.dts in an Android DT table), against stock's | {'Byte-identical' if dtb_same else 'Differs'} |")
    # stock's dtbo carries MediaTek's image signature after the table; the table's header gives its size
    dtbo_stock, dtbo_ours = os.environ.get('DTBO_STOCK', ''), os.environ.get('DTBO_OURS', '')
    if os.path.isfile(dtbo_stock) and os.path.isfile(dtbo_ours):
        st, o = open(dtbo_stock, 'rb').read(), open(dtbo_ours, 'rb').read()
        size = int.from_bytes(st[4:8], 'big')
        dtbo = 'Byte-identical' if st[:size] == o else 'Differs'
        if dtbo == 'Byte-identical' and len(st) > size: dtbo += ", but for MediaTek's signature after stock's table"
        print(f"| `dtbo.img` (gold.dts in an Android DT table), against stock's | {dtbo} |")
print('\n## Source paths\n')
print("Where each source file was built from, as far as the modules name the path (`verify/paths.py`): stock's")
print("modules against ours, and the files stock's name against the synced tree. The rest of the layout follows")
print("MiCode's sources and cannot be checked this way.\n")
print('| | |\n| --- | --- |')
print(f'| Stock modules that name source paths | {len(stock_named)} |')
print(f'| Stock modules that name none | {sum(1 for p in paths if not p[1])} |')
print(f'| Of the ones we build, naming the same paths as stock\'s | {len(same)} of {len(built)} |')
sp = [p for p in named if p[2] == 'yes']
print(f'| Paths stock\'s modules name, found at the same place in the synced tree | {sum(1 for p in sp if p[4] == "yes")} of {len(sp)} |')
print(f'| Absolute paths in our modules | {len(abspaths)} |')
diff = sorted(built - same)
if diff:
    print('\nModules naming other paths than stock\'s:\n')
    print('| Module | Only stock\'s | Only ours | Note |\n| --- | --- | --- | --- |')
    for m in diff:
        a1 = ', '.join(f'`{p[1]}`' for p in bymod[m] if p[2] == 'yes' and p[3] != 'yes')
        b1 = ', '.join(f'`{p[1]}`' for p in bymod[m] if p[3] == 'yes' and p[2] != 'yes')
        print(f'| `{m}` | {a1} | {b1} | {notes.get(m, "")} |')
missing = [p for p in sp if p[4] != 'yes']
if missing:
    print('\nFiles stock\'s modules name that the synced tree does not have:\n')
    print('| Module | Path | Note |\n| --- | --- | --- |')
    for p in missing: print(f'| `{p[0]}` | `{p[1]}` | {notes.get(p[0], "")} |')
print('\n## Compared modules\n')
print('| Module | Status | Functions same | Differ | Only stock | Only ours | Data objects differing | Bytes differing in | Note |')
print('| --- | --- | --- | --- | --- | --- | --- | --- | --- |')
for m in compared:
    same, differ, only_s, only_o = func[m]
    b = byts.get(m, ['', ''])
    where = '' if b[0].startswith('identical') else b[1].replace(',', ', ')
    print(f'| `{m}` | {status(m)} | {same} | {differ} | {only_s} | {only_o} | {data.get(m, 0)} | {where} | {notes.get(m, "")} |')
print('\n## Stock modules without published source\n')
print('| Module | Note |\n| --- | --- |')
for m in nosrc: print(f'| `{m}` | {notes.get(m, "")} |')
