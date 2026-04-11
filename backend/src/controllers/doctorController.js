const DoctorAccount = require("../models/DoctorAccount");
const Appointment = require("../models/Appointment");

// ─── Haversine fallback ───────────────────────────────────────────
function haversineKm(lat1, lon1, lat2, lon2) {
  const r = 6371;
  const toRad = (v) => (v * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * r * Math.asin(Math.sqrt(a));
}

function doctorPublic(doc, distanceKm) {
  return {
    id: doc._id.toString(),
    name: doc.name,
    email: doc.email, // Added for admin dashboard
    specialty: doc.specialty,
    imageUrl: doc.imageUrl,
    fee: doc.fee,
    experience: doc.experience,
    rating: doc.rating,
    reviews: doc.reviews,
    bio: doc.bio,
    isOnline: doc.isOnline,
    isVerified: doc.isVerified,
    licenseNumber: doc.licenseNumber, // Added for admin dashboard
    phone: doc.phone, // Added for video calls
    upiId: doc.upiId, // Added for payments
    lat: doc.lat,
    lng: doc.lng,
    availableSlots: doc.availableSlots,
    distanceKm: distanceKm !== undefined ? Number(distanceKm.toFixed(1)) : undefined,
  };
}

// GET /api/doctors — list, filter by specialty/query (ONLY verified doctors)
async function listDoctors(req, res) {
  const specialty = (req.query.specialty || "").toString().trim();
  const q = (req.query.q || "").toString().toLowerCase().trim();
  const page = Math.max(1, Number(req.query.page || 1));
  const limit = 20;

  // ONLY show verified doctors to patients
  const filter = { isVerified: true };
  if (specialty) filter.specialty = { $regex: specialty, $options: "i" };
  if (q) filter.name = { $regex: q, $options: "i" };

  const [doctors, total] = await Promise.all([
    DoctorAccount.find(filter)
      .select("-passwordHash")
      .skip((page - 1) * limit)
      .limit(limit)
      .sort({ rating: -1 }),
    DoctorAccount.countDocuments(filter),
  ]);

  return res.json({ doctors: doctors.map((d) => doctorPublic(d)), total, page });
}

// GET /api/doctors/nearby (ONLY verified doctors)
async function nearbyDoctors(req, res) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radiusKm = Number(req.query.radiusKm || 50); // Increased default from 20 to 50

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return res.status(400).json({ message: "lat and lng query params are required" });
  }

  let doctors;
  try {
    // ONLY fetch verified doctors
    // MongoDB GeoJSON requires [longitude, latitude] order
    doctors = await DoctorAccount.find({
      isVerified: true,
      location: {
        $near: {
          $geometry: { type: "Point", coordinates: [lng, lat] }, // FIXED: [lng, lat] not [lat, lng]
          $maxDistance: radiusKm * 1000, // FIXED: meters not 10000
        },
      },
    }).select("-passwordHash").limit(30);
  } catch (_) {
    // fallback if 2dsphere index not yet built
    const all = await DoctorAccount.find({ isVerified: true }).select("-passwordHash");
    doctors = all
      .map((d) => ({ doc: d, dist: haversineKm(lat, lng, d.lat, d.lng) }))
      .filter((x) => x.dist <= radiusKm)
      .sort((a, b) => a.dist - b.dist)
      .map((x) => x.doc);
  }

  const result = doctors.map((d) => {
    const dist = haversineKm(lat, lng, d.lat, d.lng);
    return doctorPublic(d, dist);
  });

  console.log(`Found ${result.length} verified doctors near lat=${lat}, lng=${lng}`);
  return res.json({ doctors: result });
}

// GET /api/doctors/specialties
async function getSpecialties(req, res) {
  const specialties = await DoctorAccount.distinct("specialty");
  return res.json({ specialties });
}

// GET /api/doctors/:id
async function getDoctorById(req, res) {
  const doc = await DoctorAccount.findById(req.params.id).select("-passwordHash");
  if (!doc) return res.status(404).json({ message: "Doctor not found" });
  return res.json({ doctor: doctorPublic(doc) });
}

