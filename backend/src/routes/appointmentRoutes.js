const express = require("express");
const { bookAppointment, getMyAppointments, getDoctorAppointments, updateStatus, rateAppointment } = require("../controllers/appointmentController");
const { requireAuth, requireDoctor } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", requireAuth, bookAppointment);
router.get("/mine", requireAuth, getMyAppointments);
router.get("/doctor", requireDoctor, getDoctorAppointments);
router.patch("/:id/status", requireAuth, updateStatus);
router.post("/:id/rate", requireAuth, rateAppointment);

module.exports = router;
