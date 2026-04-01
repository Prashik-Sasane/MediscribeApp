const express = require("express");
const { nearbyDoctors } = require("../controllers/doctorController");

const router = express.Router();

router.get("/nearby", nearbyDoctors);

module.exports = router;
