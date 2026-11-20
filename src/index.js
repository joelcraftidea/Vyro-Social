
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/health") {
      try {
        const result = await env.DB.prepare(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        ).all();

        return Response.json({
          status: "success",
          service: "VYRO",
          database: "connected",
          tables: result.results.map(row => row.name)
        });
      } catch (error) {
        return Response.json({
          status: "error",
          message: "Database connection failed"
        }, { status: 500 });
      }
    }

    return Response.json({
      service: "VYRO API",
      status: "running"
    });
  }
};
