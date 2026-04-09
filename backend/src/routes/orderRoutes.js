const express = require("express");
const { placeOrder, getMyOrders, getOrderTracking, cancelOrder } = require("../controllers/orderController");
const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", requireAuth, placeOrder);
router.get("/mine", requireAuth, getMyOrders);
router.get("/:id/tracking", requireAuth, getOrderTracking);
router.post("/:id/cancel", requireAuth, cancelOrder);

module.exports = router;
