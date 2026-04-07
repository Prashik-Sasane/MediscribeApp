const express = require("express");
const { placeOrder, getMyOrders } = require("../controllers/orderController");
const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", requireAuth, placeOrder);
router.get("/mine", requireAuth, getMyOrders);

module.exports = router;
