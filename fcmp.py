# fcmp.py <stock kernel repo> <ours dir> <out dir>: per module, which functions are instruction-for-instruction the
# same as stock's (addresses replaced by symbol names and in-function offsets, relocations by their targets).
# Writes <out>/func.tsv (module, identical, differing, only stock, only ours) and <out>/func/<module>.txt.
import os, re, shutil, subprocess, sys, hashlib
from concurrent.futures import ProcessPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
O = os.environ.get('OBJDUMP') or shutil.which('llvm-objdump')
stock_root, ours_root, out = (sys.argv[1:4] + [None]*3)[:3]
SUFFIX = re.compile(r'(\.(llvm|cfi|constprop|isra|part|cold|localalias)[._0-9a-z]*)+$')

def kos(root):
    r = {}
    for part in ('vendor_ramdisk', 'vendor_dlkm', '.'):  # stock's layout, or a flat directory
        d = os.path.join(root, part)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith('.ko'): r.setdefault(f, os.path.join(d, f))
    return r

PMAP = []
if os.environ.get('PREFIX_MAP'):
    PMAP = sorted((l.strip().replace('$(srctree)/', '').split('=', 1) for l in open(os.environ['PREFIX_MAP']) if '=' in l), key=lambda x: -len(x[0]))
LINE = re.compile(r'(\.[ch]):\d+')
def remap(t):
    for a, b in PMAP:
        if a in t: t = t.replace(a, b); break
    return LINE.sub(r'\1:<line>', t)[:200]

def norm_name(n):
    n = SUFFIX.sub('', n)
    return re.sub(r'\.\d+$', '', n)

def parse(ko):
    from elf import Elf
    e = Elf(ko)
    txt = subprocess.run([O, '-d', '-r', '--no-show-raw-insn', ko], capture_output=True, text=True, check=True).stdout
    fns, cur, base = {}, None, 0
    for l in txt.splitlines():
        m = re.match(r'^([0-9a-f]{16}) <([^>]+)>:', l)
        if m:
            cur = norm_name(m.group(2)); base = int(m.group(1), 16); fns[cur] = []
            continue
        if cur is None: continue
        r = re.match(r'^\s+([0-9a-f]+):\s+(R_AARCH64_\w+)\s+(\S+)', l)
        if r:
            t = r.group(3)
            mm = re.match(r'(.+?)\+(0x[0-9a-f]+)$', t)
            sym, add = (mm.group(1), int(mm.group(2), 16)) if mm else (t, 0)
            if sym.startswith('.'):  # section symbol: say what is there
                idx = next((i for i, s in enumerate(e.sh) if s['name'] == sym), None)
                sym = e.name_at(idx, add) if idx is not None else sym; add = 0
            fns[cur].append(f'  R {r.group(2)} {remap(norm_name(sym).lstrip("&"))}' + (f'+{add:#x}' if add else ''))
            continue
        if '.word' in l or '.short' in l or '.byte' in l: continue
        m = re.match(r'^\s+([0-9a-f]+):\s+(\S+)\s*(.*)$', l)
        if not m: continue
        addr, op, args = int(m.group(1), 16), m.group(2), m.group(3).split('//')[0].strip()
        def tgt(mt):
            a, s, o = int(mt.group(1), 16), norm_name(mt.group(2)), mt.group(3) or ''
            return ('<L->' if a <= addr else '<L+>') if s == cur else f'<{s}{o}>'
        if op in ('adrp', 'adr'): args = re.sub(r',.*', ', <page>', args)  # the target is in the relocation that follows
        else: args = re.sub(r'0x([0-9a-f]+) <([^>+]+)(\+0x[0-9a-f]+)?>', tgt, args)
        if op == '.word' or op.startswith('.'): args = ''  # constant pools and kCFI hashes
        fns[cur].append(f'{op} {args}')
    # an immediate moved into an argument register shortly before a print call is a line number or a log argument
    PR = re.compile(r'CALL26 (_printk|_printk_deferred|_dev_(err|info|warn|notice|dbg|crit|alert|emerg)|dev_err_probe|__dynamic_\w+|__warn_printk|aee_\w+|snprintf|scnprintf|sprintf|seq_printf|mtk_\w*log\w*|__ubsan\w*)$')
    for k, L in ({} if os.environ.get('FCMP_STRICT') else fns).items():  # FCMP_STRICT=1: compare these too
        for i, ins in enumerate(L):
            m = re.match(r'(mov|movz|movk) ([wx][0-7]), #', ins)
            if m and any(PR.search(x) for x in L[i + 1:i + 10]):
                L[i] = f'{m.group(1)} {m.group(2)}, #<printarg>'
    return {k: v for k, v in fns.items() if not k.startswith(('$', '.'))}

def compare(job):
    name, sp, op = job
    a, b = parse(sp), parse(op)
    same = [f for f in a if f in b and a[f] == b[f]]
    diff = [f for f in a if f in b and a[f] != b[f]]
    os_, oo = sorted(set(a) - set(b)), sorted(set(b) - set(a))
    os.makedirs(os.path.join(out, 'func'), exist_ok=True)
    with open(os.path.join(out, 'func', name + '.txt'), 'w') as f:
        import difflib
        for x in sorted(diff):
            ch = 0; kinds = set()
            for op_, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a[x], b[x], autojunk=False).get_opcodes():
                if op_ == 'equal': continue
                ch += max(i2 - i1, j2 - j1)
                for l in a[x][i1:i2] + b[x][j1:j2]:
                    kinds.add('reloc' if l.startswith('  R') else l.split()[0])
            f.write(f'DIFF {x} stock {len(a[x])} ours {len(b[x])} changed {ch} kinds {",".join(sorted(kinds))}\n')
        for x in os_: f.write(f'ONLY-STOCK {x} {len(a[x])}\n')
        for x in oo: f.write(f'ONLY-OURS {x} {len(b[x])}\n')
        for x in sorted(same): f.write(f'SAME {x}\n')
    return name, len(same), len(diff), len(os_), len(oo)

if __name__ == '__main__':
    if not O: sys.exit('fcmp.py: no llvm-objdump; set OBJDUMP')
    S, Ou = kos(stock_root), kos(ours_root)
    jobs = [(n, S[n], Ou[n]) for n in sorted(set(S) & set(Ou))]
    with ProcessPoolExecutor() as ex: res = list(ex.map(compare, jobs))
    with open(os.path.join(out, 'func.tsv'), 'w') as f:
        f.write('module\tsame\tdiffer\tonly_stock\tonly_ours\n')
        for r in sorted(res, key=lambda r: (r[2] + r[3]) / max(1, r[1] + r[2] + r[3]), reverse=True): f.write('\t'.join(map(str, r)) + '\n')
    t = [sum(r[i] for r in res) for i in range(1, 5)]
    full = sum(1 for r in res if r[2] == 0 and r[3] == 0 and r[4] == 0 and r[1] > 0)
    print(f'{len(res)} modules, {full} with every function the same; functions: same {t[0]}, differ {t[1]}, only stock {t[2]}, only ours {t[3]}')
