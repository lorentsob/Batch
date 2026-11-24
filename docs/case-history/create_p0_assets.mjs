import fs from "node:fs/promises";
import path from "node:path";
import { createRequire } from "node:module";

const root = process.cwd();
const runtimeRequire = createRequire("/Users/lorentso/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/");
const sharp = runtimeRequire("sharp");
const assetsDir = path.join(root, "docs/case-history/assets");
const diagramsDir = path.join(assetsDir, "diagrams");
const annotatedDir = path.join(assetsDir, "annotated");
const compositionsDir = path.join(assetsDir, "compositions");
const runDir = path.join(root, "outputs/imagegen/generative-polish/batch-showcase-p0");

const colors = {
  bg: "#F7F8F4",
  surface: "#FFFFFF",
  surface2: "#EFF3EA",
  ink: "#172019",
  muted: "#667064",
  line: "#DDE5D9",
  green: "#2F6F45",
  greenSoft: "#DDEDDD",
  red: "#B6463B",
  redSoft: "#F4DFDD",
  neutral: "#7A8178",
  neutralSoft: "#ECEFEB",
};

const runtime = {
  oggi: path.join(assetsDir, "runtime-01-oggi-actionable.jpg"),
  batch: path.join(assetsDir, "runtime-02-batch-hub.jpg"),
  guide: path.join(assetsDir, "runtime-03-guide-browse.jpg"),
  menu: path.join(assetsDir, "runtime-04-new-preparation-menu.jpg"),
  kefico: path.join(assetsDir, "runtime-05-kefir-detail.jpg"),
};

function esc(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function wrap(text, max = 28) {
  const words = text.split(" ");
  const lines = [];
  let current = "";
  for (const word of words) {
    const next = current ? `${current} ${word}` : word;
    if (next.length > max && current) {
      lines.push(current);
      current = word;
    } else {
      current = next;
    }
  }
  if (current) lines.push(current);
  return lines;
}

function textBlock(text, x, y, opts = {}) {
  const {
    size = 30,
    weight = 500,
    color = colors.ink,
    max = 28,
    line = Math.round(size * 1.25),
    anchor = "start",
  } = opts;
  const lines = wrap(text, max);
  return `<text x="${x}" y="${y}" text-anchor="${anchor}" font-family="Inter, -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif" font-size="${size}" font-weight="${weight}" fill="${color}">
${lines.map((value, index) => `<tspan x="${x}" dy="${index === 0 ? 0 : line}">${esc(value)}</tspan>`).join("\n")}
</text>`;
}

function card(x, y, w, h, fill = colors.surface, stroke = colors.line, r = 30) {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}" stroke-width="2"/>`;
}

function pill(text, x, y, fill = colors.greenSoft, color = colors.green) {
  const w = Math.max(128, text.length * 13 + 44);
  return `<rect x="${x}" y="${y}" width="${w}" height="46" rx="23" fill="${fill}"/>
${textBlock(text, x + w / 2, y + 30, { size: 18, weight: 700, color, anchor: "middle", max: 40 })}`;
}

function arrow(x1, y1, x2, y2, color = colors.green) {
  return `<path d="M ${x1} ${y1} C ${(x1 + x2) / 2} ${y1}, ${(x1 + x2) / 2} ${y2}, ${x2} ${y2}" fill="none" stroke="${color}" stroke-width="4" stroke-linecap="round"/>
<path d="M ${x2 - 12} ${y2 - 10} L ${x2} ${y2} L ${x2 - 12} ${y2 + 10}" fill="none" stroke="${color}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>`;
}

