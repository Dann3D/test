"""Diccionarios de texturas (ytd o embebidos en yft/ydd/ydr): leer, reducir y generar mipmaps."""
import io
import re
import struct

from PIL import Image

from .rsc7 import GFX_BASE, layout_pages

FMT_DXT1, FMT_DXT5, FMT_ARGB = 0x31545844, 0x35545844, 21
# texturas que los scripts del juego reemplazan (tablero, pantallas): no se tocan
KEEP = re.compile(r'^script_rt_', re.I)
# lo que primero se reduce cuando hay que bajar mas para entrar en el presupuesto
# rotulos/livery: con texto chico, se reducen al final
HIGH_PRIORITY = re.compile(r'sign|livery|logo|decal|plate', re.I)
LOW_PRIORITY = re.compile(r'mud|dirt|engine|motor|interior|_int\b|spec|normal|_n$|bump', re.I)
FORMATS = {FMT_DXT1: ('DXT1', 8), 0x33545844: ('DXT3', 16), FMT_DXT5: ('DXT5', 16),
           0x31495441: ('ATI1', 8), 0x32495441: ('ATI2', 16), 0x37: ('BC7', 16),
           21: ('A8R8G8B8', 0), 32: ('A8B8G8R8', 0), 28: ('A8', 0), 50: ('L8', 0)}
BPP = {'A8R8G8B8': 32, 'A8B8G8R8': 32, 'A8': 8, 'L8': 8}


def fmt_name(fmt):
    return FORMATS.get(fmt, (hex(fmt), 0))[0]


