const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/authRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    ok: true,
    message: "Mediscribe backend is running",
    endpoints: ["/health", "/api/auth/signup", "/api/auth/login"],
  });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "mediscribe-backend" });
});

app.use("/api/auth", authRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ message: "Internal server error" });
});

module.exports = app;
