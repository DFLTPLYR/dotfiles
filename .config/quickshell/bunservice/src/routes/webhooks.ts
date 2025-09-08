import todoRouter from "./todo";

// Edge-like function inside Bun
todoRouter.post("/notify-discord", async (c) => {
  const body = await c.req.json();

  const { record } = body;

  await fetch(process.env.DISCORD_WEBHOOK_URL!, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      content: `📝 New Todo: **${record.title}**
                Status: ${record.status}
                Completed: ${record.is_completed ? "✅" : "❌"}`,
    }),
  });

  return c.json({ ok: true });
});
