const express = require("express");
const { signup, login, doctorSignup, doctorLogin, getMe, updateProfile, getAddresses, addAddress } = require("../controllers/authController");
const { requireAuth } = require("../middleware/authMiddleware");

const router = express.Router();

// Patient
router.post("/signup", signup);
router.post("/login", login);

// Doctor
router.post("/doctor/signup", doctorSignup);
router.post("/doctor/login", doctorLogin);

// Shared — get current user profile
router.get("/me", requireAuth, getMe);

// Shared — update profile
router.put("/me", requireAuth, updateProfile);
router.get("/addresses", requireAuth, getAddresses);
router.post("/addresses", requireAuth, addAddress);

module.exports = router;
