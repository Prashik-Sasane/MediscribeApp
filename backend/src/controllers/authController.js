const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const DoctorAccount = require("../models/DoctorAccount");

function signToken(userId, role) {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error("JWT_SECRET is missing.");
  return jwt.sign({ userId, role }, secret, { expiresIn: "7d" });
}

function userResponse(user) {
  return {
    id: user._id.toString(),
    name: user.name,
    email: user.email,
    city: user.city,
    coins: user.coins,
    role: user.role,
    phone: user.phone,
    bloodGroup: user.bloodGroup,
    avatarUrl: user.avatarUrl,
    upiId: user.upiId,
  };
}

function doctorResponse(doc) {
  return {
    id: doc._id.toString(),
    name: doc.name,
    email: doc.email,
    specialty: doc.specialty,
    imageUrl: doc.imageUrl,
    fee: doc.fee,
    experience: doc.experience,
    rating: doc.rating,
    bio: doc.bio,
    isOnline: doc.isOnline,
    isVerified: doc.isVerified,
    licenseNumber: doc.licenseNumber,
    phone: doc.phone,
    upiId: doc.upiId,
    role: "doctor",
  };
}

// ─── Patient Signup ───────────────────────────────────────────────
async function signup(req, res) {
  const { name, email, password } = req.body;
  if (!name || !email || !password)
    return res.status(400).json({ message: "name, email, password are required" });
  if (password.length < 6)
    return res.status(400).json({ message: "Password must be at least 6 characters" });

  const existing = await User.findOne({ email: email.toLowerCase() });
  if (existing) return res.status(409).json({ message: "Email already registered" });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ name: name.trim(), email: email.toLowerCase().trim(), passwordHash });
  const token = signToken(user._id.toString(), "patient");
  return res.status(201).json({ token, user: userResponse(user) });
}

// ─── Patient Login ────────────────────────────────────────────────
async function login(req, res) {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "email and password are required" });

  const user = await User.findOne({ email: email.toLowerCase() });
  if (!user) return res.status(401).json({ message: "Invalid credentials" });

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return res.status(401).json({ message: "Invalid credentials" });

  // Use the ACTUAL user role from database (patient, doctor, or admin)
  const token = signToken(user._id.toString(), user.role);
  return res.json({ token, user: userResponse(user) });
}

// ─── Doctor Signup ────────────────────────────────────────────────
async function doctorSignup(req, res) {
  const { name, email, password, specialty, fee, experience, bio, lat, lng, phone, licenseNumber, autoVerify } = req.body;
  if (!name || !email || !password || !specialty)
    return res.status(400).json({ message: "name, email, password, specialty are required" });
  if (password.length < 6)
    return res.status(400).json({ message: "Password must be at least 6 characters" });

  const existing = await DoctorAccount.findOne({ email: email.toLowerCase() });
  if (existing) return res.status(409).json({ message: "Email already registered" });

  const passwordHash = await bcrypt.hash(password, 10);
  const doc = await DoctorAccount.create({
    name: name.trim(),
    email: email.toLowerCase().trim(),
    passwordHash,
    specialty,
    fee: fee || 500,
    experience: experience || 0,
    bio: bio || "",
    phone: phone || "",
    licenseNumber: licenseNumber || "",
    isVerified: autoVerify === true, // Auto-verify if flag is set, otherwise false
    lat: lat || 0,
    lng: lng || 0,
    location: {
      type: "Point",
      coordinates: [lng || 0, lat || 0],
    },
  });
  const token = signToken(doc._id.toString(), "doctor");
  return res.status(201).json({ token, user: doctorResponse(doc) });
}

// ─── Doctor Login ─────────────────────────────────────────────────
async function doctorLogin(req, res) {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "email and password are required" });

  const doc = await DoctorAccount.findOne({ email: email.toLowerCase() });
  if (!doc) return res.status(401).json({ message: "Invalid credentials" });

  const valid = await bcrypt.compare(password, doc.passwordHash);
  if (!valid) return res.status(401).json({ message: "Invalid credentials" });

  const token = signToken(doc._id.toString(), "doctor");
  return res.json({ token, user: doctorResponse(doc) });
}

// ─── Get current user profile ─────────────────────────────────────
async function getMe(req, res) {
  if (req.role === "doctor") {
    const doc = await DoctorAccount.findById(req.userId);
    if (!doc) return res.status(404).json({ message: "Doctor not found" });
    return res.json({ user: doctorResponse(doc) });
  }
  const user = await User.findById(req.userId);
  if (!user) return res.status(404).json({ message: "User not found" });
  return res.json({ user: userResponse(user) });
}

// ─── Update user profile (phone, upiId, etc.) ─────────────────────
async function updateProfile(req, res) {
  const { phone, upiId, bloodGroup, avatarUrl } = req.body;

  if (req.role === "doctor") {
    const updateData = {};
    if (phone !== undefined) updateData.phone = phone;
    if (upiId !== undefined) updateData.upiId = upiId;

    const doc = await DoctorAccount.findByIdAndUpdate(
      req.userId,
      updateData,
      { new: true }
    );
    if (!doc) return res.status(404).json({ message: "Doctor not found" });
    return res.json({ user: doctorResponse(doc), message: "Profile updated" });
  }

  // For patients
  const updateData = {};
  if (phone !== undefined) updateData.phone = phone;
  if (upiId !== undefined) updateData.upiId = upiId;
  if (bloodGroup !== undefined) updateData.bloodGroup = bloodGroup;
  if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl;

  const user = await User.findByIdAndUpdate(
    req.userId,
    updateData,
    { new: true }
  );
  if (!user) return res.status(404).json({ message: "User not found" });
  return res.json({ user: userResponse(user), message: "Profile updated" });
}

module.exports = { signup, login, doctorSignup, doctorLogin, getMe, updateProfile };
