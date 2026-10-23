const zlib = require('zlib');
const fs = require('fs');

const W = 900, H = 386;
const rgba = Buffer.alloc(W * H * 4, 0);

function setPixel(x, y, r, g, b, a) {
  if (x < 0 || x >= W || y < 0 || y >= H) return;
  const i = (y * W + x) * 4;
  if (a >= 255) {
    rgba[i] = r; rgba[i+1] = g; rgba[i+2] = b; rgba[i+3] = a;
    return;
  }
  const inv = 255 - a;
  rgba[i] = (r * a + rgba[i] * inv) / 255;
  rgba[i+1] = (g * a + rgba[i+1] * inv) / 255;
  rgba[i+2] = (b * a + rgba[i+2] * inv) / 255;
  rgba[i+3] = a + (rgba[i+3] * inv) / 255;
}

function fillRect(x, y, w, h, r, g, b, a) {
  const x0 = Math.max(0, Math.floor(x));
  const y0 = Math.max(0, Math.floor(y));
  const x1 = Math.min(W, Math.ceil(x + w));
  const y1 = Math.min(H, Math.ceil(y + h));
  for (let yy = y0; yy < y1; yy++) {
    for (let xx = x0; xx < x1; xx++) {
      setPixel(xx, yy, r, g, b, a);
    }
  }
}

function lerp(a, b, t) { return a + (b - a) * t; }
function lerpColor(c1, c2, t) {
  return [lerp(c1[0], c2[0], t), lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t)];
}

// 1. 渐变背景
const topColor = [11, 27, 61];
const botColor = [18, 58, 107];
for (let y = 0; y < H; y++) {
  const t = y / (H - 1);
  const c = lerpColor(topColor, botColor, t);
  for (let x = 0; x < W; x++) setPixel(x, y, c[0], c[1], c[2], 255);
}

// 2. 网格线
for (let x = 0; x <= W; x += 45) {
  for (let y = 0; y < H; y++) setPixel(x, y, 100, 180, 255, 25);
}
for (let y = 0; y <= H; y += 45) {
  for (let x = 0; x < W; x++) setPixel(x, y, 100, 180, 255, 25);
}

// 3. 左侧加深
for (let x = 0; x < W * 0.45; x++) {
  const t = 1 - x / (W * 0.45);
  const a = Math.floor(140 * t);
  for (let y = 0; y < H; y++) setPixel(x, y, 5, 15, 40, a);
}

// 4. 右侧光晕
const cx = W - 420, cy = H / 2 - 50;
for (let y = 0; y < H; y++) {
  for (let x = 0; x < W; x++) {
    const dx = x - cx, dy = y - cy;
    const d = Math.sqrt(dx*dx + dy*dy);
    if (d < 260) {
      const a = Math.floor(90 * Math.pow(1 - d / 260, 1.8));
      setPixel(x, y, 0, 229, 255, a);
    }
  }
}

// 5. 人物剪影
const headX = W - 280, headY = H / 2 - 60;
// 头部
for (let y = headY - 30; y <= headY + 30; y++) {
  for (let x = headX - 30; x <= headX + 30; x++) {
    const d = Math.sqrt((x - headX)**2 + (y - headY)**2);
    if (d <= 28) setPixel(x, y, 15, 35, 75, 230);
  }
}
// 身体（梯形）
function fillPoly(points, r, g, b, a) {
  let minY = H, maxY = 0;
  for (const p of points) { minY = Math.min(minY, p[1]); maxY = Math.max(maxY, p[1]); }
  for (let y = Math.max(0, minY); y <= Math.min(H-1, maxY); y++) {
    const intersections = [];
    for (let i = 0; i < points.length; i++) {
      const p1 = points[i], p2 = points[(i+1) % points.length];
      if ((p1[1] <= y && p2[1] > y) || (p2[1] <= y && p1[1] > y)) {
        const t = (y - p1[1]) / (p2[1] - p1[1]);
        intersections.push(p1[0] + t * (p2[0] - p1[0]));
      }
    }
    intersections.sort((a, b) => a - b);
    for (let i = 0; i < intersections.length; i += 2) {
      const x0 = Math.max(0, Math.floor(intersections[i]));
      const x1 = Math.min(W-1, Math.ceil(intersections[i+1]));
      for (let x = x0; x <= x1; x++) setPixel(x, y, r, g, b, a);
    }
  }
}
fillPoly([[headX-35, headY+25], [headX+35, headY+25], [headX+70, H+20], [headX-70, H+20]], 15, 35, 75, 230);
fillPoly([[headX+30, headY+40], [headX+90, headY-20], [headX+100, headY-5], [headX+40, headY+60]], 25, 50, 95, 220);