// GET /api/doctors/admin/unverified (admin only)
async function getUnverifiedDoctors(req, res) {
  if (req.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  
  const page = Math.max(1, Number(req.query.page || 1));
  const limit = 50;
  
  const [doctors, total] = await Promise.all([
    DoctorAccount.find({ isVerified: false })
      .select("-passwordHash")
      .skip((page - 1) * limit)
      .limit(limit)
      .sort({ createdAt: -1 }),
    DoctorAccount.countDocuments({ isVerified: false }),
  ]);
  
  return res.json({ 
    doctors: doctors.map((d) => doctorPublic(d)), 
    total, 
    page 
  });
}

// PUT /api/doctors/:id/online  (doctor auth)
async function toggleOnline(req, res) {
  if (req.userId !== req.params.id && req.role !== "doctor") {
    return res.status(403).json({ message: "Forbidden" });
  }
  const doc = await DoctorAccount.findByIdAndUpdate(
    req.params.id,
    { isOnline: req.body.isOnline },
    { new: true }
  ).select("-passwordHash");
  if (!doc) return res.status(404).json({ message: "Doctor not found" });
  return res.json({ doctor: doctorPublic(doc) });
}

// PUT /api/doctors/:id/verify  (admin auth)
async function verifyDoctor(req, res) {
  if (req.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  
  const updateData = { 
    isVerified: req.body.isVerified !== undefined ? req.body.isVerified : true,
  };
  
  if (req.body.licenseNumber) {
    updateData.licenseNumber = req.body.licenseNumber;
  }
  
  const doc = await DoctorAccount.findByIdAndUpdate(
    req.params.id,
    updateData,
    { new: true }
  ).select("-passwordHash");
  
  if (!doc) return res.status(404).json({ message: "Doctor not found" });
  return res.json({ doctor: doctorPublic(doc) });
}

// PUT /api/doctors/admin/bulk-verify  (admin auth)
async function bulkVerifyDoctors(req, res) {
  if (req.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  
  const { doctorIds, verifyAll } = req.body;
  
  let result;
  if (verifyAll === true) {
    // Verify ALL unverified doctors
    result = await DoctorAccount.updateMany(
      { isVerified: false },
      { isVerified: true }
    );
    return res.json({ 
      message: `Verified ${result.modifiedCount} doctors`,
      modifiedCount: result.modifiedCount 
    });
  } else if (Array.isArray(doctorIds)) {
    // Verify specific doctors
    result = await DoctorAccount.updateMany(
      { _id: { $in: doctorIds } },
      { isVerified: true }
    );
    return res.json({ 
      message: `Verified ${result.modifiedCount} doctors`,
      modifiedCount: result.modifiedCount 
    });
  }
  
  return res.status(400).json({ message: "Provide doctorIds array or verifyAll: true" });
}

// GET /api/doctors/:id/available-slots
async function getDoctorSlots(req, res) {
  const { date } = req.query;
  
  if (!date) {
    return res.status(400).json({ message: "date query parameter is required (YYYY-MM-DD)" });
  }
  
  // Find doctor
  const doctor = await DoctorAccount.findById(req.params.id);
  if (!doctor) {
    return res.status(404).json({ message: "Doctor not found" });
  }
  
  // Define standard time slots (9 AM to 5 PM)
  const allSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
    "15:00", "15:30", "16:00", "16:30", "17:00"
  ];
  
  // Find booked appointments for this date
  const bookedAppointments = await Appointment.find({
    doctorId: req.params.id,
    dateLabel: { $regex: date, $options: "i" },
    status: { $ne: "cancelled" }
  });
  
  const bookedTimes = bookedAppointments.map(appt => appt.timeLabel);
  
  // Create slots with availability
  const slots = allSlots.map(time => ({
    time,
    available: !bookedTimes.includes(time)
  }));
  
  return res.json({
    date,
    doctorId: doctor._id.toString(),
    doctorName: doctor.name,
    slots
  });
}

module.exports = { listDoctors, nearbyDoctors, getSpecialties, getDoctorById, toggleOnline, verifyDoctor, getUnverifiedDoctors, bulkVerifyDoctors, getDoctorSlots };
