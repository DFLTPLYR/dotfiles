import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import Database from "better-sqlite3";
import { drizzle } from "drizzle-orm/better-sqlite3";

const sqlite = new Database("offline.sqlite");
const offlinDb = drizzle(sqlite);

const onlineDb = createClient(
  Bun.env.SUPABASE_URL as string,
  Bun.env.API_KEY as string
);

const todos = sqliteTable("todos", {
  id: integer("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description"),
  status: text("status").default("pending"),
  is_completed: integer("is_completed").default(0),
  is_sync: integer("is_sync").default(0),
  created_at: text("created_at"),
  updated_at: text("updated_at"),
});

const todoRouter = new Hono();

todoRouter.get("/", async (c) => {
  const { data, error } = await onlineDb.from("todos").select();
  if (error) return c.json({ error }, 500);
  return c.json(data);
});

todoRouter.post("/", async (c) => {
  const body = await c.req.json();
  const { title, description, status, is_completed } = body;

  // Insert into Supabase
  const { data, error } = await onlineDb
    .from("todos")
    .insert([
      {
        title,
        description,
        status: status || "pending",
        is_completed: is_completed ?? false,
      },
    ])
    .select();

  // Insert into offline
  await offlinDb.insert(todos).values({
    title: title,
    description: description,
    status: status || "pending",
    is_completed: is_completed ? 1 : 0,
    is_sync: error ? 0 : 1,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  });

  if (error) return c.json({ error }, 500);
  return c.json(data[0]);
});

export default todoRouter;
