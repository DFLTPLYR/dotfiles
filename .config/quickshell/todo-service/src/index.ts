import { serve } from "bun";
import { Hono } from "hono";
import "dotenv/config";
import { createClient } from "@supabase/supabase-js";

const app = new Hono();

// hehe funny number
const PORT = process.env.PORT ? Number(process.env.PORT) : 6969;

const supabase = createClient(
  process.env.SUPABASE_URL as string,
  process.env.API_KEY as string
);

serve({
  unix: "/tmp/bun.sock",
  fetch: app.fetch,
});

// Rest Api
app.get("/", (c) => {
  return c.text("OK", 200);
});

app.get("/todos", async (c) => {
  const { data, error } = await supabase.from("todos").select();
  if (error) return c.json({ error }, 500);
  return c.json(data);
});

export default app;
