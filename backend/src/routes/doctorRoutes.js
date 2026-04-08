const express = require("express");
const { listDoctors, nearbyDoctors, getSpecialties, getDoctorById, toggleOnline, verifyDoctor, getUnverifiedDoctors, bulkVerifyDoctors, getDoctorSlots } = require("../controllers/doctorController");
const { requireDoctor, requireAdmin } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/", listDoctors);
router.get("/nearby", nearbyDoctors);
router.get("/specialties", getSpecialties);
router.get("/admin/unverified", requireAdmin, getUnverifiedDoctors);
router.get("/:id", getDoctorById);
router.get("/:id/available-slots", getDoctorSlots);
router.put("/:id/online", requireDoctor, toggleOnline);
router.put("/:id/verify", requireAdmin, verifyDoctor);
router.put("/admin/bulk-verify", requireAdmin, bulkVerifyDoctors);

module.exports = router;
