import { Client } from "@gradio/client";
import { Hono } from "hono";
const client = Client.connect("hysts/DeepDanbooru");

const imageRouter = new Hono();

imageRouter.get("/", async (c) => {
  const response_0 = await fetch(
    "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"
  );
  const exampleImage = await response_0.blob();

  const result = await (
    await client
  ).predict("/predict", {
    image: exampleImage,
    score_threshold: 0.5,
  });

  return c.json(result.data as Record<string, unknown>, 200);
});

export default imageRouter;
