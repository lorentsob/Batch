import React from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame,
} from "remotion";

const VIEWBOX_WIDTH = 923.27;
const VIEWBOX_HEIGHT = 967.23;
const MARK_FILL = "#EAF6F1";

const clampEase = {
  easing: Easing.bezier(0.16, 1, 0.3, 1),
  extrapolateLeft: "clamp" as const,
  extrapolateRight: "clamp" as const,
};

type SegmentProps = {
  order: number;
  vector: { x: number; y: number };
  children: React.ReactNode;
};

const Segment = ({ order, vector, children }: SegmentProps) => {
  const frame = useCurrentFrame();

  const start = 4 + order * 4;
  const enter = interpolate(frame, [start, start + 17], [0, 1], clampEase);

  const radialIntro = 0.24 * (1 - enter);
  const x = vector.x * -radialIntro;
  const y = vector.y * -radialIntro;
  const scale = 0.86 + enter * 0.14;
  const opacity = interpolate(frame, [start, start + 12], [0, 1], clampEase);

  const style: React.CSSProperties & {
    transformBox?: "fill-box";
    transformOrigin?: string;
  } = {
    opacity,
    transform: `translate(${x}px, ${y}px) scale(${scale})`,
    transformBox: "fill-box",
    transformOrigin: "center",
  };

  return <g style={style}>{children}</g>;
};

export const BatchLogoLoading = () => {
  const frame = useCurrentFrame();

  const logoIntro = interpolate(frame, [0, 20], [0, 1], clampEase);
  const markScale = interpolate(frame, [0, 22], [0.9, 1], clampEase);
  const markY = interpolate(frame, [0, 22], [28, 0], clampEase);
  const markRotate = interpolate(frame, [0, 58], [-10, 0], clampEase);

  return (
    <AbsoluteFill
      style={{
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <div
        style={{
          height: 706,
          opacity: logoIntro,
          position: "relative",
          transform: `translateY(${markY}px) rotate(${markRotate}deg) scale(${markScale})`,
          transformOrigin: "center",
          width: 674,
        }}
      >
        <svg
          viewBox={`0 0 ${VIEWBOX_WIDTH} ${VIEWBOX_HEIGHT}`}
          xmlns="http://www.w3.org/2000/svg"
          style={{
            height: "100%",
            inset: 0,
            position: "absolute",
            width: "100%",
          }}
        >
          <Segment order={5} vector={{ x: -298, y: -54 }}>
            <path
              fill={MARK_FILL}
              d="M163.96,429.66c-58-31.23-81.76-100.8-55.04-160.97,21.21,5.65,43.06-3.15,54.26-22.11,6.98-11.8,9.25-25.36,5.3-38.72,68-33.49,150.07,1.49,172.24,74.38,17.62,57.93-8.13,120.54-62.28,148.76-35.72,18.34-78.73,17.91-114.49-1.35Z"
            />
            <circle fill={MARK_FILL} cx="121.28" cy="220.18" r="37.45" />
          </Segment>
          <Segment order={0} vector={{ x: 52, y: -354 }}>
            <path
              fill={MARK_FILL}
              d="M598.73,129.97c11.57,55.51-14.18,110.98-63.86,137.63-52.98,28.42-118.39,13.53-155.23-34.63-24.07-31.47-31.88-71.66-20.43-111.84,9.4-33,34.12-63.34,68.14-79.05,40.98-18.92,87.95-13.43,123.38,13.44-6.18,9.73-8.32,20.24-7.12,31.2,3.01,27.59,27.42,47.14,55.13,43.25Z"
            />
            <path
              fill={MARK_FILL}
              d="M604.67,116c-16.2,6.27-34.07-.05-43.44-14.36-7.56-11.54-8.13-26.13-1.3-38.78,10.79-20,36.71-26.38,54.28-12.32,11.17,8.94,16.22,21.86,14.01,36.15-1.88,12.19-10.12,24.1-23.55,29.3Z"
            />
          </Segment>
          <Segment order={1} vector={{ x: 314, y: -152 }}>
            <path
              fill={MARK_FILL}
              d="M856.41,322.52c-18.08,2.12-34.33,13.16-41.11,29.1-7.69,18.07-4.99,38.09,7.49,52.63-27.99,29.94-67.65,43.39-107.57,37.77-45.35-6.39-82.93-38.22-98.08-78.79-17.48-46.82-5.96-97.41,28.24-131.86,27.16-27.36,64.48-40.67,103.22-35.95,63.89,7.78,110.53,63.25,107.81,127.1Z"
            />
            <circle fill={MARK_FILL} cx="859.47" cy="371.93" r="36.9" />
          </Segment>
          <Segment order={4} vector={{ x: -314, y: 178 }}>
            <path
              fill={MARK_FILL}
              d="M205.33,755.55c-63.6,3-118.08-41.2-128.03-106.09,21.75-3.25,37.86-19.6,41.38-40.95,3.23-19.59-4.71-39.08-21.43-50.16,13.27-19.39,30.9-34.86,52.07-44.49,53.32-24.24,115.02-7.78,149.39,39.37,32.55,44.65,32.75,105.96.25,150.86-22.19,30.65-56.68,49.71-93.63,51.46Z"
            />
            <circle fill={MARK_FILL} cx="70.82" cy="600.34" r="37.06" />
          </Segment>
          <Segment order={2} vector={{ x: 314, y: 198 }}>
            <path
              fill={MARK_FILL}
              d="M864.39,687.47c-18.07-8.46-38.57-5.35-52.88,8.05-13.99,13.1-19.37,33.28-11.61,52.07-45.02,18.1-95.81,8.13-130.71-25.47-45.82-44.11-52-116.52-14.52-167.76,31.63-43.24,86.26-62.5,137.71-46.06,38.99,12.46,68.74,43.83,80.33,83.12,9.37,31.79,6.49,64.94-8.31,96.03Z"
            />
            <circle fill={MARK_FILL} cx="843.04" cy="730.06" r="35.04" />
          </Segment>
          <Segment order={3} vector={{ x: 0, y: 350 }}>
            <path
              fill={MARK_FILL}
              d="M450.13,908.71c5.54-22.2-4.68-44.64-24.8-54.53-15.94-7.84-34.15-5.34-48.53,5.97-44.79-61.44-25.32-148.68,41.2-184.88,28.8-15.67,61.67-19.62,93.31-10.01,35.19,10.68,63.98,36.56,78.37,70.23,21.75,50.87,8.07,109.07-32.97,145.65-29.09,25.93-68.65,35.85-106.58,27.57Z"
            />
            <circle fill={MARK_FILL} cx="405.7" cy="896.69" r="34.75" />
          </Segment>
        </svg>
      </div>
    </AbsoluteFill>
  );
};
