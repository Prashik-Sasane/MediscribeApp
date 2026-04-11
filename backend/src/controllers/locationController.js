const https = require("https");
const DoctorAccount = require("../models/DoctorAccount");

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

// GET /api/location/search?q=&type=  — proxy Nominatim (OSM, no API key)
async function searchLocation(req, res) {
  const q = (req.query.q || "").toString().trim();
  if (!q) return res.status(400).json({ message: "q is required" });

  const type = (req.query.type || "").toString().trim(); // hospital, clinic, pharmacy…
  const query = type ? `${q} ${type}` : q;
  const url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=10&addressdetails=1`;

  https.get(
    url,
    {
      headers: {
        "User-Agent": "MediscribeApp/1.0 (contact@mediscribe.app)",
        "Accept-Language": "en",
      },
    },
    (upstream) => {
      let data = "";
      upstream.on("data", (chunk) => (data += chunk));
      upstream.on("end", () => {
        try {
          const json = JSON.parse(data);
          const places = json.map((p) => ({
            id: p.place_id,
            name: p.display_name.split(",")[0],
            displayName: p.display_name,
            address: p.display_name,
            lat: parseFloat(p.lat),
            lng: parseFloat(p.lon),
            type: p.type,
          }));
          return res.json({ places });
        } catch {
          return res.status(502).json({ message: "Failed to parse Nominatim response" });
        }
      });
    }
  ).on("error", () => {
    return res.status(502).json({ message: "Cannot reach Nominatim" });
  });
}

// GET /api/location/nearby-clinics?lat=&lng=&radiusKm=
async function nearbyClinics(req, res) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radiusKm = Number(req.query.radiusKm || 50); // Increased default to 50

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return res.status(400).json({ message: "lat and lng are required" });
  }

  let doctors;
  try {
    // MongoDB GeoJSON requires [longitude, latitude] order
    doctors = await DoctorAccount.find({
      location: {
        $near: {
          $geometry: { type: "Point", coordinates: [lng, lat] }, // FIXED: [lng, lat]
          $maxDistance: radiusKm * 1000, // FIXED: meters not 10000
        },
      },
    })
      .select("-passwordHash")
      .limit(20);
  } catch (_) {
    const all = await DoctorAccount.find().select("-passwordHash");
    doctors = all
      .filter((d) => haversineKm(lat, lng, d.lat, d.lng) <= radiusKm)
      .sort((a, b) => haversineKm(lat, lng, a.lat, a.lng) - haversineKm(lat, lng, b.lat, b.lng));
  }

  const clinics = doctors.map((d) => ({
    id: d._id.toString(),
    name: d.name,
    specialty: d.specialty,
    imageUrl: d.imageUrl,
    address: d.city || '',
    rating: d.rating,
    distanceKm: Number(haversineKm(lat, lng, d.lat, d.lng).toFixed(1)),
    lat: d.lat,
    lng: d.lng,
    isOnline: d.isOnline,
    type: "Clinic",
  }));

  return res.json({ clinics });
}

module.exports = { searchLocation, nearbyClinics };
