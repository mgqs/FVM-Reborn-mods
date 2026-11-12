import sys
sys.stdout.reconfigure(encoding="utf-8")

OX, OY = 695, 228
CX, CY = 107, 116
XOFF, YOFF = 177, 250          # spr_honglonglong_skill_3 origin（底部居中）
SC = 1.8
VCX, VCY = 170, 170            # frames 15..23 alpha 加权质心均值

rows = range(1, 6)
cases = []
for row in rows:
    for col in (3, 4, 5, 6):
        cases.append((row, col, -10))
for row in rows:
    cases.append((row, 10, -80))

print("row col |  ring centre      | boss x,y after snap | visual centre delta | grid kept | depth")
bad = 0
for row, col, dx_adj in cases:
    grid_cx = OX + col * CX + CX // 2
    grid_cy = OY + row * CY + CY // 2
    bx = grid_cx + dx_adj
    by = grid_cy + 33
    ring_x = OX + col * CX
    ring_y = OY + row * CY
    vcx = (bx - XOFF * SC) + VCX * SC
    vcy = (by - YOFF * SC) + VCY * SC
    bx += ring_x - vcx
    by += ring_y - vcy
    vcx = (bx - XOFF * SC) + VCX * SC
    vcy = (by - YOFF * SC) + VCY * SC
    kept = (int((bx - OX) // CX) == col) and (int((by - OY) // CY) == row)
    if not kept:
        bad += 1
    boss_depth = (-10 - row * 45 - col * 5) - 4.5
    print("%3d %3d | (%6.0f,%6.0f) | (%7.1f,%6.1f) | (%+5.1f,%+5.1f) | %-8s | fx %.1f < boss %.1f"
          % (row, col, ring_x, ring_y, bx, by, vcx - ring_x, vcy - ring_y, kept,
             boss_depth + 1, boss_depth))

print("grid membership failures:", bad)
print("sprite half height world px:", 311 * SC / 2, " ring outer radius:", 2.2 * CX)