function baseSvg(width, height, title, subtitle, body) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="${width}" height="${height}" fill="${colors.bg}"/>
${textBlock(title, 80, 92, { size: 46, weight: 800, max: 48 })}
${subtitle ? textBlock(subtitle, 82, 138, { size: 22, weight: 500, color: colors.muted, max: 90 }) : ""}
${body}
</svg>`;
}

async function writeSvg(file, svg) {
  await fs.writeFile(file, svg, "utf8");
}

async function createDiagrams() {
  await writeSvg(
    path.join(diagramsDir, "ia-oggi-batch-guide.svg"),
    baseSvg(
      1600,
      1000,
      "IA finale",
      "La navigazione passa da sezioni separate a tre superfici con ruoli chiari.",
      `
${card(95, 220, 400, 590)}
${textBlock("Oggi", 145, 292, { size: 38, weight: 800 })}
${textBlock("Agenda operativa", 145, 350, { size: 24, weight: 700, color: colors.green })}
${textBlock("Azioni in ritardo, elementi attivi, prossime cose da fare e supporto guide.", 145, 405, { size: 25, color: colors.muted, max: 24 })}
${pill("Cosa fare oggi", 145, 675)}

${card(600, 220, 400, 590)}
${textBlock("Batch", 650, 292, { size: 38, weight: 800 })}
${textBlock("Hub dei domini", 650, 350, { size: 24, weight: 700, color: colors.green })}
${textBlock("Impasti, Starter, Kefir e Ricette restano specifici ma accessibili da un unico centro.", 650, 405, { size: 25, color: colors.muted, max: 25 })}
${pill("Impasti", 650, 635)}
${pill("Starter", 650, 695, colors.neutralSoft, colors.neutral)}
${pill("Kefir", 805, 695, colors.redSoft, colors.red)}

${card(1105, 220, 400, 590)}
${textBlock("Guide", 1155, 292, { size: 38, weight: 800 })}
${textBlock("Supporto", 1155, 350, { size: 24, weight: 700, color: colors.green })}
${textBlock("Contenuti bundled, categorie, ricerca e articoli richiamabili quando aiutano l'azione.", 1155, 405, { size: 25, color: colors.muted, max: 25 })}
${pill("Cerca guide", 1155, 675, colors.neutralSoft, colors.neutral)}
${arrow(495, 515, 600, 515, colors.line)}
${arrow(1000, 515, 1105, 515, colors.line)}
`
    )
  );

  await writeSvg(
    path.join(diagramsDir, "oggi-priority-model.svg"),
    baseSvg(
      1600,
      1050,
      "Oggi priority model",
      "Oggi traduce dominio, tempo e stato in una gerarchia di attenzione.",
      `
${[
  ["1", "Overdue / critical", "Ciò che richiede azione immediata.", colors.redSoft, colors.red],
  ["2", "Azioni previste oggi", "Step, rinnovi e gestione pianificati nella giornata.", colors.greenSoft, colors.green],
  ["3", "Elementi attivi", "Routine già avviate che devono restare visibili.", colors.surface2, colors.neutral],
  ["4", "Prossime azioni future", "Preview utile senza occupare il centro della pagina.", colors.surface, colors.muted],
  ["5", "Guide e consigli", "Supporto quando chiarisce una decisione operativa.", colors.surface, colors.muted],
]
  .map((row, index) => {
    const y = 230 + index * 145;
    return `${card(160, y, 1280, 105, row[3], colors.line, 28)}
<circle cx="225" cy="${y + 52}" r="30" fill="${row[4]}"/>
${textBlock(row[0], 225, y + 62, { size: 24, weight: 800, color: "#fff", anchor: "middle" })}
${textBlock(row[1], 285, y + 45, { size: 28, weight: 800, color: colors.ink, max: 38 })}
${textBlock(row[2], 285, y + 78, { size: 22, weight: 500, color: colors.muted, max: 80 })}`;
  })
  .join("\n")}
${textBlock("Non è solo ordinamento cronologico: è una lista di attenzione.", 160, 955, { size: 28, weight: 700, color: colors.green, max: 80 })}
`
    )
  );

  await writeSvg(
    path.join(diagramsDir, "new-preparation-flow.svg"),
    baseSvg(
      1600,
      950,
      "Nuova preparazione",
      "Il selettore apre domini operativi, non semplici template.",
      `
