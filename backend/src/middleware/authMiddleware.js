const jwt = require("jsonwebtoken");

function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "Missing or invalid authorization header" });
  }
  const token = authHeader.split(" ")[1];
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = payload.userId;
    req.role = payload.role || "patient";
    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

function requireDoctor(req, res, next) {
  requireAuth(req, res, () => {
    if (req.role !== "doctor") {
      return res.status(403).json({ message: "Doctor access only" });
    }
    next();
  });
}

function requireAdmin(req, res, next) {
  requireAuth(req, res, () => {
    if (req.role !== "admin") {
      return res.status(403).json({ message: "Admin access only" });
    }
    next();
  });
}

module.exports = { requireAuth, requireDoctor, requireAdmin };
