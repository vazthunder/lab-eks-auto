import express from "express";

const app = express();
const PORT = process.env.PORT || 3000;
const version = process.env.GIT_SHA || "unknown";

app.get("/healthz", (_req, res) => res.sendStatus(200));
app.get("/readyz", (_req, res) => res.sendStatus(200));

app.get("/info", (_req, res) => {
  res.json({
    app: "eks-test-app",
    version,
    node: process.version,
    hostname: process.env.HOSTNAME || "unknown",
    cluster: process.env.CLUSTER_NAME || "unknown",
  });
});

app.get("/", (_req, res) => {
  const hostname = process.env.HOSTNAME || "unknown";
  const cluster = process.env.CLUSTER_NAME || "unknown";

  res.send(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>eks-test-app</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      display: flex; justify-content: center; align-items: center;
      min-height: 100vh; background: #f0f4f8; color: #1a202c;
    }
    .card {
      background: #fff; border-radius: 12px; padding: 2.5rem 3rem;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08); text-align: center;
      max-width: 480px;
    }
    h1 { font-size: 1.75rem; margin-bottom: 0.5rem; }
    .badge {
      display: inline-block; background: #3182ce; color: #fff;
      font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.75rem;
      border-radius: 999px; margin-bottom: 1.5rem;
    }
    .info { margin-top: 1.5rem; }
    .info p {
      font-size: 0.875rem; color: #4a5568; margin-bottom: 0.5rem;
      display: flex; justify-content: space-between; gap: 2rem;
    }
    .info span { font-weight: 500; color: #1a202c; }
    .footer { margin-top: 2rem; font-size: 0.75rem; color: #a0aec0; }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">RUNNING</div>
    <h1>eks-test-app</h1>
    <p style="color:#718096;font-size:0.9rem">Deployed on Amazon EKS Auto Mode</p>
    <div class="info">
      <p>Node.js <span>${process.version}</span></p>
      <p>Version <span>${version}</span></p>
      <p>Hostname <span>${hostname}</span></p>
      <p>Cluster <span>${cluster}</span></p>
    </div>
    <div class="footer">${new Date().toISOString()}</div>
  </div>
</body>
</html>`);
});

app.listen(PORT, () => console.log(`listening on ${PORT}`));
