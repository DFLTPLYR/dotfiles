import "dotenv/config";
import { Hono } from "hono";

const weatherRouter = new Hono();

weatherRouter.get("/", async (c) => {
  try {
    const clientIp =
      c.req.header("x-forwarded-for") ||
      c.req.header("x-real-ip") ||
      "auto:ip";

    const url =
      "https://api.weatherapi.com/v1/forecast.json?key=" +
      Bun.env.WEATHER_API +
      "&q=" +
      encodeURIComponent(clientIp) +
      "&days=3&aqi=no&alerts=no";

    const res = await fetch(url);
    if (!res.ok) {
      return c.json({ error: "Failed to fetch weather data" }, 500);
    }

    const data = await res.json();
    return c.json(data);
  } catch (err) {
    return c.json({ error: err.message }, 500);
  }
});

export default weatherRouter;
