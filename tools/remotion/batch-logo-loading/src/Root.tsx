import { Composition } from "remotion";
import { BatchLogoLoading } from "./BatchLogoLoading";

export const RemotionRoot = () => {
  return (
    <Composition
      id="BatchLogoLoading"
      component={BatchLogoLoading}
      durationInFrames={72}
      fps={30}
      width={1080}
      height={1080}
    />
  );
};
