import os, struct

ROOT = r"C:\Users\18203\Desktop\跨服"

def png_size(p):
    with open(p, 'rb') as f:
        d = f.read(33)
    return struct.unpack('>II', d[16:24])

for root, dirs, files in os.walk(ROOT):
    for fn in sorted(files):
        if fn.lower().endswith('.png'):
            p = os.path.join(root, fn)
            w, h = png_size(p)
            rel = os.path.relpath(p, ROOT)
            print("%-42s %5dx%-5d %6.0f KB" % (rel, w, h, os.path.getsize(p) / 1024))
