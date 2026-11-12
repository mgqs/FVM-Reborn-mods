"""Locate the old effect sprite in the user's screenshot by template match,
then compare the 4x4 judge centre against the red circle the user drew."""
import os, math
import numpy as np
from PIL import Image

ROOT = r"D:\gameProject\FVM-Reborn-mod"
SHOT = r"D:\DSH\home\attachments\v1\objects\b4\b4a12eddcc9b5c349f4c39a16e30cd4bb4409a9ef8bb6654225c398ad6c6645d"
FX   = os.path.join(ROOT, r"sprites\spr_honglonglong_skill_3_effect")

shot = Image.open(SHOT).convert("RGB")
S = np.asarray(shot).astype(np.float32)
print("shot", shot.size)

# --- red circle ---
r, g, b = S[:, :, 0], S[:, :, 1], S[:, :, 2]
red = (r > 150) & (g < 90) & (b < 90)
ys, xs = np.nonzero(red)
cx_red, cy_red = xs.mean(), ys.mean()
rad = np.hypot(xs - cx_red, ys - cy_red)
print("red circle centre (%.1f, %.1f) radius mean %.1f" % (cx_red, cy_red, rad.mean()))

# --- card grid: orange/brown cards ---
card = (r > 110) & (r > g + 30) & (g > b + 15)
col_prof = card.sum(axis=0)
row_prof = card.sum(axis=1)

def peaks(prof, thresh):
    out, run = [], []
    for i, v in enumerate(prof):
        if v > thresh:
            run.append(i)
        else:
            if run:
                out.append(sum(run) / len(run))
                run = []
    if run:
        out.append(sum(run) / len(run))
    return out

print("card column peaks:", [round(p, 1) for p in peaks(col_prof, col_prof.max() * 0.35)])
print("card row peaks   :", [round(p, 1) for p in peaks(row_prof, row_prof.max() * 0.35)])

# --- template match the effect frame 0 (brightest, most distinctive) ---
f0 = np.asarray(Image.open(os.path.join(FX, "e4d73617-0a36-43b7-bbfc-1640cbe6c778.png")).convert("RGBA")).astype(np.float32)
alpha = f0[:, :, 3:4] / 255.0
rgb0 = f0[:, :, :3] * alpha + 255 * (1 - alpha)   # composite on white is wrong; use luminance mask only

# use alpha as the feature, and the shot's "bright cyan glow" as cue
bright = (b > 150) & (g > 140) & (r > 110)
print("bright glow px:", int(bright.sum()))
if bright.sum() > 0:
    ys2, xs2 = np.nonzero(bright)
    print("bright glow centroid (%.1f, %.1f) bbox x%d-%d y%d-%d" % (xs2.mean(), ys2.mean(), xs2.min(), xs2.max(), ys2.min(), ys2.max()))

# cross-correlate alpha with a soft "glow strength" map of the shot
glow = (np.maximum(0, b - r) + np.maximum(0, g - r)) / 2.0
a = alpha[:, :, 0]
a = a - a.mean()
gh, gw = a.shape
best = None
for s in (1.6, 1.7, 1.8, 1.9, 2.0, 2.1):
    th, tw = int(gh * s), int(gw * s)
    tpl = np.asarray(Image.fromarray(a).resize((tw, th), Image.BILINEAR))
    tpl = tpl - tpl.mean()
    H, W = glow.shape
    for cy in range(th // 2, H - th // 2, 4):
        for cx in range(tw // 2, W - tw // 2, 4):
            patch = glow[cy - th // 2: cy + th // 2, cx - tw // 2: cx + tw // 2]
            if patch.shape != tpl.shape:
                continue
            pv = patch - patch.mean()
            den = np.sqrt((pv * pv).sum() * (tpl * tpl).sum())
            if den <= 0:
                continue
            score = float((pv * tpl).sum() / den)
            if best is None or score > best[0]:
                best = (score, cx, cy, s)
print("best effect origin in screenshot: score=%.3f at (%d,%d) scale=%.1f" % best)
score, ex, ey, s = best

# --- what the fix does ---
for sc in (1.0, 1.0703):
    nx = ex - 83 * sc
    ny = ey - 96 * sc
    print("scale %.3f -> 4x4 centre (%d, %d) | red circle (%d, %d) | delta (%+d, %+d)"
          % (sc, nx, ny, cx_red, cy_red, cx_red - nx, cy_red - ny))