${card(95, 300, 310, 260)}
${textBlock("Oggi", 150, 375, { size: 34, weight: 800 })}
${pill("Nuova preparazione", 150, 455)}
${arrow(405, 430, 535, 430)}

${card(535, 235, 360, 390)}
${textBlock("Scegli dominio", 585, 310, { size: 34, weight: 800 })}
${pill("Impasto", 585, 385)}
${pill("Starter", 585, 455, colors.neutralSoft, colors.neutral)}
${pill("Kefir", 585, 525, colors.redSoft, colors.red)}
${arrow(895, 430, 1025, 430)}

${card(1025, 160, 380, 170)}
${textBlock("Timeline impasto", 1075, 230, { size: 29, weight: 800 })}
${textBlock("Formula -> step -> shift", 1075, 270, { size: 22, color: colors.muted, max: 28 })}

${card(1025, 390, 380, 170)}
${textBlock("Refresh starter", 1075, 460, { size: 29, weight: 800 })}
${textBlock("Due date -> rinnovo", 1075, 500, { size: 22, color: colors.muted, max: 28 })}

${card(1025, 620, 380, 170)}
${textBlock("Kefir batch", 1075, 690, { size: 29, weight: 800 })}
${textBlock("Rinfresca -> cronologia", 1075, 730, { size: 22, color: colors.muted, max: 30 })}
`
    )
  );

  await writeSvg(
    path.join(diagramsDir, "bake-step-state-model.svg"),
    baseSvg(
      1600,
      950,
      "BakeStep state model",
      "Il tempo può rendere uno step in ritardo, ma non può completarlo.",
      `
${card(150, 370, 280, 150, colors.surface)}
${textBlock("pending", 290, 455, { size: 34, weight: 800, anchor: "middle" })}
${card(650, 260, 280, 150, colors.greenSoft)}
${textBlock("running", 790, 345, { size: 34, weight: 800, color: colors.green, anchor: "middle" })}
${card(1170, 260, 280, 150, colors.greenSoft)}
${textBlock("done", 1310, 345, { size: 34, weight: 800, color: colors.green, anchor: "middle" })}
${card(1170, 560, 280, 150, colors.neutralSoft)}
${textBlock("skipped", 1310, 645, { size: 34, weight: 800, color: colors.neutral, anchor: "middle" })}
${arrow(430, 445, 650, 335)}
${arrow(930, 335, 1170, 335)}
${arrow(430, 445, 1170, 635, colors.neutral)}
${arrow(930, 335, 1170, 635, colors.neutral)}
${card(150, 650, 610, 130, colors.redSoft, colors.red)}
${textBlock("Overdue è una lettura UI derivata, non uno status salvato.", 195, 722, { size: 26, weight: 700, color: colors.red, max: 42 })}
${card(845, 650, 610, 130, colors.surface2)}
${textBlock("actualStart e actualEnd restano separati dal piano.", 890, 722, { size: 26, weight: 700, color: colors.green, max: 42 })}
`
    )
  );

  await writeSvg(
    path.join(diagramsDir, "kefir-lifecycle-flow.svg"),
    baseSvg(
      1800,
      1050,
      "Kefir lifecycle",
      "Il kefir diventa un dominio operativo: stato, eventi, archivio e confronto.",
      `
${[
  ["Kefico overdue", "stato derivato", colors.redSoft, colors.red],
  ["Rinfresca", "azione primaria", colors.greenSoft, colors.green],
  ["KefirEvent", "evento automatico", colors.surface2, colors.neutral],
  ["Cronologia", "memoria leggibile", colors.surface, colors.muted],
  ["Archivia", "resta consultabile", colors.neutralSoft, colors.neutral],
  ["Nuovo batch", "derivazione", colors.greenSoft, colors.green],
  ["Confronta", "lineage context", colors.surface, colors.muted],
]
  .map((item, i) => {
    const x = 95 + (i % 4) * 420;
    const y = i < 4 ? 275 : 630;
    return `${card(x, y, 330, 170, item[2])}
${textBlock(item[0], x + 36, y + 72, { size: 30, weight: 800, color: item[3], max: 17 })}
${textBlock(item[1], x + 36, y + 112, { size: 21, color: colors.muted, max: 22 })}`;
  })
  .join("\n")}
