import "dotenv/config";
import { createClient } from "@supabase/supabase-js";
import { Hono } from "hono";
import { Database } from "bun:sqlite";
import { Todo } from "../types/todo.types";

const todoRouter = new Hono();

const onlineDb = createClient(
  Bun.env.SUPABASE_URL as string,
  Bun.env.API_KEY as string
);

const offlineDb = new Database("offline.sqlite");

offlineDb.run(`
  CREATE TABLE IF NOT EXISTS todos (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    is_completed INTEGER DEFAULT 0,
    is_sync INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT
  )
`);

// Get All Todos
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

// Insert Todo
todoRouter.post("/", async (c) => {
  try {
    const body = await c.req.json();
    const { title, status, is_completed } = body;

    // Insert into Supabase
    const { data, error } = await onlineDb
      .from("todos")
      .insert([
        {
          title,
          status: status || "pending",
          is_completed: is_completed ?? false,
        },
      ])
      .select();

    const todo = data?.[0];
    const uuid = todo?.id ?? crypto.randomUUID();
    // Insert into Offline
    offlineDb.run(
      `INSERT INTO todos (id, title, status, is_completed, is_sync, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      uuid,
      todo.title,
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

// Update Todo by ID
todoRouter.put("/:id", async (c) => {
  try {
    const id = c.req.param("id");
    const body = await c.req.json();
    const { title, status, is_completed } = body;

    // Update in Supabase
    const { data, error } = await onlineDb
      .from("todos")
      .update({
        title,
        status: status || "pending",
        is_completed: is_completed ?? false,
        updated_at: new Date().toISOString(),
      })
      .eq("id", id)
      .select();

    const todo = data?.[0];

    // Update in Offline SQLite
    offlineDb.run(
      `UPDATE todos SET title = ?, status = ?, is_completed = ?, is_sync = ?, updated_at = ? WHERE id = ?`,
      [
        title,
        todo?.status || status || "pending",
        todo?.is_completed ?? (is_completed ? 1 : 0),
        error ? 0 : 1,
        todo?.updated_at || new Date().toISOString(),
        id,
      ]
    );

    if (error) return c.json({ error }, 500);
    return c.json(data[0]);
  } catch (e) {
    return c.json({ error: String(e) }, 500);
  }
});

// Delete Todo by ID
todoRouter.delete("/:id", async (c) => {
  try {
    const id = c.req.param("id");

    // Delete from Supabase
    const { error } = await onlineDb.from("todos").delete().eq("id", id);

    // Delete from Offline SQLite
    offlineDb.run("DELETE FROM todos WHERE id = ?", [id]);

    if (error) return c.json({ error }, 500);
    return c.json({
      ok: true,
      message: `Todo ${id} deleted from both databases.`,
    });
  } catch (e) {
    return c.json({ error: String(e) }, 500);
  }
});

// Delete both online and offline
todoRouter.delete("/nuke", async (c) => {
  offlineDb.run("DELETE FROM todos");
  const { error } = await onlineDb.from("todos").delete().neq("title", null);
  if (error) return c.json({ ok: false, error: error.message }, 500);
  return c.json({
    ok: true,
    message: "All todos deleted from both databases.",
  });
});

export default todoRouter;
