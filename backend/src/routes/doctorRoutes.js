const express = require("express");
const { listDoctors, nearbyDoctors, getSpecialties, getDoctorById, toggleOnline } = require("../controllers/doctorController");
const { requireDoctor } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", listDoctors);
router.get("/nearby", nearbyDoctors);
router.get("/specialties", getSpecialties);
router.get("/:id", getDoctorById);
router.put("/:id/online", requireDoctor, toggleOnline);

module.exports = router;