${arrow(425, 360, 515, 360)}
${arrow(845, 360, 935, 360)}
${arrow(1265, 360, 1355, 360)}
${arrow(1520, 445, 1520, 630, colors.neutral)}
${arrow(1355, 715, 1265, 715, colors.neutral)}
${arrow(1095, 715, 935, 715)}
${textBlock("Automatic-first: l'utente non deve compilare un diario per avere memoria operativa.", 95, 930, { size: 28, weight: 700, color: colors.green, max: 92 })}
`
    )
  );
}

function phoneBaseSvg(w, h) {
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
<defs>
  <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
    <feDropShadow dx="0" dy="22" stdDeviation="24" flood-color="#172019" flood-opacity=".16"/>
  </filter>
</defs>
<rect x="6" y="6" width="${w - 12}" height="${h - 12}" rx="58" fill="#121712" filter="url(#shadow)"/>
<rect x="18" y="18" width="${w - 36}" height="${h - 36}" rx="46" fill="#fff"/>
</svg>`);
}

function phoneOverlaySvg(w, h, label = "") {
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
<rect x="18" y="18" width="${w - 36}" height="${h - 36}" rx="46" fill="none" stroke="#121712" stroke-width="14"/>
<rect x="${w / 2 - 42}" y="28" width="84" height="9" rx="4.5" fill="#121712" opacity=".84"/>
${label ? textBlock(label, w / 2, h - 22, { size: 18, weight: 700, color: colors.muted, anchor: "middle", max: 32 }) : ""}
</svg>`);
}

async function phoneComposite(input, options = {}) {
  const { width = 370, label = "" } = options;
  const height = Math.round(width * 800 / 369);
  const framePad = Math.round(width * 0.055);
  const frameW = width + framePad * 2;
  const frameH = height + framePad * 2;
  const screen = await sharp(input).resize(width, height, { fit: "fill" }).png().toBuffer();
  return sharp({
    create: { width: frameW, height: frameH, channels: 4, background: "#00000000" },
  })
    .composite([
      { input: phoneBaseSvg(frameW, frameH), left: 0, top: 0 },
      { input: screen, left: framePad, top: framePad },
      { input: phoneOverlaySvg(frameW, frameH, label), left: 0, top: 0 },
    ])
    .png()
    .toBuffer();
}

function calloutSvg(width, height, title, subtitle, callouts) {
  return Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="${width}" height="${height}" fill="${colors.bg}"/>
${textBlock(title, 82, 92, { size: 46, weight: 800, max: 46 })}
${textBlock(subtitle, 84, 135, { size: 22, color: colors.muted, max: 72 })}
${callouts
  .map((item, index) => {
    const y = 235 + index * 215;
    return `${card(1020, y, 690, 155, item.tone === "red" ? colors.redSoft : item.tone === "neutral" ? colors.neutralSoft : colors.surface, colors.line, 26)}
${textBlock(item.title, 1060, y + 58, { size: 28, weight: 800, color: item.tone === "red" ? colors.red : colors.green, max: 30 })}
${textBlock(item.body, 1060, y + 96, { size: 21, color: colors.muted, max: 50 })}
<path d="M ${1020} ${y + 78} C 900 ${y + 78}, 850 ${item.targetY}, 790 ${item.targetY}" fill="none" stroke="${item.tone === "red" ? colors.red : colors.green}" stroke-width="3" stroke-linecap="round" opacity=".75"/>`;
  })
  .join("\n")}
</svg>`);
}

