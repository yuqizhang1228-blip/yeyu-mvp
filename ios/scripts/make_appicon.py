#!/usr/bin/env python3
"""生成夜屿 App 图标 1024×1024（不透明、无圆角，符合 App Store 规范）。
品牌：夜空 #0B111D，暖月光 #FFB86C。主题「夜屿」= 夜晚的岛。
"""
from PIL import Image, ImageDraw, ImageFilter
import math, os, random

S = 1024
SS = S * 4  # 4x 超采样后缩小，边缘更顺滑

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

# ---- 背景：竖向夜空渐变 ----
top = (0x0B, 0x11, 0x1D)
bottom = (0x05, 0x08, 0x10)
mid = (0x12, 0x1A, 0x2B)
base = Image.new("RGB", (SS, SS), top)
px = base.load()
for y in range(SS):
    t = y / (SS - 1)
    # 上深 -> 中略亮(地平线辉光) -> 下深
    if t < 0.62:
        col = lerp(top, mid, (t / 0.62) ** 1.3)
    else:
        col = lerp(mid, bottom, ((t - 0.62) / 0.38))
    for x in range(SS):
        px[x, y] = col

draw = ImageDraw.Draw(base, "RGBA")

# ---- 星点 ----
random.seed(7)
for _ in range(90):
    x = random.randint(0, SS)
    y = random.randint(0, int(SS * 0.55))
    r = random.choice([1, 1, 2, 2, 3]) * 4
    a = random.randint(40, 150)
    draw.ellipse([x - r, y - r, x + r, y + r], fill=(255, 255, 255, a))

moon = (0xFF, 0xB8, 0x6C)
moon_light = (0xFF, 0xCF, 0x99)

# ---- 月亮辉光 ----
glow = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
cx, cy, R = int(SS * 0.63), int(SS * 0.34), int(SS * 0.135)
gd.ellipse([cx - R * 2.4, cy - R * 2.4, cx + R * 2.4, cy + R * 2.4],
           fill=(0xFF, 0xB8, 0x6C, 60))
glow = glow.filter(ImageFilter.GaussianBlur(SS // 18))
base = Image.alpha_composite(base.convert("RGBA"), glow).convert("RGB")
draw = ImageDraw.Draw(base, "RGBA")

# ---- 弯月（两圆相减）----
moon_layer = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
ml = ImageDraw.Draw(moon_layer)
# 渐变满月盘
for i in range(R, 0, -1):
    t = 1 - i / R
    col = lerp(moon, moon_light, t * 0.5)
    ml.ellipse([cx - i, cy - i, cx + i, cy + i], fill=col + (255,))
# 用偏移圆挖出新月
ox, oy = int(R * 0.55), int(-R * 0.18)
ml.ellipse([cx + ox - R, cy + oy - R, cx + ox + R, cy + oy + R], fill=(0, 0, 0, 0))
base = Image.alpha_composite(base.convert("RGBA"), moon_layer).convert("RGB")
draw = ImageDraw.Draw(base, "RGBA")

# ---- 水面月光倒影 ----
horizon = int(SS * 0.72)
refl = Image.new("RGBA", (SS, SS), (0, 0, 0, 0))
rd = ImageDraw.Draw(refl)
for k in range(26):
    yy = horizon + k * int(SS * 0.008)
    w = int(SS * 0.05 * (1 - k / 30))
    a = max(0, 70 - k * 3)
    rd.line([(cx - w, yy), (cx + w, yy)], fill=(0xFF, 0xCF, 0x99, a), width=6)
refl = refl.filter(ImageFilter.GaussianBlur(6))
base = Image.alpha_composite(base.convert("RGBA"), refl).convert("RGB")
draw = ImageDraw.Draw(base, "RGBA")

# ---- 小岛剪影（夜屿）----
island = (0x04, 0x06, 0x0C)
def hill(center_x, top_y, half_w, color):
    pts = []
    for i in range(0, 101):
        t = i / 100
        x = center_x - half_w + 2 * half_w * t
        # 平滑山丘曲线
        y = horizon - (top_y) * math.sin(math.pi * t)
        pts.append((x, y))
    pts += [(center_x + half_w, horizon + SS), (center_x - half_w, horizon + SS)]
    draw.polygon(pts, fill=color)

# 远岛（略亮）+ 主岛
hill(int(SS * 0.40), int(SS * 0.10), int(SS * 0.30), (0x0A, 0x0F, 0x1A))
hill(int(SS * 0.62), int(SS * 0.165), int(SS * 0.34), island)

# 水面压到岛下方铺满
draw.rectangle([0, horizon, SS, SS], fill=(0x05, 0x08, 0x10))
# 重画岛（在水面之上）
hill(int(SS * 0.40), int(SS * 0.10), int(SS * 0.30), (0x0A, 0x0F, 0x1A))
hill(int(SS * 0.62), int(SS * 0.165), int(SS * 0.34), island)
# 倒影再叠一层（在水面上）
base = Image.alpha_composite(base.convert("RGBA"), refl).convert("RGB")

# ---- 缩小输出 ----
out = base.resize((S, S), Image.LANCZOS).convert("RGB")
dst = os.path.join(os.path.dirname(__file__), "..",
                   "Yeyu/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
dst = os.path.abspath(dst)
out.save(dst, "PNG")
print("saved:", dst, out.size, out.mode)
