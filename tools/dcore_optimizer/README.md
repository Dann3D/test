# DCORE Optimizer

Analiza y comprime recursos de GTA V / FiveM (carros, ropa y mapas). Es el motor para la
seccion "Comprimir" del panel: los diccionarios de texturas (`.ytd`) tienen el mismo formato
en carros, ropa (`stream/*.ytd` de un pack de ropa) y mapeos, asi que funciona con los tres.

Requisitos: Python 3.10+ y Pillow 11.2+ (`pip install pillow`).

## Analizar

```
cd tools
python -m dcore_optimizer analizar ruta/al/recurso
```

Para cada `.ytd/.yft/.ydr/.ydd` muestra VRAM, RAM, triangulos por LOD y las texturas mas pesadas,
y avisa de lo que causa lag: texturas sin mipmaps, mayores a 1024px, no potencia de 2,
modelos sin LODs o con demasiados triangulos y archivos de mas de 16 MB ("oversized asset").

## Comprimir

```
python -m dcore_optimizer comprimir carpeta_entrada carpeta_salida [--max 1024] [--presupuesto 15] [--regla sign=1024]
```

- Pasa las texturas a potencia de 2 y como maximo `--max` px.
- Genera mipmaps a las que no tienen.
- Convierte texturas ARGB sin comprimir a DXT5 (menos las `script_rt_*`, que usan los scripts del juego).
- Si el `.ytd` sigue pasando de `--presupuesto` MB, reduce a la mitad las texturas mas grandes,
  empezando por las poco visibles (motor, barro, spec/normal) y dejando para el final los rotulos/livery.
  Texturas hermanas (`sign_1`, `sign_2`...) se reducen juntas.
- Con `--regla PATRON=TAM` fijas un maximo por nombre (regex), ej. `--regla "livery=2048"`.
- Copia el resto de archivos tal cual, asi la salida es un recurso listo.

Hoy comprime `.ytd`. Los `.yft/.ydr/.ydd` solo se analizan: reducir triangulos y crear LODs
hay que hacerlo en Blender + Sollumz (Decimate) y re-exportar.
