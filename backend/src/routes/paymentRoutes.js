const express = require("express");
const router = express.Router();
const { authenticate } = require("../middleware/auth");
const {
  createPaymentOrder,
  verifyPayment,
} = require("../controllers/paymentController");

// Authenticated routes (webhook is handled in app.js with raw body parsing)
router.post("/create-order", authenticate, createPaymentOrder);
router.post("/verify", authenticate, verifyPayment);

module.exports = router;