// 6. 漂浮元素
function drawDoc(x, y, s, r, g, b, a) {
  fillRect(x, y, s, s * 1.3, r, g, b, a);
  // 高光线
  for (let yy = y + 15; yy <= y + 16; yy++) for (let xx = x + 8; xx <= x + s - 8; xx++) setPixel(xx, yy, 100, 180, 255, 180);
  for (let yy = y + 25; yy <= y + 26; yy++) for (let xx = x + 8; xx <= x + s - 8; xx++) setPixel(xx, yy, 100, 180, 255, 180);
  for (let yy = y + 35; yy <= y + 36; yy++) for (let xx = x + 8; xx <= x + s - 12; xx++) setPixel(xx, yy, 100, 180, 255, 180);
  // 边框
  for (let xx = x; xx <= x + s; xx++) { setPixel(xx, y, 0, 229, 255, 255); setPixel(xx, y + s*1.3, 0, 229, 255, 255); }
  for (let yy = y; yy <= y + s*1.3; yy++) { setPixel(x, yy, 0, 229, 255, 255); setPixel(x + s, yy, 0, 229, 255, 255); }
}
function drawRoundRect(x, y, w, h, radius, r, g, b, a) {
  for (let yy = y; yy <= y + h; yy++) {
    for (let xx = x; xx <= x + w; xx++) {
      let dx = 0, dy = 0;
      if (xx < x + radius) dx = x + radius - xx;
      else if (xx > x + w - radius) dx = xx - (x + w - radius);
      if (yy < y + radius) dy = y + radius - yy;
      else if (yy > y + h - radius) dy = yy - (y + h - radius);
      const d = Math.sqrt(dx*dx + dy*dy);
      if (d <= radius || (xx >= x + radius && xx <= x + w - radius) || (yy >= y + radius && yy <= y + h - radius)) {
        setPixel(xx, yy, r, g, b, a);
      }
    }
  }
}
function drawChat(x, y, w, h) {
  drawRoundRect(x, y, w, h, 8, 0, 229, 255, 165);
  // 小尾巴
  fillPoly([[x+10, y+h], [x+20, y+h+10], [x+30, y+h]], 0, 229, 255, 165);
  // 边框
  for (let xx = x; xx <= x + w; xx++) { setPixel(xx, y, 255, 255, 255, 200); setPixel(xx, y+h, 255, 255, 255, 200); }
  for (let yy = y; yy <= y + h; yy++) { setPixel(x, yy, 255, 255, 255, 200); setPixel(x+w, yy, 255, 255, 255, 200); }
  for (let i = 0; i < 10; i++) {
    setPixel(x + 20 - i, y + h + i, 255, 255, 255, 200);
    setPixel(x + 20 + i, y + h + i, 255, 255, 255, 200);
  }
}
function drawGear(x, y, radius) {
  const teeth = 8;
  const pts = [];
  for (let i = 0; i < teeth * 2; i++) {
    const angle = 2 * Math.PI * i / (teeth * 2) - Math.PI / 2;
    const r = i % 2 === 0 ? radius : radius * 0.7;
    pts.push([x + r * Math.cos(angle), y + r * Math.sin(angle)]);
  }
  fillPoly(pts, 255, 179, 71, 190);
  // 边框
  for (let i = 0; i < pts.length; i++) {
    const p1 = pts[i], p2 = pts[(i+1) % pts.length];
    const steps = Math.max(Math.abs(p2[0]-p1[0]), Math.abs(p2[1]-p1[1]));
    for (let t = 0; t <= steps; t++) {
      const px = Math.round(p1[0] + (p2[0]-p1[0]) * t / steps);
      const py = Math.round(p1[0] + (p2[1]-p1[1]) * t / steps);
      // 简单描边可省略，避免复杂
    }
  }
  // 中心孔
  for (let yy = y - radius*0.35; yy <= y + radius*0.35; yy++) {
    for (let xx = x - radius*0.35; xx <= x + radius*0.35; xx++) {
      if ((xx-x)**2 + (yy-y)**2 <= (radius*0.35)**2) setPixel(xx, yy, 11, 27, 61, 240);
    }
  }
}
function drawChart(x, y, s) {
  fillRect(x, y, s, s, 255, 255, 255, 30);
  for (let xx = x; xx <= x + s; xx++) { setPixel(xx, y, 0, 229, 255, 190); setPixel(xx, y+s, 0, 229, 255, 190); }
  for (let yy = y; yy <= y + s; yy++) { setPixel(x, yy, 0, 229, 255, 190); setPixel(x+s, yy, 0, 229, 255, 190); }
  const heights = [s*0.25, s*0.5, s*0.35, s*0.7];
  const barW = s / 5;
  heights.forEach((h, i) => {
    fillRect(x + 6 + i * barW, y + s - 6 - h, barW - 3, h, 0, 229, 255, 200);
  });
}
function drawLine(x1, y1, x2, y2, r, g, b, a) {
  const steps = Math.max(Math.abs(x2-x1), Math.abs(y2-y1));
  for (let i = 0; i <= steps; i++) {
    const t = i / steps;
    setPixel(Math.round(x1 + (x2-x1)*t), Math.round(y1 + (y2-y1)*t), r, g, b, a);
  }
}