async function createHero() {
  const width = 2400;
  const height = 1500;
  const phones = await Promise.all([
    phoneComposite(runtime.oggi, { width: 370, label: "Oggi" }),
    phoneComposite(runtime.batch, { width: 370, label: "Batch" }),
    phoneComposite(runtime.kefico, { width: 390, label: "Kefico" }),
    phoneComposite(runtime.guide, { width: 370, label: "Guide" }),
    phoneComposite(runtime.menu, { width: 370, label: "Nuova preparazione" }),
  ]);
  const bg = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
<rect width="${width}" height="${height}" fill="${colors.bg}"/>
<rect x="90" y="90" width="2220" height="1320" rx="70" fill="${colors.surface}" stroke="${colors.line}" stroke-width="2"/>
${textBlock("Batch", 170, 220, { size: 82, weight: 850, max: 20 })}
${textBlock("Hub operativo per routine fermentative", 172, 292, { size: 32, weight: 650, color: colors.green, max: 48 })}
${textBlock("Oggi, Batch e Guide tengono insieme priorità, domini e supporto senza trasformare l'app in un ricettario.", 172, 350, { size: 25, color: colors.muted, max: 74 })}
${pill("iPhone only", 172, 430, colors.surface2, colors.neutral)}
${pill("Local-first", 338, 430)}
${pill("Italian-first", 510, 430, colors.surface2, colors.neutral)}
</svg>`);

  await sharp(bg)
    .composite([
      { input: phones[0], left: 230, top: 590 },
      { input: phones[1], left: 660, top: 520 },
      { input: phones[2], left: 1080, top: 455 },
      { input: phones[3], left: 1530, top: 520 },
      { input: phones[4], left: 1920, top: 590 },
    ])
    .webp({ quality: 92 })
    .toFile(path.join(compositionsDir, "hero-batch-overview.webp"));
}

async function createAnnotated() {
  const oggiPhone = await phoneComposite(runtime.oggi, { width: 480, label: "Oggi actionable" });
  const oggiBase = calloutSvg(1800, 1300, "Oggi: priorità operativa", "La home ordina ciò che richiede attenzione, non tutto ciò che esiste.", [
    { title: "Promessa chiara", body: "`Cosa fare oggi` orienta la schermata sulla prossima azione.", targetY: 260 },
    { title: "Card per dominio", body: "Kefir, Starter e Guide convivono nella stessa agenda.", targetY: 520 },
    { title: "CTA sempre visibile", body: "`Nuova preparazione` resta un ingresso rapido al sistema.", targetY: 860 },
  ]);
  await sharp(oggiBase)
    .composite([{ input: oggiPhone, left: 220, top: 185 }])
    .webp({ quality: 92 })
    .toFile(path.join(annotatedDir, "annotated-oggi-priority.webp"));

  const keficoPhone = await phoneComposite(runtime.kefico, { width: 480, label: "Kefico detail" });
  const keficoBase = calloutSvg(1800, 1300, "Kefico: stato e azioni", "Il dettaglio mostra come un dominio specifico resta action-first.", [
    { title: "Overdue derivato", body: "Il ritardo è una lettura UI, non un valore duplicato nei dati.", targetY: 255, tone: "red" },
    { title: "Metriche operative", body: "Le informazioni servono a decidere, non a riempire dashboard.", targetY: 525 },
    { title: "Una primaria", body: "`Rinfresca` domina; cronologia, confronto e archivio restano secondari.", targetY: 820 },
  ]);
  await sharp(keficoBase)
    .composite([{ input: keficoPhone, left: 220, top: 185 }])
    .webp({ quality: 92 })
    .toFile(path.join(annotatedDir, "annotated-kefico-detail.webp"));
}

async function makeContactSheet(files) {
  const thumbs = [];
  for (const file of files) {
    const input = path.join(root, file);
    const meta = await sharp(input).metadata();
    const thumb = await sharp(input)
      .resize(520, 360, { fit: "contain", background: colors.surface })
      .extend({ top: 18, bottom: 92, left: 18, right: 18, background: colors.surface })
      .composite([
        {
          input: Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="556" height="470">
${textBlock(path.basename(file), 28, 430, { size: 18, weight: 700, color: colors.ink, max: 45 })}
${textBlock(`${meta.width}x${meta.height}`, 28, 456, { size: 15, color: colors.muted, max: 25 })}
</svg>`),
          left: 0,
          top: 0,
        },
      ])
      .webp({ quality: 88 })
      .toBuffer();
    thumbs.push(thumb);
  }

  const cols = 3;
  const tileW = 556;
  const tileH = 470;
  const gap = 26;
  const top = 160;
  const width = cols * tileW + (cols + 1) * gap;
  const rows = Math.ceil(files.length / cols);
  const height = top + rows * tileH + (rows + 1) * gap;
  const bg = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
