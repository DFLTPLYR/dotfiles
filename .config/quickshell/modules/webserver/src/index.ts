import { serve } from "bun";
import { Hono } from "hono";
import "dotenv/config";
import todoRouter from "./routes/todo";
import imageRouter from "./routes/images";
import weatherRouter from "./routes/weather";

const app = new Hono();

// hehe funny number
const PORT = Bun.env.PORT ? Number(Bun.env.PORT) : 6969;

// allow simple CORS for browser/QML requests (optional)
app.options("/*", (c) => {
  c.header("Access-Control-Allow-Origin", "*");
  c.header("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  c.header("Access-Control-Allow-Headers", "Content-Type");
  return c.text("", 200);
});

// Rest Api
app.get("/", (c) => {
  return c.text("OK", 200);
});

app.route("/todos", todoRouter);
app.route("/image", imageRouter);
app.route("/weather", weatherRouter);

serve({
  port: PORT,
  fetch: app.fetch,
});
