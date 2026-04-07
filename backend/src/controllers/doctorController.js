const DoctorAccount = require("../models/DoctorAccount");

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
    specialty: doc.specialty,
    imageUrl: doc.imageUrl,
    fee: doc.fee,
    experience: doc.experience,
    rating: doc.rating,
    reviews: doc.reviews,
    bio: doc.bio,
    isOnline: doc.isOnline,
    lat: doc.lat,
    lng: doc.lng,
    availableSlots: doc.availableSlots,
    distanceKm: distanceKm !== undefined ? Number(distanceKm.toFixed(1)) : undefined,
  };
}

// GET /api/doctors — list, filter by specialty/query
async function listDoctors(req, res) {
  const specialty = (req.query.specialty || "").toString().trim();
  const q = (req.query.q || "").toString().toLowerCase().trim();
  const page = Math.max(1, Number(req.query.page || 1));
  const limit = 20;

  const filter = {};
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

// GET /api/doctors/nearby
async function nearbyDoctors(req, res) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radiusKm = Number(req.query.radiusKm || 20);

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return res.status(400).json({ message: "lat and lng query params are required" });
  }

  let doctors;
  try {
    doctors = await DoctorAccount.find({
      location: {
        $near: {
          $geometry: { type: "Point", coordinates: [lng, lat] },
          $maxDistance: radiusKm * 1000,
        },
      },
    }).select("-passwordHash").limit(30);
  } catch (_) {
    // fallback if 2dsphere index not yet built
    const all = await DoctorAccount.find().select("-passwordHash");
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

module.exports = { listDoctors, nearbyDoctors, getSpecialties, getDoctorById, toggleOnline };
