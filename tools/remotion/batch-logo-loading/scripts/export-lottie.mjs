import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";

const FRAME_RATE = 30;
const DURATION = 72;
const WIDTH = 1080;
const HEIGHT = 1080;
const VIEWBOX_WIDTH = 923.27;
const VIEWBOX_HEIGHT = 967.23;
const SVG_WIDTH = 674;
const SVG_HEIGHT = 706;
const MARK_FILL = "#EAF6F1";

const svgScale = Math.min(SVG_WIDTH / VIEWBOX_WIDTH, SVG_HEIGHT / VIEWBOX_HEIGHT);
const svgLeft = (WIDTH - SVG_WIDTH) / 2 + (SVG_WIDTH - VIEWBOX_WIDTH * svgScale) / 2;
const svgTop = (HEIGHT - SVG_HEIGHT) / 2 + (SVG_HEIGHT - VIEWBOX_HEIGHT * svgScale) / 2;

const segments = [
  {
    name: "Upper Left",
    order: 5,
    vector: { x: -298, y: -54 },
    shapes: [
      {
        type: "path",
        d: "M163.96,429.66c-58-31.23-81.76-100.8-55.04-160.97,21.21,5.65,43.06-3.15,54.26-22.11,6.98-11.8,9.25-25.36,5.3-38.72,68-33.49,150.07,1.49,172.24,74.38,17.62,57.93-8.13,120.54-62.28,148.76-35.72,18.34-78.73,17.91-114.49-1.35Z",
      },
      { type: "circle", cx: 121.28, cy: 220.18, r: 37.45 },
    ],
  },
  {
    name: "Top",
    order: 0,
    vector: { x: 52, y: -354 },
    shapes: [
      {
        type: "path",
        d: "M598.73,129.97c11.57,55.51-14.18,110.98-63.86,137.63-52.98,28.42-118.39,13.53-155.23-34.63-24.07-31.47-31.88-71.66-20.43-111.84,9.4-33,34.12-63.34,68.14-79.05,40.98-18.92,87.95-13.43,123.38,13.44-6.18,9.73-8.32,20.24-7.12,31.2,3.01,27.59,27.42,47.14,55.13,43.25Z",
      },
      {
        type: "path",
        d: "M604.67,116c-16.2,6.27-34.07-.05-43.44-14.36-7.56-11.54-8.13-26.13-1.3-38.78,10.79-20,36.71-26.38,54.28-12.32,11.17,8.94,16.22,21.86,14.01,36.15-1.88,12.19-10.12,24.1-23.55,29.3Z",
      },
    ],
  },
  {
    name: "Upper Right",
    order: 1,
    vector: { x: 314, y: -152 },
    shapes: [
      {
        type: "path",
        d: "M856.41,322.52c-18.08,2.12-34.33,13.16-41.11,29.1-7.69,18.07-4.99,38.09,7.49,52.63-27.99,29.94-67.65,43.39-107.57,37.77-45.35-6.39-82.93-38.22-98.08-78.79-17.48-46.82-5.96-97.41,28.24-131.86,27.16-27.36,64.48-40.67,103.22-35.95,63.89,7.78,110.53,63.25,107.81,127.1Z",
      },
      { type: "circle", cx: 859.47, cy: 371.93, r: 36.9 },
    ],
  },
  {
    name: "Lower Left",
    order: 4,
    vector: { x: -314, y: 178 },
    shapes: [
      {
        type: "path",
        d: "M205.33,755.55c-63.6,3-118.08-41.2-128.03-106.09,21.75-3.25,37.86-19.6,41.38-40.95,3.23-19.59-4.71-39.08-21.43-50.16,13.27-19.39,30.9-34.86,52.07-44.49,53.32-24.24,115.02-7.78,149.39,39.37,32.55,44.65,32.75,105.96.25,150.86-22.19,30.65-56.68,49.71-93.63,51.46Z",
      },
      { type: "circle", cx: 70.82, cy: 600.34, r: 37.06 },
    ],
  },
  {
    name: "Lower Right",
    order: 2,
    vector: { x: 314, y: 198 },
    shapes: [
      {
        type: "path",
        d: "M864.39,687.47c-18.07-8.46-38.57-5.35-52.88,8.05-13.99,13.1-19.37,33.28-11.61,52.07-45.02,18.1-95.81,8.13-130.71-25.47-45.82-44.11-52-116.52-14.52-167.76,31.63-43.24,86.26-62.5,137.71-46.06,38.99,12.46,68.74,43.83,80.33,83.12,9.37,31.79,6.49,64.94-8.31,96.03Z",
      },
      { type: "circle", cx: 843.04, cy: 730.06, r: 35.04 },
    ],
  },
  {
    name: "Bottom",
    order: 3,
    vector: { x: 0, y: 350 },
    shapes: [
      {
        type: "path",
        d: "M450.13,908.71c5.54-22.2-4.68-44.64-24.8-54.53-15.94-7.84-34.15-5.34-48.53,5.97-44.79-61.44-25.32-148.68,41.2-184.88,28.8-15.67,61.67-19.62,93.31-10.01,35.19,10.68,63.98,36.56,78.37,70.23,21.75,50.87,8.07,109.07-32.97,145.65-29.09,25.93-68.65,35.85-106.58,27.57Z",
      },
      { type: "circle", cx: 405.7, cy: 896.69, r: 34.75 },
    ],
  },
];

