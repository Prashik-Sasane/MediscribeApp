const express = require("express");
const { listLabs, bookLabTest, getMyBookings } = require("../controllers/labController");
const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", listLabs);
router.post("/book", requireAuth, bookLabTest);
router.get("/my-bookings", requireAuth, getMyBookings);

module.exports = router;
