# elf.py: just enough ELF64 (aarch64 relocatable) parsing for comparing kernel modules
import struct, re

SUFFIX = re.compile(r'(\.(llvm|cfi|constprop|isra|part|cold|localalias)[._0-9a-z]*)+$')

class Elf:
    def __init__(self, path):
        d = self.d = open(path, 'rb').read()
        shoff, = struct.unpack_from('<Q', d, 0x28)
        shentsize, shnum, shstrndx = struct.unpack_from('<HHH', d, 0x3a)
        self.sh = []
        for i in range(shnum):
            name, typ, flags, addr, off, size, link, info, align, entsize = struct.unpack_from('<IIQQQQIIQQ', d, shoff + i * shentsize)
            self.sh.append(dict(name=name, type=typ, flags=flags, off=off, size=size, link=link, info=info, entsize=entsize))
        strtab = self.sh[shstrndx]
        for s in self.sh:
            s['name'] = self.cstr(strtab['off'] + s['name'])
        self.syms = []
        for i, s in enumerate(self.sh):
            if s['type'] == 2:  # SYMTAB
                st = self.sh[s['link']]
                for j in range(s['size'] // 24):
                    n, info, other, shndx, value, size = struct.unpack_from('<IBBHQQ', d, s['off'] + j * 24)
                    self.syms.append(dict(name=self.cstr(st['off'] + n), type=info & 0xf, bind=info >> 4, shndx=shndx, value=value, size=size))
        self.rela = {}  # target section index -> list of (offset, type, symidx, addend)
        for s in self.sh:
            if s['type'] == 4:  # RELA
                lst = self.rela.setdefault(s['info'], [])
                for j in range(s['size'] // 24):
                    off, info, add = struct.unpack_from('<QQq', d, s['off'] + j * 24)
                    lst.append((off, info & 0xffffffff, info >> 32, add))
        # function symbols per section, sorted, to name code addresses
        self.funcs = {}
        for y in self.syms:
            if y['type'] == 2 and y['shndx'] < len(self.sh):
                self.funcs.setdefault(y['shndx'], []).append((y['value'], y['size'], SUFFIX.sub('', y['name'])))
        for v in self.funcs.values(): v.sort()
        self.objs = {}
        for y in self.syms:
            if y['type'] == 1 and y['size'] and 0 < y['shndx'] < len(self.sh):
                self.objs.setdefault(y['shndx'], []).append((y['value'], y['size'], SUFFIX.sub('', y['name'])))
        for v in self.objs.values(): v.sort()

    def cstr(self, off):
        e = self.d.find(b'\0', off)
        return self.d[off:e].decode('latin1')

    def name_at(self, shndx, off):
        """What lives at section+off: a string, a function, an object (+delta), or the section name."""
        s = self.sh[shndx]
        if s['flags'] & 0x20 and s['type'] == 1:  # SHF_STRINGS
            return '"' + self.cstr(s['off'] + off)[:400] + '"'
        for v, sz, n in self.funcs.get(shndx, []):
            if v <= off < v + max(sz, 1): return n + ('' if off == v else f'+{off - v:#x}')
        for v, sz, n in self.objs.get(shndx, []):
            if v <= off < v + max(sz, 1):
                d = '' if off == v else f'+{off - v:#x}'
                if n.startswith('.') or re.search(r'\.\d+$', n):  # anonymous or numbered static: name it by content
                    if getattr(self, '_depth', 0) < 3:
                        self._depth = getattr(self, '_depth', 0) + 1
                        try: c = ''.join(self.object_tokens(shndx, v, sz))
                        finally: self._depth -= 1
                        return '&{' + c[:200] + '}' + d
                    return '&{...}' + d
                return '&' + n + d
        return s['name'] + '+?'

    def target(self, symidx, addend):
        y = self.syms[symidx]
        if y['type'] == 3 or (y['shndx'] and y['shndx'] < len(self.sh) and y['type'] in (0, 1, 2) and y['bind'] == 0 and y['name'] == ''):
            return self.name_at(y['shndx'], y['value'] + addend)
        n = SUFFIX.sub('', y['name'])
        if y['shndx'] and y['shndx'] < len(self.sh) and addend:
            return self.name_at(y['shndx'], y['value'] + addend)
        return n + (f'+{addend:#x}' if addend else '')

    def object_tokens(self, shndx, value, size):
        """The object's bytes, with every relocated field replaced by what it points to."""
        s = self.sh[shndx]
        nobits = s['type'] == 8
        raw = b'\0' * size if nobits else self.d[s['off'] + value:s['off'] + value + size]
        rel = sorted((o - value, t, i, a) for o, t, i, a in self.rela.get(shndx, []) if value <= o < value + size)
        out, pos = [], 0
        for o, t, i, a in rel:
            if o < pos: continue
            out.append(raw[pos:o].hex())
            w = 8 if t in (257, 1027) else 4  # ABS64 / RELATIVE
            out.append('<' + self.target(i, a) + '>')
            pos = o + w
        out.append(raw[pos:].hex())
        return out
