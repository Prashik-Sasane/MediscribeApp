require("dotenv").config();
const mongoose = require("mongoose");
const Medicine = require("./src/models/Medicine");

const medicines = [
  // Medicines
  {
    name: "Dolo 650 (Paracetamol)",
    category: "Medicines",
    price: 32,
    mrp: 40,
    imageUrl: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800",
    stock: 500,
    requiresPrescription: false,
    tags: ["trending", "bestseller"],
  },
  {
    name: "Cetirizine 10mg",
    category: "Medicines",
    price: 49,
    mrp: 59,
    imageUrl: "https://images.unsplash.com/photo-1550572017-edd951aa8f7e?w=800",
    stock: 450,
    requiresPrescription: false,
    tags: ["bestseller"],
  },
  {
    name: "Amoxicillin 500mg",
    category: "Medicines",
    price: 120,
    mrp: 150,
    imageUrl: "https://images.unsplash.com/photo-1471864190281-a93a3070b6de?w=800",
    stock: 300,
    requiresPrescription: true,
    tags: ["antibiotic"],
  },
  {
    name: "Ibuprofen 400mg",
    category: "Medicines",
    price: 55,
    mrp: 70,
    imageUrl: "https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800",
    stock: 400,
    requiresPrescription: false,
    tags: ["pain-relief"],
  },
  {
    name: "Omeprazole 20mg",
    category: "Medicines",
    price: 85,
    mrp: 100,
    imageUrl: "https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800",
    stock: 350,
    requiresPrescription: false,
    tags: ["acidity"],
  },
  {
    name: "Metformin 500mg",
    category: "Medicines",
    price: 65,
    mrp: 80,
    imageUrl: "https://images.unsplash.com/photo-1576602976047-174e57a47881?w=800",
    stock: 280,
    requiresPrescription: true,
    tags: ["diabetes"],
  },
  {
    name: "Azithromycin 500mg",
    category: "Medicines",
    price: 145,
    mrp: 175,
    imageUrl: "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800",
    stock: 250,
    requiresPrescription: true,
    tags: ["antibiotic", "trending"],
  },
  {
    name: "Losartan 50mg",
    category: "Medicines",
    price: 95,
    mrp: 115,
    imageUrl: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800",
    stock: 320,
    requiresPrescription: true,
    tags: ["blood-pressure"],
  },
  
  // Supplements
  {
    name: "Vitamin C Gummies",
    category: "Supplements",
    price: 299,
    mrp: 399,
    imageUrl: "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800",
    stock: 200,
    requiresPrescription: false,
    tags: ["bestseller", "immunity"],
  },
  {
    name: "Protein Supplement (1kg)",
    category: "Supplements",
    price: 1599,
    mrp: 1899,
    imageUrl: "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=800",
    stock: 150,
    requiresPrescription: false,
    tags: ["bestseller", "fitness"],
  },
  {
    name: "Omega-3 Fish Oil",
    category: "Supplements",
    price: 599,
    mrp: 749,
    imageUrl: "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800",
    stock: 180,
    requiresPrescription: false,
    tags: ["heart-health"],
  },
  {
    name: "Multivitamin Tablets",
    category: "Supplements",
    price: 449,
    mrp: 549,
    imageUrl: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800",
    stock: 220,
    requiresPrescription: false,
    tags: ["daily-health"],
  },
  {
    name: "Calcium + Vitamin D3",
    category: "Supplements",
    price: 349,
    mrp: 429,
    imageUrl: "https://images.unsplash.com/photo-1550572017-edd951aa8f7e?w=800",
    stock: 190,
    requiresPrescription: false,
    tags: ["bone-health"],
  },
  {
    name: "Iron + Folic Acid",
    category: "Supplements",
    price: 199,
    mrp: 249,
    imageUrl: "https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800",
    stock: 260,
    requiresPrescription: false,
    tags: ["anemia"],
  },

  // Devices
  {
    name: "Digital Thermometer",
    category: "Devices",
    price: 199,
    mrp: 249,
    imageUrl: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800",
    stock: 100,
    requiresPrescription: false,
    tags: ["bestseller", "trending"],
  },
  {
    name: "Blood Pressure Monitor",
    category: "Devices",
    price: 1299,
    mrp: 1599,
    imageUrl: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800",
    stock: 75,
    requiresPrescription: false,
    tags: ["bestseller"],
  },
  {
    name: "Glucometer Kit",
    category: "Devices",
    price: 899,
    mrp: 1099,
    imageUrl: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800",
    stock: 90,
    requiresPrescription: false,
    tags: ["diabetes"],
  },
  {
    name: "Pulse Oximeter",
    category: "Devices",
    price: 699,
    mrp: 899,
    imageUrl: "https://images.unsplash.com/photo-1583947581924-860bdaed7b4f?w=800",
    stock: 110,
    requiresPrescription: false,
    tags: ["trending"],
  },
  {
    name: "Nebulizer Machine",
    category: "Devices",
    price: 1899,
    mrp: 2299,
    imageUrl: "https://images.unsplash.com/photo-1582719478170-2c3f6f0d2e62?w=800",
    stock: 60,
    requiresPrescription: false,
    tags: ["respiratory"],
  },

  // Personal Care
  {
    name: "Moisturizing Lotion",
    category: "Personal Care",
    price: 249,
    mrp: 299,
    imageUrl: "https://images.unsplash.com/photo-1611930022073-5b4df1d2c312?w=800",
    stock: 300,
    requiresPrescription: false,
    tags: ["trending", "skincare"],
  },
  {
    name: "Hand Sanitizer (500ml)",
    category: "Personal Care",
    price: 149,
    mrp: 199,
    imageUrl: "https://images.unsplash.com/photo-1583947581924-860bdaed7b4f?w=800",
    stock: 400,
    requiresPrescription: false,
    tags: ["hygiene"],
  },
  {
    name: "Antiseptic Cream",
    category: "Personal Care",
    price: 179,
    mrp: 219,
    imageUrl: "https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800",
    stock: 350,
    requiresPrescription: false,
    tags: ["first-aid"],
  },
  {
    name: "Sunscreen SPF 50",
    category: "Personal Care",
    price: 399,
    mrp: 499,
    imageUrl: "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800",
    stock: 280,
    requiresPrescription: false,
    tags: ["skincare", "trending"],
  },
  {
    name: "Oral Mouthwash",
    category: "Personal Care",
    price: 199,
    mrp: 249,
    imageUrl: "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=800",
    stock: 320,
    requiresPrescription: false,
    tags: ["oral-care"],
  },
];

async function seedMedicines() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB");

    // Clear existing medicines
    await Medicine.deleteMany({});
    console.log("Cleared existing medicines");

    // Insert new medicines
    const result = await Medicine.insertMany(medicines);
    console.log(`Inserted ${result.length} medicines`);

    console.log("✅ Database seeded successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    process.exit(1);
  }
}

seedMedicines();
