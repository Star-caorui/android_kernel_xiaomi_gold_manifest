# dcmp.py <stock kernel repo> <ours dir> <out dir>: compare every data object of same-named modules
# (contents with relocations resolved to names). Writes <out>/data.tsv and <out>/data/<module>.txt.
import os, sys
from concurrent.futures import ProcessPoolExecutor
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from elf import Elf

stock_root, ours_root, out = sys.argv[1:4]
SKIP = ('__func__', '__UNIQUE_ID', '__param', '__kstrtab', '__ksymtab', '__kcrctab', '__crc_', '__mod_', '_rs.', '__already_done',
        '__warned', '___done', '__print_once', '__key', '__compound_literal', '____versions', '__this_module', '_entry',
        '__tracepoint_', '__SCK__', '__SCT__', '__bpf_trace_', 'trace_event_', 'event_class_', '__event_', 'print_fmt_',
        '__TRACE_SYSTEM', 'str__', 'TRACE_SYSTEM_', '__initcall', '__exitcall', '__setup', '__dyndbg', '_note_')

def kos(root):
    r = {}
    for part in ('vendor_ramdisk', 'vendor_dlkm', '.'):  # stock's layout, or a flat directory
        d = os.path.join(root, part)
        if os.path.isdir(d):
            for f in os.listdir(d):
                if f.endswith('.ko'): r.setdefault(f, os.path.join(d, f))
    return r

def objects(e):
    r = {}
    for y in e.syms:
        if y['type'] != 1 or not y['size'] or not (0 < y['shndx'] < len(e.sh)): continue
        n = e.SUFFIX.sub('', y['name']) if hasattr(e, 'SUFFIX') else y['name']
        import re
        n = re.sub(r'(\.(llvm|cfi|constprop|isra|part)[._0-9a-z]*)+$', '', n)
        n = re.sub(r'\.\d+$', '', n)
        if n.startswith(SKIP) or any(x in n for x in ('._rs', '.__func__', '__already_done', '.__warned', '__print_once')): continue
        sec = e.sh[y['shndx']]['name']
        if sec.startswith(('.modinfo', '__versions', '.gnu.linkonce', '__ksymtab', '__kcrctab', '__param', '.BTF', '__tracepoints',
                           '_ftrace_events', '__dyndbg', '.note', '__bug_table', '.init.')): continue
        r.setdefault(n, []).append((sec, y['size'], e.object_tokens(y['shndx'], y['value'], y['size'])))
    return r

def compare(job):
    name, sp, op = job
    a, b = objects(Elf(sp)), objects(Elf(op))
    lines = []
    for n in sorted(set(a) & set(b)):
        if len(a[n]) != 1 or len(b[n]) != 1: continue  # several statics of the same name: skip
        (sa, za, ta), (sb, zb, tb) = a[n][0], b[n][0]
        if za != zb:
            lines.append(f'SIZE {n} ({sa}) stock {za} ours {zb}')
        elif ta != tb:
            ra = ''.join(x for x in ta); rb = ''.join(x for x in tb)
            # first difference, in tokens
            for i, (x, y) in enumerate(zip(ta, tb)):
                if x != y: break
            lines.append(f'CONTENT {n} ({sa}, {za} bytes): stock {ta[i][:70]} ours {tb[i][:70]}')
    for n in sorted(set(a) - set(b)): lines.append(f'ONLY-STOCK {n} ({a[n][0][0]}, {a[n][0][1]} bytes)')
    for n in sorted(set(b) - set(a)): lines.append(f'ONLY-OURS {n} ({b[n][0][0]}, {b[n][0][1]} bytes)')
    os.makedirs(os.path.join(out, 'data'), exist_ok=True)
    open(os.path.join(out, 'data', name + '.txt'), 'w').write('\n'.join(lines) + '\n')
    nsz = sum(l.startswith('SIZE') for l in lines); nct = sum(l.startswith('CONTENT') for l in lines)
    return name, nsz + nct, f'size {nsz} content {nct} only-stock {sum(l.startswith("ONLY-STOCK") for l in lines)} only-ours {sum(l.startswith("ONLY-OURS") for l in lines)} common {len(set(a) & set(b))}'

if __name__ == '__main__':
    S, O = kos(stock_root), kos(ours_root)
    jobs = [(n, S[n], O[n]) for n in sorted(set(S) & set(O))]
    with ProcessPoolExecutor() as ex: res = list(ex.map(compare, jobs))
    res.sort(key=lambda r: -r[1])
    with open(os.path.join(out, 'data.tsv'), 'w') as f:
        for n, k, s in res: f.write(f'{k}\t{n}\t{s}\n')
    print(sum(1 for r in res if r[1] == 0), 'modules with no data difference of', len(res))
