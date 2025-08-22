import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";
import { Database } from "bun:sqlite";

const offlineDb = new Database("offline.sqlite");

offlineDb.run(`
  CREATE TABLE IF NOT EXISTS todos (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending',
    is_completed INTEGER DEFAULT 0,
    is_sync INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT
  )
`);

const onlineDb = createClient(
  Bun.env.SUPABASE_URL as string,
  Bun.env.API_KEY as string
);

type Todo = {
  id: string;
  title: string;
  description?: string;
  status: string;
  is_completed: number;
  is_sync: number;
  created_at?: string;
  updated_at?: string;
};

const todoRouter = new Hono();

todoRouter.get("/", async (c) => {
  // Fetch online todos
  const { data: onlineTodos, error } = await onlineDb.from("todos").select();
  // Fetch offline todos
  const offlineTodos = offlineDb.query("SELECT * FROM todos").all() as Todo[];

  // If online fetch fails, just return offline
  if (error) {
    return c.json({ online: [], offline: offlineTodos }, 500);
  }

  // Compare: find offline todos not present online (by id)
  const onlineIds = new Set(((onlineTodos as Todo[]) ?? []).map((t) => t.id));
  const unsynced = offlineTodos.filter((t) => !onlineIds.has(t.id));

  return c.json({
    online: onlineTodos ?? [],
    offline: offlineTodos,
    unsynced,
  });
});

todoRouter.post("/", async (c) => {
  try {
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

    const todo = data?.[0];
    const uuid = todo?.id ?? crypto.randomUUID();
    // Insert into Offline
    offlineDb.run(
      `INSERT INTO todos (id, title, description, status, is_completed, is_sync, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      uuid,
      title,
      description,
      todo?.status || status || "pending",
      todo?.is_completed ?? is_completed ? 1 : 0,
      error ? 0 : 1,
      todo?.created_at || new Date().toISOString(),
      todo?.updated_at || new Date().toISOString()
    );

    if (error) return c.json({ error }, 500);
    return c.json(data[0]);
  } catch (e) {
    return c.json({ error: String(e) }, 500);
  }
});

export default todoRouter;
