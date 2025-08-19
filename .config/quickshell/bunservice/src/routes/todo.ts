import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";

const supabase = createClient(
  process.env.SUPABASE_URL as string,
  process.env.API_KEY as string
);

const todoRouter = new Hono();

todoRouter.get("/", async (c) => {
  const { data, error } = await supabase.from("todos").select();
  if (error) return c.json({ error }, 500);
  return c.json(data);
});

export default todoRouter;
