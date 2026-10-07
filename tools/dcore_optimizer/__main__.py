"""DCORE Optimizer: analiza y comprime recursos de GTA V / FiveM (carros, ropa, mapas).

  python -m dcore_optimizer analizar <archivo|carpeta>
  python -m dcore_optimizer comprimir <carpeta_o_archivo> <salida> [--max 1024] [--regla engine=512]
"""
import argparse
import os
import shutil

from .models import drawable_stats, embedded_dictionary
from .rsc7 import SYS_BASE, Resource
from .textures import dictionary_textures, fmt_name, optimize_textures

DEFAULT_RULES = [(r'engine|motor|interior|_int\b|mud|dirt', 512)]
FIVEM_LIMIT = 16 * 2**20  # FiveM avisa "oversized asset" arriba de esto


def root_drawables(res, ext):
    if ext == '.yft':
        return [res.u64(SYS_BASE + 0x30)]
    if ext == '.ydr':
        return [SYS_BASE]
    if ext == '.ydd':
        return res.ptr_list(SYS_BASE + 0x30)
    return []


def analyze(path, log=print):
    ext = os.path.splitext(path)[1].lower()
    res = Resource(path)
    warnings = []
    log('\n== %s  (%.1f MB en disco, RAM %.1f MB, VRAM %.1f MB)' % (
        os.path.basename(path), res.packed_size / 2**20, len(res.sys) / 2**20, len(res.gfx) / 2**20))
    if len(res.gfx) > FIVEM_LIMIT:
        warnings.append('VRAM > 16 MB: FiveM lo marca como "oversized asset" (tirones y perdida de texturas)')
    if len(res.sys) > FIVEM_LIMIT:
        warnings.append('RAM > 16 MB: modelo muy pesado para streaming')
    dicts = [SYS_BASE] if ext == '.ytd' else []
    for d in root_drawables(res, ext):
        lods = drawable_stats(res, d)
        for l in lods:
            if l['geoms']:
                log('  LOD %-5s dist=%6.0f  geoms=%4d  tris=%8d  verts=%8d  (%.1f MB)' % (
                    l['name'], l['dist'], l['geoms'], l['tris'], l['verts'], l['vbytes'] / 2**20))
        hi = lods[0]['tris']
        if hi > 150000:
            warnings.append('%d triangulos en HIGH (recomendado < 150k para carro, < 50k para ropa)' % hi)
        if not any(l['geoms'] for l in lods[1:]):
            warnings.append('sin LODs (MED/LOW/VLOW): se dibuja el modelo completo a cualquier distancia')
        emb = embedded_dictionary(res, d)
        if emb:
            dicts.append(emb)
    for dp in dicts:
        ts = dictionary_textures(res, dp)
        big = [t for t in ts if max(t.w, t.h) > 1024]
        nomip = [t for t in ts if t.levels < 2 and min(t.w, t.h) > 4]
        npot = [t for t in ts if t.w & (t.w - 1) or t.h & (t.h - 1)]
        log('  %d texturas, %.1f MB' % (len(ts), sum(t.size for t in ts) / 2**20))
        for t in sorted(ts, key=lambda t: -t.size)[:12]:
            log('    %-36s %5dx%-5d %-9s mips=%-2d %6.2f MB' % (t.name, t.w, t.h, fmt_name(t.fmt), t.levels, t.size / 2**20))
        if big:
            warnings.append('%d texturas mayores a 1024px' % len(big))
        if nomip:
            warnings.append('%d texturas sin mipmaps (titilan de lejos y gastan mas VRAM al dibujar)' % len(nomip))
        if npot:
            warnings.append('%d texturas que no son potencia de 2 (%s)' % (len(npot), ', '.join(t.name for t in npot[:4])))
    for w in warnings:
        log('  ! ' + w)
    return warnings


def compress_file(src, dst, max_size, rules, budget, log=print):
    res = Resource(src)
    before = len(res.gfx)
    optimize_textures(res, dictionary_textures(res, SYS_BASE), max_size, rules, budget, log)
    packed = res.save(dst)
    log('  %s: VRAM %.1f MB -> %.1f MB, disco %.1f MB -> %.1f MB' % (
        os.path.basename(src), before / 2**20, len(res.gfx) / 2**20, res.packed_size / 2**20, packed / 2**20))


def iter_files(path):
    if os.path.isfile(path):
        yield path, os.path.basename(path)
        return
    for root, _, names in os.walk(path):
        for n in sorted(names):
            full = os.path.join(root, n)
            yield full, os.path.relpath(full, path)


def main():
    ap = argparse.ArgumentParser(prog='dcore_optimizer', description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest='cmd', required=True)
    a = sub.add_parser('analizar')
    a.add_argument('ruta')
    c = sub.add_parser('comprimir')
    c.add_argument('ruta')
    c.add_argument('salida')
    c.add_argument('--max', type=int, default=1024, help='tamano maximo de textura (default 1024)')
    c.add_argument('--regla', action='append', default=[], metavar='PATRON=TAM',
                   help='limite por nombre de textura, ej: sign=512 (se puede repetir)')
    c.add_argument('--presupuesto', type=float, default=15.0, metavar='MB',
                   help='VRAM maxima por ytd; reduce mas si hace falta (default 15, 0 = sin limite)')
    args = ap.parse_args()

    exts = ('.ytd', '.yft', '.ydr', '.ydd')
    if args.cmd == 'analizar':
        for full, _ in iter_files(args.ruta):
            if full.lower().endswith(exts):
                analyze(full)
        return
    rules = [(p, int(s)) for p, s in (r.split('=', 1) for r in args.regla)] + DEFAULT_RULES
    single = os.path.isfile(args.ruta)
    for full, rel in iter_files(args.ruta):
        dst = args.salida if single else os.path.join(args.salida, rel)
        os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
        if full.lower().endswith('.ytd'):
            compress_file(full, dst, args.max, rules, args.presupuesto * 2**20 or None)
        elif not single:
            shutil.copy2(full, dst)


if __name__ == '__main__':
    main()
