const express = require("express");
const router = express.Router();
const { authenticate } = require("../middleware/auth");
const {
  createPaymentOrder,
  verifyPayment,
  paymentWebhook,
} = require("../controllers/paymentController");

// Public route for webhook (no auth needed)
router.post("/webhook", paymentWebhook);

// Authenticated routes
router.post("/create-order", authenticate, createPaymentOrder);
router.post("/verify", authenticate, verifyPayment);

module.exports = router;
