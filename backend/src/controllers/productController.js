const products = [
  {
    id: "p1",
    name: "Dolo 650 (Paracetamol)",
    category: "Medicines",
    price: 32,
    mrp: 40,
    imageUrl:
      "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=800&q=80",
    tags: ["trending"],
  },
  {
    id: "p2",
    name: "Vitamin C Gummies",
    category: "Supplements",
    price: 299,
    mrp: 399,
    imageUrl:
      "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?auto=format&fit=crop&w=800&q=80",
    tags: ["bestseller"],
  },
  {
    id: "p3",
    name: "Digital Thermometer",
    category: "Devices",
    price: 199,
    mrp: 249,
    imageUrl:
      "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=800&q=80",
    tags: ["bestseller", "trending"],
  },
  {
    id: "p4",
    name: "Moisturizing Lotion",
    category: "Personal Care",
    price: 249,
    mrp: 299,
    imageUrl:
      "https://images.unsplash.com/photo-1611930022073-5b4df1d2c312?auto=format&fit=crop&w=800&q=80",
    tags: ["trending"],
  },
  {
    id: "p5",
    name: "Blood Pressure Monitor",
    category: "Devices",
    price: 1299,
    mrp: 1599,
    imageUrl:
      "https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=800&q=80",
    tags: ["bestseller"],
  },
  {
    id: "p6",
    name: "Protein Supplement (1kg)",
    category: "Supplements",
    price: 1599,
    mrp: 1899,
    imageUrl:
      "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?auto=format&fit=crop&w=800&q=80",
    tags: ["bestseller"],
  },
  {
    id: "p7",
    name: "Hand Sanitizer (500ml)",
    category: "Personal Care",
    price: 149,
    mrp: 199,
    imageUrl:
      "https://images.unsplash.com/photo-1583947581924-860bdaed7b4f?auto=format&fit=crop&w=800&q=80",
    tags: [],
  },
  {
    id: "p8",
    name: "Cetirizine 10mg",
    category: "Medicines",
    price: 49,
    mrp: 59,
    imageUrl:
      "https://images.unsplash.com/photo-1550572017-edd951aa8f7e?auto=format&fit=crop&w=800&q=80",
    tags: ["bestseller"],
  },
];

function listProducts(req, res) {
  const category = (req.query.category || "").toString();
  const q = (req.query.q || "").toString().toLowerCase();
  const tag = (req.query.tag || "").toString().toLowerCase();

  let result = products;
  if (category) {
    result = result.filter((p) => p.category === category);
  }
  if (q) {
    result = result.filter((p) => p.name.toLowerCase().includes(q));
  }
  if (tag) {
    result = result.filter((p) => p.tags.some((t) => t.toLowerCase() === tag));
  }

  return res.json({ products: result });
}

module.exports = { listProducts };
