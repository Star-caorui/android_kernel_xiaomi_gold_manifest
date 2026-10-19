# paths.py <stock modules> <our modules> <repository> <out dir>: the source paths each module names, stock's against
# ours, and whether the synced tree has each file stock names at the same place.
# Writes <out>/paths.tsv: module, path, named by stock's ("yes"/"no"), named by ours ("yes"/"no", "-" when we do
# not build the module), in the synced tree; a module that names none in either has one line with an empty path.
# Writes <out>/abspaths.tsv: absolute source paths in our modules (module, path), which a build must not leave.
#
# Stock's build passed sources to the compiler by paths relative to the kernel's directory, so a source file that
# uses __FILE__ (in WARN(), BUG(), assertions, logs) leaves "../<directory>/<file>" in the module. The kernel sits
# next to the synced directories (kernel-6.6/), so "../x/y.c" is x/y.c here. Our modules must name the same
# paths: that is where they were built from.
import os, re, sys

stock_root, ours_root, repo, out = sys.argv[1:5]
PATH = re.compile(rb'(?<![A-Za-z0-9_./-])\.\./([A-Za-z0-9_+./-]+?\.[chS])(?![A-Za-z0-9_])')
ABS = re.compile(rb'(?<![A-Za-z0-9_./-])/[A-Za-z0-9_+.-]+/[A-Za-z0-9_+./-]+?\.[chS](?![A-Za-z0-9_])')

def kos(root):
    r = {}
    for part in ('vendor_ramdisk', 'vendor_dlkm', '.'):
        d = os.path.join(root, part)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith('.ko'): r.setdefault(f, os.path.join(d, f))
    return r

S, O = kos(stock_root), kos(ours_root)
with open(os.path.join(out, 'paths.tsv'), 'w') as o:
    for m in sorted(S):
        a = {x.decode() for x in PATH.findall(open(S[m], 'rb').read())}
        b = {x.decode() for x in PATH.findall(open(O[m], 'rb').read())} if m in O else set()
        if not a and not b:
            o.write(f'{m}\t\t\t\t\n'); continue
        for p in sorted(a | b):
            here = 'yes' if os.path.isfile(os.path.join(repo, os.path.normpath(p))) else 'no'
            ours = '-' if m not in O else ('yes' if p in b else 'no')
            o.write(f'{m}\t{p}\t{"yes" if p in a else "no"}\t{ours}\t{here}\n')
with open(os.path.join(out, 'abspaths.tsv'), 'w') as o:
    for m in sorted(O):
        for p in sorted({x.decode() for x in ABS.findall(open(O[m], 'rb').read())}): o.write(f'{m}\t{p}\n')
