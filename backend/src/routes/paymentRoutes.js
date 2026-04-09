const express = require("express");
const router = express.Router();
const { requireAuth } = require("../middleware/authMiddleware");
const {
  createPaymentOrder,
  verifyPayment,
} = require("../controllers/paymentController");

// Authenticated routes (webhook is handled in app.js with raw body parsing)
router.post("/create-order", requireAuth, createPaymentOrder);
router.post("/verify", requireAuth, verifyPayment);

module.exports = router;
