const express = require("express");
const { getMessages, sendMessage } = require("../controllers/chatController");
const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/:appointmentId", requireAuth, getMessages);
router.post("/:appointmentId", requireAuth, sendMessage);

module.exports = router;
