"""Estadisticas de geometria de drawables (yft/ydr) para detectar modelos pesados."""
import struct

LOD_NAMES = ('HIGH', 'MED', 'LOW', 'VLOW')


def model_stats(res, model_ptr):
    geoms = res.ptr_list(model_ptr + 0x08)
    tris = verts = vbytes = 0
    for g in geoms:
        b = res.read(g, 0x78)
        tris += struct.unpack_from('<I', b, 0x5C)[0]
        vc = struct.unpack_from('<H', b, 0x60)[0]
        verts += vc
        vbytes += vc * struct.unpack_from('<H', b, 0x70)[0]
    return len(geoms), tris, verts, vbytes


def drawable_stats(res, drawable_ptr):
    lod_dist = struct.unpack('<4f', res.read(drawable_ptr + 0x70, 16))
    lods = []
    for i, name in enumerate(LOD_NAMES):
        g = t = v = b = 0
        for m in res.ptr_list(res.u64(drawable_ptr + 0x50 + 8 * i)):
            mg, mt, mv, mb = model_stats(res, m)
            g, t, v, b = g + mg, t + mt, v + mv, b + mb
        lods.append(dict(name=name, dist=lod_dist[i], geoms=g, tris=t, verts=v, vbytes=b))
    return lods


def embedded_dictionary(res, drawable_ptr):
    sg = res.u64(drawable_ptr + 0x10)
    return res.u64(sg + 0x08) if sg else 0
