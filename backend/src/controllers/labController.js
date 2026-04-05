const labs = [
  {
    id: "l1",
    name: "Complete Blood Count (CBC)",
    category: "Blood",
    price: 499,
    description: "Measures RBC, WBC, platelets and hemoglobin.",
    imageUrl:
      "https://images.unsplash.com/photo-1582719478170-2c3f6f0d2e62?auto=format&fit=crop&w=800&q=80",
    tags: ["popular"],
  },
  {
    id: "l2",
    name: "HbA1c (Diabetes)",
    category: "Diabetes",
    price: 699,
    description: "Average blood sugar levels over 3 months.",
    imageUrl:
      "https://images.unsplash.com/photo-1581595220921-32f2c1f17f92?auto=format&fit=crop&w=800&q=80",
    tags: ["popular"],
  },
  {
    id: "l3",
    name: "Thyroid Profile (T3/T4/TSH)",
    category: "Thyroid",
    price: 799,
    description: "Screens thyroid function and hormonal balance.",
    imageUrl:
      "https://images.unsplash.com/photo-1582719201952-ea63ac1671dc?auto=format&fit=crop&w=800&q=80",
    tags: ["popular"],
  },
  {
    id: "l4",
    name: "Full Body Checkup",
    category: "Full Body",
    price: 1999,
    description: "Comprehensive package including blood, liver, kidney.",
    imageUrl:
      "https://images.unsplash.com/photo-1582719478183-2ab71b7f44fb?auto=format&fit=crop&w=800&q=80",
    tags: ["popular"],
  },
  {
    id: "l5",
    name: "Vitamin D Test",
    category: "Blood",
    price: 999,
    description: "Detects Vitamin D deficiency affecting bones & immunity.",
    imageUrl:
      "https://images.unsplash.com/photo-1582719478291-6c2b7b29ea62?auto=format&fit=crop&w=800&q=80",
    tags: [],
  },
  {
    id: "l6",
    name: "Lipid Profile",
    category: "Blood",
    price: 899,
    description: "Measures cholesterol and triglycerides for heart risk.",
    imageUrl:
      "https://images.unsplash.com/photo-1582719478177-2cf81f170d72?auto=format&fit=crop&w=800&q=80",
    tags: ["popular"],
  },
];

function listLabs(req, res) {
  const category = (req.query.category || "").toString();
  const q = (req.query.q || "").toString().toLowerCase();
  const tag = (req.query.tag || "").toString().toLowerCase();

  let result = labs;
  if (category) {
    result = result.filter((l) => l.category === category);
  }
  if (q) {
    result = result.filter((l) => l.name.toLowerCase().includes(q));
  }
  if (tag) {
    result = result.filter((l) => l.tags.some((t) => t.toLowerCase() === tag));
  }

  return res.json({ labs: result });
}

module.exports = { listLabs };