const isCommand = (token) => /^[a-zA-Z]$/.test(token);

const tokenizePath = (path) =>
  path.match(/[a-zA-Z]|[-+]?(?:\d*\.\d+|\d+\.?)(?:e[-+]?\d+)?/gi) ?? [];

const toCompPoint = ([x, y]) => [
  round(svgLeft + x * svgScale),
  round(svgTop + y * svgScale),
];

const toCompTangent = ([x, y]) => [round(x * svgScale), round(y * svgScale)];

const round = (value) => Number(value.toFixed(4));

const addPoint = (points, point) => {
  points.push(toCompPoint(point));
};

const parsePath = (path) => {
  const tokens = tokenizePath(path);
  const vertices = [];
  const inTangents = [];
  const outTangents = [];
  const bboxPoints = [];
  let index = 0;
  let command = "";
  let current = [0, 0];
  let start = [0, 0];

  const readNumber = () => Number(tokens[index++]);
  const addVertex = (point, inTangent = [0, 0], outTangent = [0, 0]) => {
    vertices.push(toCompPoint(point));
    inTangents.push(toCompTangent(inTangent));
    outTangents.push(toCompTangent(outTangent));
    addPoint(bboxPoints, point);
  };

  while (index < tokens.length) {
    if (isCommand(tokens[index])) {
      command = tokens[index++];
    }

    switch (command) {
      case "M":
      case "m": {
        const isRelative = command === "m";
        const x = readNumber();
        const y = readNumber();
        current = isRelative ? [current[0] + x, current[1] + y] : [x, y];
        start = current;
        addVertex(current);

        while (index < tokens.length && !isCommand(tokens[index])) {
          const lineX = readNumber();
          const lineY = readNumber();
          current = isRelative
            ? [current[0] + lineX, current[1] + lineY]
            : [lineX, lineY];
          addVertex(current);
        }
        break;
      }
      case "C":
      case "c": {
        const isRelative = command === "c";
        while (index < tokens.length && !isCommand(tokens[index])) {
          const c1 = [readNumber(), readNumber()];
          const c2 = [readNumber(), readNumber()];
          const end = [readNumber(), readNumber()];
          const control1 = isRelative
            ? [current[0] + c1[0], current[1] + c1[1]]
            : c1;
          const control2 = isRelative
            ? [current[0] + c2[0], current[1] + c2[1]]
            : c2;
          const next = isRelative
            ? [current[0] + end[0], current[1] + end[1]]
            : end;

          outTangents[outTangents.length - 1] = toCompTangent([
            control1[0] - current[0],
            control1[1] - current[1],
          ]);
          addVertex(next, [control2[0] - next[0], control2[1] - next[1]]);
          addPoint(bboxPoints, control1);
          addPoint(bboxPoints, control2);
          current = next;
        }
        break;
      }
      case "Z":
      case "z":
        current = start;
        command = "";
        break;
      default:
        throw new Error(`Unsupported SVG path command: ${command}`);
    }
  }

  return {
    bboxPoints,
    shape: {
      c: true,
      i: inTangents,
      o: outTangents,
      v: vertices,
    },
  };
};

const hexToLottieRgb = (hex) => {
  const value = hex.replace("#", "");
  return [
    parseInt(value.slice(0, 2), 16) / 255,
    parseInt(value.slice(2, 4), 16) / 255,
    parseInt(value.slice(4, 6), 16) / 255,
    1,
  ].map(round);
};

const ease = (dimensions) => ({
  i: {
    x: Array(dimensions).fill(0.3),
    y: Array(dimensions).fill(1),
  },
  o: {
    x: Array(dimensions).fill(0.16),
    y: Array(dimensions).fill(1),
  },
});

const animated = (start, end, from, to, dimensions) => ({
  a: 1,
  k: [
    {
      t: start,
      s: from,
      e: to,
      ...ease(dimensions),
    },
    {
      t: end,
      s: to,
    },
  ],
});

const staticProperty = (value) => ({
  a: 0,
  k: value,
});

