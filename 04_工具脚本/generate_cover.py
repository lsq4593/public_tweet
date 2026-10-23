from PIL import Image, ImageDraw, ImageFilter
import math

W, H = 900, 386
img = Image.new('RGB', (W, H), '#0B1B3D')
draw = ImageDraw.Draw(img)

# 深蓝渐变背景
def draw_gradient(draw, w, h, color_top, color_bottom):
    for y in range(h):
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * y / h)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * y / h)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * y / h)
        draw.line([(0, y), (w, y)], fill=(r, g, b))

draw_gradient(draw, W, H, (11, 27, 61), (18, 58, 107))

# 左侧文字区域加深（半透明深蓝遮罩）
overlay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
overlay_draw = ImageDraw.Draw(overlay)
overlay_draw.rectangle([0, 0, int(W * 0.38), H], fill=(5, 15, 40, 120))
img = Image.alpha_composite(img.convert('RGBA'), overlay)

# 绘制 subtle grid / 光点
draw = ImageDraw.Draw(img)
for i in range(0, W, 45):
    draw.line([(i, 0), (i, H)], fill=(255, 255, 255), width=1)
    # 降低不透明度效果：用叠加层处理更简单，这里直接画淡线
    # 重画淡线
for i in range(0, H, 45):
    draw.line([(0, i), (W, i)], fill=(255, 255, 255), width=1)

# 用带透明度的叠加层让网格变淡
grid_overlay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
grid_draw = ImageDraw.Draw(grid_overlay)
for i in range(0, W, 45):
    grid_draw.line([(i, 0), (i, H)], fill=(100, 180, 255, 25), width=1)
for i in range(0, H, 45):
    grid_draw.line([(0, i), (W, i)], fill=(100, 180, 255, 25), width=1)
img = Image.alpha_composite(img, grid_overlay)

# 右侧 AI 光晕
glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
glow_draw = ImageDraw.Draw(glow)
for r in range(250, 0, -5):
    alpha = int(30 * (r / 250) ** 2)
    glow_draw.ellipse([W - 420 - r, H // 2 - 50 - r, W - 420 + r, H // 2 - 50 + r], fill=(0, 229, 255, alpha))
img = Image.alpha_composite(img, glow)

# 绘制"人"的剪影（右侧，性别中性，背面）
person = Image.new('RGBA', (W, H), (0, 0, 0, 0))
pd = ImageDraw.Draw(person)
# 简化的头部和肩膀剪影
head_x, head_y = W - 280, H // 2 - 60
pd.ellipse([head_x - 28, head_y - 28, head_x + 28, head_y + 28], fill=(20, 40, 80, 220))
# 身体
pd.polygon([
    (head_x - 35, head_y + 25),
    (head_x + 35, head_y + 25),
    (head_x + 70, H + 20),
    (head_x - 70, H + 20),
], fill=(15, 35, 75, 230))
# 手臂抬起指向界面
pd.polygon([
    (head_x + 30, head_y + 40),
    (head_x + 90, head_y - 20),
    (head_x + 100, head_y - 5),
    (head_x + 40, head_y + 60),
], fill=(25, 50, 95, 220))
img = Image.alpha_composite(img, person)

# 漂浮 AI 元素（文档、对话框、齿轮等）
elements = Image.new('RGBA', (W, H), (0, 0, 0, 0))
ed = ImageDraw.Draw(elements)

def draw_doc(x, y, size):
    ed.rectangle([x, y, x + size, y + size * 1.3], fill=(255, 255, 255, 200), outline=(0, 229, 255, 255), width=2)
    ed.line([x + 8, y + 15, x + size - 8, y + 15], fill=(100, 180, 255, 180), width=2)
    ed.line([x + 8, y + 25, x + size - 8, y + 25], fill=(100, 180, 255, 180), width=2)
    ed.line([x + 8, y + 35, x + size - 12, y + 35], fill=(100, 180, 255, 180), width=2)

def draw_chat(x, y, w, h):
    ed.rounded_rectangle([x, y, x + w, y + h], radius=8, fill=(0, 229, 255, 160), outline=(255, 255, 255, 200), width=1)
    ed.polygon([(x + 10, y + h), (x + 20, y + h + 10), (x + 30, y + h)], fill=(0, 229, 255, 160))

def draw_gear(x, y, r):
    points = []
    teeth = 8
    for i in range(teeth * 2):
        angle = 2 * math.pi * i / (teeth * 2) - math.pi / 2
        radius = r if i % 2 == 0 else r * 0.7
        px = x + radius * math.cos(angle)
        py = y + radius * math.sin(angle)
        points.append((px, py))
    ed.polygon(points, fill=(255, 179, 71, 180), outline=(255, 255, 255, 150), width=1)
    ed.ellipse([x - r * 0.35, y - r * 0.35, x + r * 0.35, y + r * 0.35], fill=(11, 27, 61, 220))

def draw_chart(x, y, size):
    ed.rectangle([x, y, x + size, y + size], fill=(255, 255, 255, 30), outline=(0, 229, 255, 180), width=2)
    bar_w = size // 5
    heights = [size * 0.25, size * 0.5, size * 0.35, size * 0.7]
    for i, h in enumerate(heights):
        bx = x + 6 + i * bar_w
        by = y + size - 6 - h
        ed.rectangle([bx, by, bx + bar_w - 3, y + size - 6], fill=(0, 229, 255, 180))

draw_doc(W - 180, 60, 42)
draw_chat(W - 130, 140, 70, 42)
draw_gear(W - 220, 210, 28)
draw_chart(W - 150, 250, 60)
draw_doc(W - 340, 90, 36)
draw_chat(W - 300, 180, 60, 34)

# 连接人与元素的光线
ed.line([(W - 280, H // 2 - 20), (W - 180, 80)], fill=(0, 229, 255, 120), width=2)
ed.line([(W - 250, H // 2 + 10), (W - 130, 160)], fill=(0, 229, 255, 120), width=2)
ed.line([(W - 260, H // 2 + 40), (W - 210, 210)], fill=(0, 229, 255, 120), width=2)

img = Image.alpha_composite(img, elements)

# 加一层轻微模糊让画面更柔和
img = img.filter(ImageFilter.GaussianBlur(radius=0.3))

# 转回 RGB 保存
img_rgb = img.convert('RGB')
out_path = r'C:\Users\cbs\Desktop\公众号推文\cover-ai-empowerment.png'
img_rgb.save(out_path, 'PNG', quality=95)
print('Saved:', out_path)
