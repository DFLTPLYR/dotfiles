import { readFileSync } from "fs";
import { Client } from "@gradio/client";
import { Hono } from "hono";
const client = Client.connect("hysts/DeepDanbooru");

const imageRouter = new Hono();

imageRouter.post("/", async (c) => {
  try {
    const body = await c.req.json();
    const imagePath = body.path;
    if (!imagePath) {
      return c.json({ error: "No image path provided" }, 400);
    }
    const buffer = readFileSync(imagePath);
    const exampleImage = new Blob([buffer]);

    const result = await (
      await client
    ).predict("/predict", {
      image: exampleImage,
      score_threshold: 0.5,
    });

    const data = result.data as [unknown, Record<string, unknown>, string];
    return c.json(data[1], 200);
  } catch (err) {
    console.error("Image route error:", err);
    return c.json({ error: err?.message || String(err) }, 500);
  }
});

export default imageRouter;
