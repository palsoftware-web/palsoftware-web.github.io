import fs from 'node:fs/promises';
import path from 'node:path';
import sharp from 'sharp';

const ROOT = process.cwd();
const INPUT_DIR = path.join(ROOT, 'assets/showcase/raw');
const OUTPUT_DIR = path.join(ROOT, 'public/showcase/generated');

const CANVAS_W = 1600;
const CANVAS_H = 1200;
const PHONE_W = 560;
const PHONE_H = 1120;
const SCREEN_MARGIN = 26;
const SCREEN_W = PHONE_W - SCREEN_MARGIN * 2;
const SCREEN_H = PHONE_H - SCREEN_MARGIN * 2;

const PHONE_X = Math.round((CANVAS_W - PHONE_W) / 2);
const PHONE_Y = Math.round((CANVAS_H - PHONE_H) / 2);
const SCREEN_X = PHONE_X + SCREEN_MARGIN;
const SCREEN_Y = PHONE_Y + SCREEN_MARGIN;

function normalizeName(filename) {
  return filename.replace(/\.[^.]+$/, '').replace(/[^a-zA-Z0-9_-]+/g, '-');
}

function phoneOverlaySvg() {
  const radius = 72;
  const screenRadius = 52;
  const notchW = 170;
  const notchH = 30;
  const notchX = PHONE_X + Math.round((PHONE_W - notchW) / 2);
  const notchY = PHONE_Y + 18;

  return `
<svg width="${CANVAS_W}" height="${CANVAS_H}" viewBox="0 0 ${CANVAS_W} ${CANVAS_H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="body" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#191919"/>
      <stop offset="100%" stop-color="#050505"/>
    </linearGradient>
  </defs>

  <rect x="${PHONE_X}" y="${PHONE_Y}" width="${PHONE_W}" height="${PHONE_H}" rx="${radius}" fill="url(#body)"/>
  <rect x="${SCREEN_X}" y="${SCREEN_Y}" width="${SCREEN_W}" height="${SCREEN_H}" rx="${screenRadius}" fill="none" stroke="#0B0B0B" stroke-width="10"/>
  <rect x="${notchX}" y="${notchY}" width="${notchW}" height="${notchH}" rx="15" fill="#040404"/>
</svg>
`.trim();
}

function backgroundSvg(label) {
  const safeLabel = label.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  return `
<svg width="${CANVAS_W}" height="${CANVAS_H}" viewBox="0 0 ${CANVAS_W} ${CANVAS_H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#F4F6F8"/>
      <stop offset="100%" stop-color="#DDE4EA"/>
    </linearGradient>
    <filter id="shadow" x="-40%" y="-40%" width="180%" height="180%">
      <feDropShadow dx="0" dy="28" stdDeviation="26" flood-color="#273240" flood-opacity="0.34"/>
    </filter>
  </defs>

  <rect width="${CANVAS_W}" height="${CANVAS_H}" fill="url(#bg)"/>
  <circle cx="250" cy="220" r="300" fill="#FFFFFF" fill-opacity="0.56"/>
  <circle cx="1380" cy="1040" r="300" fill="#C8D7E6" fill-opacity="0.44"/>
  <g filter="url(#shadow)">
    <rect x="${PHONE_X}" y="${PHONE_Y}" width="${PHONE_W}" height="${PHONE_H}" rx="72" fill="#000000" fill-opacity="0.001"/>
  </g>
  <text x="80" y="1090" font-family="ui-sans-serif, -apple-system, Segoe UI, Helvetica, Arial" font-size="42" fill="#223245" fill-opacity="0.72">${safeLabel}</text>
</svg>
`.trim();
}

async function collectRawPngs(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.toLowerCase().endsWith('.png'))
    .map((entry) => path.join(dir, entry.name));
}

async function renderOne(inputPath) {
  const fileName = path.basename(inputPath);
  const base = normalizeName(fileName);
  const outPath = path.join(OUTPUT_DIR, `${base}.png`);

  const screenshot = await sharp(inputPath)
    .resize(SCREEN_W, SCREEN_H, { fit: 'cover', position: 'centre' })
    .png()
    .toBuffer();

  const composed = await sharp(Buffer.from(backgroundSvg(base)))
    .composite([
      { input: screenshot, left: SCREEN_X, top: SCREEN_Y },
      { input: Buffer.from(phoneOverlaySvg()) }
    ])
    .png({ compressionLevel: 9 })
    .toBuffer();

  await fs.writeFile(outPath, composed);
  return outPath;
}

async function main() {
  await fs.mkdir(OUTPUT_DIR, { recursive: true });

  const raws = await collectRawPngs(INPUT_DIR);
  if (raws.length === 0) {
    console.log(`No PNG files found in ${INPUT_DIR}`);
    console.log('Add screenshots to assets/showcase/raw and run: npm run docs:images');
    return;
  }

  const outputs = [];
  for (const file of raws) {
    const out = await renderOne(file);
    outputs.push(out);
  }

  console.log(`Generated ${outputs.length} showcase image(s):`);
  for (const out of outputs) {
    console.log(`- ${path.relative(ROOT, out)}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