def mip_bytes(fmt, w, h):
    name, block = FORMATS.get(fmt, (None, 0))
    if block:
        return max(1, (w + 3) // 4) * max(1, (h + 3) // 4) * block
    return w * h * BPP.get(name, 32) // 8


def chain_bytes(fmt, w, h, levels):
    return sum(mip_bytes(fmt, max(1, w >> i), max(1, h >> i)) for i in range(levels))


class Texture:
    def __init__(self, res, ptr):
        self.res, self.ptr = res, ptr
        hdr = res.read(ptr, 0x78)
        self.name = res.cstr(struct.unpack_from('<Q', hdr, 0x28)[0])
        self.w, self.h, _, self.stride = struct.unpack_from('<HHHH', hdr, 0x50)
        self.fmt = struct.unpack_from('<I', hdr, 0x58)[0]
        self.levels = hdr[0x5D]
        self.data_ptr = struct.unpack_from('<Q', hdr, 0x70)[0]

    @property
    def size(self):
        return chain_bytes(self.fmt, self.w, self.h, self.levels)

    def data(self):
        return self.res.read(self.data_ptr, self.size)

    def image(self):
        if self.fmt == FMT_ARGB:
            return Image.frombytes('RGBA', (self.w, self.h), self.data()[:self.w * self.h * 4], 'raw', 'BGRA')
        n = {FMT_DXT1: 1, FMT_DXT5: 3}.get(self.fmt)
        if not n:
            return None
        return Image.frombytes('RGBA', (self.w, self.h), self.data()[:mip_bytes(self.fmt, self.w, self.h)], 'bcn', n)


def dictionary_textures(res, dict_ptr):
    """TextureDictionary: lista de punteros a texturas en +0x30."""
    return [Texture(res, p) for p in res.ptr_list(dict_ptr + 0x30)]


def _pow2(n, cap):
    p = 4
    while p * 2 <= cap and abs(p * 2 - n) <= abs(p - n):
        p *= 2
    return min(p, cap)


def _encode(img, fmt):
    buf = io.BytesIO()
    img.save(buf, 'DDS', pixel_format='DXT1' if fmt == FMT_DXT1 else 'DXT5')
    raw = buf.getvalue()
    off = 148 if raw[84:88] == b'DX10' else 128
    return raw[off:]


def _encode_chain(img, fmt):
    w, h = img.size
    out, levels = [], 0
    while True:
        lvl = img if levels == 0 else img.resize((w, h), Image.LANCZOS)
        out.append(_encode(lvl, fmt))
        levels += 1
        if w <= 4 or h <= 4:
            break
        w, h = w // 2, h // 2
    return b''.join(out), levels


def budget_for(name, rules, default):
    for pattern, size in rules:
        if re.search(pattern, name, re.I):
            return size
    return default


def plan(textures, max_size=1024, rules=(), budget=None):
    """Decide tamano y formato final de cada textura. Si se da budget (bytes), sigue
    reduciendo a la mitad las texturas mas grandes (primero las menos visibles) hasta entrar."""
    out = []
    for t in textures:
        if KEEP.search(t.name) or fmt_name(t.fmt) not in ('DXT1', 'DXT5', 'A8R8G8B8'):
            out.append([t, t.w, t.h, t.fmt, False])
            continue
        cap = budget_for(t.name, rules, max_size)
        fmt = FMT_DXT5 if t.fmt == FMT_ARGB else t.fmt
        out.append([t, _pow2(t.w, cap), _pow2(t.h, cap), fmt, True])

    def size(e):
        t, w, h, fmt, edit = e
        return chain_bytes(fmt, w, h, _levels(w, h)) if edit else t.size

    # texturas hermanas (sign_1, sign_2...) se reducen juntas para que no queden disparejas
    groups = {}
    for e in out:
        if e[4]:
            groups.setdefault(re.sub(r'[_\s-]*\d+$', '', e[0].name.lower()), []).append(e)
    while budget and sum(size(e) for e in out) > budget:
        cands = [g for g in groups.values() if min(min(e[1], e[2]) for e in g) > 256]
        if not cands:
            break
        # la mas grande primero; las poco visibles (motor, barro, spec/normal) cuentan doble
        # y los rotulos la mitad
        def weight(g):
            n = g[0][0].name
            return max(size(e) for e in g) * (2 if LOW_PRIORITY.search(n) else 0.5 if HIGH_PRIORITY.search(n) else 1)
        g = max(cands, key=weight)
        for e in g:
            e[1], e[2] = e[1] // 2, e[2] // 2
    return out


def _levels(w, h):
    n = 1
    while w > 4 and h > 4:
        w, h, n = w // 2, h // 2, n + 1
    return n


def optimize_textures(res, textures, max_size=1024, rules=(), budget=None, log=print):
    """Reduce texturas grandes, las pasa a potencia de 2 y DXT, y genera mipmaps.
    Reconstruye el segmento grafico del recurso (solo vale si ahi solo hay datos de textura)."""
    blocks = []
    for t, nw, nh, fmt, edit in plan(textures, max_size, rules, budget):
        changed = edit and ((nw, nh) != (t.w, t.h) or fmt != t.fmt or (t.levels < 2 and min(t.w, t.h) > 4))
        if not changed:
            blocks.append((t, t.data(), t.w, t.h, t.fmt, t.levels, t.stride))
            continue
        img = t.image()
        if (nw, nh) != (t.w, t.h):
            img = img.resize((nw, nh), Image.LANCZOS)
        data, levels = _encode_chain(img, fmt)
        stride = max(1, (nw + 3) // 4) * (8 if fmt == FMT_DXT1 else 16)
        log('  %-36s %5dx%-5d %-8s mips=%-2d -> %5dx%-5d %-4s mips=%-2d  %5.2f MB -> %5.2f MB' % (
            t.name, t.w, t.h, fmt_name(t.fmt), t.levels, nw, nh, fmt_name(fmt), levels,
            t.size / 2**20, len(data) / 2**20))
        blocks.append((t, data, nw, nh, fmt, levels, stride))

    offsets, flags, total = layout_pages([len(b[1]) for b in blocks])
    gfx = bytearray(total)
    for (t, data, w, h, fmt, levels, stride), off in zip(blocks, offsets):
        gfx[off:off + len(data)] = data
        buf, o = res.seg(t.ptr)
        struct.pack_into('<HHHHI', buf, o + 0x50, w, h, 1, stride, fmt)
        buf[o + 0x5D] = levels
        struct.pack_into('<Q', buf, o + 0x70, GFX_BASE + off)
    res.gfx = gfx
    res.gfx_flags = (res.gfx_flags & 0xF0000000) | flags