drawDoc(W - 180, 60, 42, 255, 255, 255, 200);
drawChat(W - 130, 140, 70, 42);
drawGear(W - 220, 210, 28);
drawChart(W - 150, 250, 60);
drawDoc(W - 340, 90, 36, 255, 255, 255, 200);
drawChat(W - 300, 180, 60, 34);

// 7. 连接线
drawLine(W - 280, H/2 - 20, W - 180, 80, 0, 229, 255, 120);
drawLine(W - 250, H/2 + 10, W - 130, 160, 0, 229, 255, 120);
drawLine(W - 260, H/2 + 40, W - 210, 210, 0, 229, 255, 120);

// 8. PNG 编码
function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type);
  const crc = zlib.crc32(Buffer.concat([typeBuf, data]));
  const crcBuf = Buffer.alloc(4); crcBuf.writeUInt32BE(crc >>> 0, 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}
const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
const rowSize = W * 4;
const raw = Buffer.alloc(H * (rowSize + 1));
for (let y = 0; y < H; y++) {
  raw[y * (rowSize + 1)] = 0;
  for (let x = 0; x < W; x++) {
    const src = (y * W + x) * 4;
    const dst = y * (rowSize + 1) + 1 + x * 4;
    raw[dst] = rgba[src]; raw[dst+1] = rgba[src+1]; raw[dst+2] = rgba[src+2]; raw[dst+3] = rgba[src+3];
  }
}
const compressed = zlib.deflateSync(raw, { level: 9 });
const png = Buffer.concat([sig, chunk('IHDR', ihdr), chunk('IDAT', compressed), chunk('IEND', Buffer.alloc(0))]);
const outPath = 'C:\\Users\\cbs\\Desktop\\公众号推文\\cover-ai-empowerment.png';
fs.writeFileSync(outPath, png);
console.log('Saved:', outPath);
