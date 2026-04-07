const express = require("express");
const { createPrescription, getMyPrescriptions, getPrescription } = require("../controllers/prescriptionController");
const { requireAuth, requireDoctor } = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", requireDoctor, createPrescription);
router.get("/mine", requireAuth, getMyPrescriptions);
router.get("/:id", requireAuth, getPrescription);

module.exports = router;
