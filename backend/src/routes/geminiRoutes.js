const express = require("express");
const multer = require("multer");
const {
  analyzePrescriptionFromImage,
  listModels,
} = require("../controllers/geminiController");

const router = express.Router();

// Keep uploads in-memory (no disk writes). Max 10MB.
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

// POST /api/gemini/prescription (multipart/form-data, field: image)
router.post("/prescription", upload.single("image"), analyzePrescriptionFromImage);

// GET /api/gemini/models (debug)
router.get("/models", listModels);

module.exports = router;

