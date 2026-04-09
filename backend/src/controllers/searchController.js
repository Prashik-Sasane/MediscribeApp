const Doctor = require("../models/Doctor");
const Medicine = require("../models/Medicine");
const LabTest = require("../models/LabTest");

async function globalSearch(req, res) {
  const { q } = req.query;
  if (!q) return res.json({ doctors: [], medicines: [], labTests: [] });

  const query = q.toString();

  try {
    // Search Doctors
    const doctors = await Doctor.find({
      $or: [
        { name: { $regex: query, $options: "i" } },
        { specialty: { $regex: query, $options: "i" } },
      ],
    })
    .select("name specialty imageUrl rating")
    .limit(5);

    // Search Medicines
    const medicines = await Medicine.find({
      $or: [
        { name: { $regex: query, $options: "i" } },
        { category: { $regex: query, $options: "i" } },
        { tags: { $regex: query, $options: "i" } },
      ],
    })
    .select("name category price imageUrl tags")
    .limit(5);

    // Search Lab Tests
    const labTests = await LabTest.find({
      $or: [
        { name: { $regex: query, $options: "i" } },
        { category: { $regex: query, $options: "i" } },
        { description: { $regex: query, $options: "i" } },
        { tags: { $regex: query, $options: "i" } },
      ],
    })
    .select("name category price imageUrl tags description")
    .limit(5);

    res.json({
      doctors: doctors.map(d => ({
        id: d._id.toString(),
        title: d.name,
        subtitle: d.specialty,
        type: "doctor",
        imageUrl: d.imageUrl,
        rating: d.rating,
      })),
      medicines: medicines.map(m => ({
        id: m._id.toString(),
        title: m.name,
        subtitle: m.category,
        type: "medicine",
        imageUrl: m.imageUrl,
        price: m.price,
        tags: m.tags,
      })),
      labTests: labTests.map(l => ({
        id: l._id.toString(),
        title: l.name,
        subtitle: l.category,
        type: "lab_test",
        imageUrl: l.imageUrl,
        price: l.price,
        description: l.description,
      })),
    });
  } catch (err) {
    console.error("Search Error:", err);
    res.status(500).json({ message: "Search failed" });
  }
}

module.exports = { globalSearch };