const layerTransform = ({ anchor, position, scale, opacity, rotation = 0 }) => ({
  o: opacity,
  r: typeof rotation === "number" ? staticProperty(rotation) : rotation,
  p: position,
  a: staticProperty([anchor[0], anchor[1], 0]),
  s: scale,
});

const shapeTransform = () => ({
  ty: "tr",
  p: staticProperty([0, 0]),
  a: staticProperty([0, 0]),
  s: staticProperty([100, 100]),
  r: staticProperty(0),
  o: staticProperty(100),
  sk: staticProperty(0),
  sa: staticProperty(0),
  nm: "Transform",
});

const boundsFromPoints = (points) => {
  const xs = points.map(([x]) => x);
  const ys = points.map(([, y]) => y);
  return {
    minX: Math.min(...xs),
    maxX: Math.max(...xs),
    minY: Math.min(...ys),
    maxY: Math.max(...ys),
  };
};

const segmentLayer = (segment, index) => {
  const shapeItems = [];
  const bboxPoints = [];

  segment.shapes.forEach((shape, shapeIndex) => {
    if (shape.type === "path") {
      const parsed = parsePath(shape.d);
      shapeItems.push({
        ty: "sh",
        ks: staticProperty(parsed.shape),
        nm: `${segment.name} Path ${shapeIndex + 1}`,
      });
      bboxPoints.push(...parsed.bboxPoints);
      return;
    }

    const center = toCompPoint([shape.cx, shape.cy]);
    const radius = round(shape.r * svgScale);
    shapeItems.push({
      ty: "el",
      p: staticProperty(center),
      s: staticProperty([round(radius * 2), round(radius * 2)]),
      d: 1,
      nm: `${segment.name} Dot`,
    });
    bboxPoints.push(
      [round(center[0] - radius), center[1]],
      [round(center[0] + radius), center[1]],
      [center[0], round(center[1] - radius)],
      [center[0], round(center[1] + radius)],
    );
  });

  const bounds = boundsFromPoints(bboxPoints);
  const anchor = [
    round((bounds.minX + bounds.maxX) / 2),
    round((bounds.minY + bounds.maxY) / 2),
  ];
  const startFrame = 4 + segment.order * 4;
  const offset = [
    round(segment.vector.x * -0.24),
    round(segment.vector.y * -0.24),
  ];

  return {
    ddd: 0,
    ind: index + 2,
    ty: 4,
    nm: `Batch Logo ${segment.name}`,
    parent: 1,
    sr: 1,
    ks: layerTransform({
      anchor,
      position: animated(
        startFrame,
        startFrame + 17,
        [round(anchor[0] + offset[0]), round(anchor[1] + offset[1]), 0],
        [anchor[0], anchor[1], 0],
        3,
      ),
      scale: animated(startFrame, startFrame + 17, [86, 86, 100], [100, 100, 100], 3),
      opacity: animated(startFrame, startFrame + 12, [0], [100], 1),
    }),
    ao: 0,
    shapes: [
      {
        ty: "gr",
        it: [
          ...shapeItems,
          {
            ty: "fl",
            c: staticProperty(hexToLottieRgb(MARK_FILL)),
            o: staticProperty(100),
            r: 1,
            bm: 0,
            nm: "Unified Fill",
          },
          shapeTransform(),
        ],
        nm: `${segment.name} Shapes`,
        bm: 0,
      },
    ],
    ip: 0,
    op: DURATION,
    st: 0,
    bm: 0,
  };
};

const parentLayer = {
  ddd: 0,
  ind: 1,
  ty: 3,
  nm: "Logo Intro Transform",
  sr: 1,
  ks: layerTransform({
    anchor: [WIDTH / 2, HEIGHT / 2],
    position: animated(0, 22, [WIDTH / 2, HEIGHT / 2 + 28, 0], [WIDTH / 2, HEIGHT / 2, 0], 3),
    scale: animated(0, 22, [90, 90, 100], [100, 100, 100], 3),
    opacity: animated(0, 20, [0], [100], 1),
    rotation: animated(0, 58, [-10], [0], 1),
  }),
  ao: 0,
  ip: 0,
  op: DURATION,
  st: 0,
  bm: 0,
};

const lottie = {
  v: "5.12.2",
  fr: FRAME_RATE,
  ip: 0,
  op: DURATION,
  w: WIDTH,
  h: HEIGHT,
  nm: "Batch Logo Loading",
  ddd: 0,
  assets: [],
  layers: [...segments.map(segmentLayer), parentLayer],
  markers: [],
};

const outputPath = resolve("out/batch-logo-loading.json");
mkdirSync(dirname(outputPath), { recursive: true });
writeFileSync(outputPath, `${JSON.stringify(lottie, null, 2)}\n`);

console.log(outputPath);
