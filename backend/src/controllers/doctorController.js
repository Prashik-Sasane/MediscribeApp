const doctors = [
  {
    id: "d1",
    name: "Dr. Rahul Sharma",
    specialty: "Cardiologist",
    imageUrl: "https://i.pravatar.cc/201",
    rating: 4.8,
    fee: 600,
    lat: 18.5204,
    lng: 73.8567,
  },
  {
    id: "d2",
    name: "Dr. Priya Mehta",
    specialty: "Dermatologist",
    imageUrl: "https://i.pravatar.cc/202",
    rating: 4.7,
    fee: 500,
    lat: 18.5314,
    lng: 73.8446,
  },
  {
    id: "d3",
    name: "Dr. Aman Verma",
    specialty: "Neurologist",
    imageUrl: "https://i.pravatar.cc/203",
    rating: 4.9,
    fee: 900,
    lat: 18.5089,
    lng: 73.9258,
  },
  {
    id: "d4",
    name: "Dr. Sneha Patil",
    specialty: "Psychologist",
    imageUrl: "https://i.pravatar.cc/204",
    rating: 4.8,
    fee: 700,
    lat: 18.5654,
    lng: 73.9122,
  },
];

function toRadians(value) {
  return (value * Math.PI) / 180;
}

function haversineKm(lat1, lon1, lat2, lon2) {
  const r = 6371;
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * r * Math.asin(Math.sqrt(a));
}

function nearbyDoctors(req, res) {
  const lat = Number(req.query.lat);
  const lng = Number(req.query.lng);
  const radiusKm = Number(req.query.radiusKm || 20);

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return res.status(400).json({ message: "lat and lng query params are required" });
  }

  const mapped = doctors
    .map((doctor) => {
      const distanceKm = haversineKm(lat, lng, doctor.lat, doctor.lng);
      return {
        id: doctor.id,
        name: doctor.name,
        specialty: doctor.specialty,
        imageUrl: doctor.imageUrl,
        rating: doctor.rating,
        fee: doctor.fee,
        distanceKm: Number(distanceKm.toFixed(1)),
      };
    })
    .filter((doctor) => doctor.distanceKm <= radiusKm)
    .sort((a, b) => a.distanceKm - b.distanceKm);

  return res.json({ doctors: mapped });
}

module.exports = { nearbyDoctors };