<rect width="${width}" height="${height}" fill="${colors.bg}"/>
${textBlock("Batch showcase P0 asset pack", gap, 70, { size: 42, weight: 850, max: 60 })}
${textBlock("Diagrammi, annotazioni e hero generati da screenshot runtime e layout deterministici.", gap, 116, { size: 20, color: colors.muted, max: 92 })}
</svg>`);
  const composites = thumbs.map((input, index) => ({
    input,
    left: gap + (index % cols) * (tileW + gap),
    top: top + Math.floor(index / cols) * (tileH + gap),
  }));
  await sharp(bg)
    .composite(composites)
    .webp({ quality: 90 })
    .toFile(path.join(compositionsDir, "p0-contact-sheet.webp"));
}

async function writeManifest(files) {
  const items = [];
  for (const file of files) {
    const input = path.join(root, file);
    const meta = await sharp(input).metadata();
    items.push({
      file,
      title: path.basename(file),
      width: meta.width,
      height: meta.height,
      type: file.includes("/diagrams/") ? "diagram" : file.includes("/annotated/") ? "annotated-screen" : "composition",
      source: file.includes("/diagrams/") ? "deterministic SVG" : "runtime screenshots + deterministic layout",
      status: "draft-review",
    });
  }
  const manifest = {
    project: "Batch",
    runId: "batch-showcase-p0",
    generatedAt: new Date().toISOString(),
    method: "Deterministic SVG and sharp compositing. No generative image layer used.",
    sourceOfTruth: "docs/case-history/final-showcase-plan.md",
    items,
  };
  await fs.mkdir(path.join(runDir, "data"), { recursive: true });
  await fs.writeFile(path.join(runDir, "manifest.json"), JSON.stringify(manifest, null, 2));
  await fs.writeFile(path.join(compositionsDir, "p0-manifest.json"), JSON.stringify(manifest, null, 2));
}

async function main() {
  await Promise.all([fs.mkdir(diagramsDir, { recursive: true }), fs.mkdir(annotatedDir, { recursive: true }), fs.mkdir(compositionsDir, { recursive: true }), fs.mkdir(runDir, { recursive: true })]);
  await createDiagrams();
  await createHero();
  await createAnnotated();
  const files = [
    "docs/case-history/assets/compositions/hero-batch-overview.webp",
    "docs/case-history/assets/diagrams/ia-oggi-batch-guide.svg",
    "docs/case-history/assets/diagrams/oggi-priority-model.svg",
    "docs/case-history/assets/diagrams/new-preparation-flow.svg",
    "docs/case-history/assets/diagrams/bake-step-state-model.svg",
    "docs/case-history/assets/diagrams/kefir-lifecycle-flow.svg",
    "docs/case-history/assets/annotated/annotated-oggi-priority.webp",
    "docs/case-history/assets/annotated/annotated-kefico-detail.webp",
  ];
  await makeContactSheet(files);
  files.push("docs/case-history/assets/compositions/p0-contact-sheet.webp");
  await writeManifest(files);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
