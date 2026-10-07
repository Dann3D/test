"""Lectura/escritura de recursos RSC7 de GTA V (ytd, yft, ydd, ydr...)."""
import struct
import zlib

MAGIC = b'RSC7'
SYS_BASE = 0x50000000
GFX_BASE = 0x60000000


def flags_size(f):
    base = 0x2000 << (f & 0xF)
    return (base * ((f >> 4) & 0x1) * 16 + base * ((f >> 5) & 0x3) * 8 +
            base * ((f >> 7) & 0xF) * 4 + base * ((f >> 11) & 0x3F) * 2 +
            base * ((f >> 17) & 0x7F) + (base // 2) * ((f >> 24) & 0x1) +
            (base // 4) * ((f >> 25) & 0x1) + (base // 8) * ((f >> 26) & 0x1) +
            (base // 16) * ((f >> 27) & 0x1))


class Resource:
    def __init__(self, path):
        raw = open(path, 'rb').read()
        magic, self.version, self.sys_flags, self.gfx_flags = struct.unpack_from('<4sIII', raw, 0)
        if magic != MAGIC:
            raise ValueError('%s no es un recurso RSC7' % path)
        data = zlib.decompress(raw[16:], -15)
        ss = flags_size(self.sys_flags)
        self.sys = bytearray(data[:ss])
        self.gfx = bytearray(data[ss:ss + flags_size(self.gfx_flags)])
        self.packed_size = len(raw)

    def seg(self, ptr):
        top = ptr >> 28
        if top == 5:
            return self.sys, ptr & 0x0FFFFFFF
        if top == 6:
            return self.gfx, ptr & 0x0FFFFFFF
        raise ValueError('puntero invalido %#x' % ptr)

    def read(self, ptr, n):
        buf, o = self.seg(ptr)
        return bytes(buf[o:o + n])

    def u16(self, ptr):
        return struct.unpack('<H', self.read(ptr, 2))[0]

    def u32(self, ptr):
        return struct.unpack('<I', self.read(ptr, 4))[0]

    def u64(self, ptr):
        return struct.unpack('<Q', self.read(ptr, 8))[0]

    def cstr(self, ptr):
        buf, o = self.seg(ptr)
        end = buf.index(0, o)
        return buf[o:end].decode('latin1')

    def ptr_list(self, ptr):
        """ResourcePointerList64: (puntero, count u16, capacity u16)."""
        if not ptr:
            return []
        p, c = struct.unpack('<QH', self.read(ptr, 10))
        return list(struct.unpack('<%dQ' % c, self.read(p, 8 * c))) if c else []

    def save(self, path, level=9):
        body = zlib.compress(bytes(self.sys) + bytes(self.gfx), level)[2:-4]  # deflate crudo
        with open(path, 'wb') as f:
            f.write(struct.pack('<4sIII', MAGIC, self.version, self.sys_flags, self.gfx_flags))
            f.write(body)
        return 16 + len(body)


# multiplicadores de pagina que admite RSC7 y cuantas paginas de cada uno caben en los flags
PAGE_KINDS = [(16, 1, 4), (8, 3, 5), (4, 15, 7), (2, 63, 11), (1, 127, 17),
              (0.5, 1, 24), (0.25, 1, 25), (0.125, 1, 26), (0.0625, 1, 27)]


def _align(n, a):
    return (n + a - 1) & ~(a - 1)


def _pack(sizes, order, cap, base, align):
    """First-fit decreasing en paginas de tamano cap; luego encoge cada pagina al minimo posible."""
    bins = []  # [usado, [(indice, offset)]]
    for i in order:
        for b in bins:
            off = _align(b[0], align)
            if off + sizes[i] <= cap:
                b[1].append((i, off))
                b[0] = off + sizes[i]
                break
        else:
            bins.append([sizes[i], [(i, 0)]])
    left = {m: n for m, n, _ in PAGE_KINDS}
    pages = []
    for used, items in sorted(bins, key=lambda b: -b[0]):
        for m, _, _ in reversed(PAGE_KINDS):
            size = int(base * m)
            if size >= used and left[m] > 0:
                left[m] -= 1
                pages.append((size, m, items))
                break
        else:
            return None
    pages.sort(key=lambda p: -p[0])
    offsets, pos, flags = [0] * len(sizes), 0, 0
    for size, m, items in pages:
        for i, off in items:
            offsets[i] = pos + off
        pos += size
    for m, _, bit in PAGE_KINDS:
        flags |= (sum(1 for p in pages if p[1] == m)) << bit
    return offsets, flags, pos


def layout_pages(sizes, align=16):
    """Coloca bloques en paginas RSC7 sin cruzar bordes, buscando el menor tamano total.
    Devuelve (offsets, flags_sin_version, tamano_total)."""
    if not sizes:
        return [], 1 << 17, 0x2000
    order = sorted(range(len(sizes)), key=lambda i: -sizes[i])
    best = None
    for shift in range(16):
        base = 0x2000 << shift
        for top in (1, 2, 4, 8, 16):
            if base * top < sizes[order[0]]:
                continue
            r = _pack(sizes, order, base * top, base, align)
            if r and (best is None or r[2] < best[2]):
                best = (r[0], r[1] | shift, r[2])
    return best
