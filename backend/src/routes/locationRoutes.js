const express = require("express");
const { searchLocation, nearbyClinics } = require("../controllers/locationController");

const router = express.Router();

router.get("/search", searchLocation);
router.get("/nearby-clinics", nearbyClinics);

module.exports = router;
