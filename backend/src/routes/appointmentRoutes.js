const express = require("express");
const { bookAppointment, getMyAppointments, getDoctorAppointments, updateStatus } = require("../controllers/appointmentController");
const { requireAuth, requireDoctor } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", requireAuth, bookAppointment);
router.get("/mine", requireAuth, getMyAppointments);
router.get("/doctor", requireDoctor, getDoctorAppointments);
router.patch("/:id/status", requireAuth, updateStatus);

module.exports = router;
