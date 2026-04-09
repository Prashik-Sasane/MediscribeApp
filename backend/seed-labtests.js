require("dotenv").config();
const mongoose = require("mongoose");
const LabTest = require("./src/models/LabTest");

const labTests = [
  // Blood Tests
  {
    name: "Complete Blood Count (CBC)",
    category: "Blood",
    price: 499,
    description: "Measures RBC, WBC, platelets, hemoglobin and other blood parameters",
    imageUrl: "https://images.unsplash.com/photo-1582719478170-2c3f6f0d2e62?w=800",
    tags: ["popular", "bestseller"],
    parametersCount: 20,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Lipid Profile",
    category: "Blood",
    price: 899,
    description: "Measures cholesterol and triglycerides for heart risk assessment",
    imageUrl: "https://images.unsplash.com/photo-1582719478177-2cf81f170d72?w=800",
    tags: ["popular", "heart-health"],
    parametersCount: 8,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Vitamin D Test",
    category: "Blood",
    price: 999,
    description: "Detects Vitamin D deficiency affecting bones and immunity",
    imageUrl: "https://images.unsplash.com/photo-1582719478291-6c2b7b29ea62?w=800",
    tags: ["trending"],
    parametersCount: 1,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Liver Function Test (LFT)",
    category: "Blood",
    price: 699,
    description: "Evaluates liver health and detects liver diseases",
    imageUrl: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800",
    tags: ["popular"],
    parametersCount: 12,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Kidney Function Test (KFT)",
    category: "Blood",
    price: 749,
    description: "Assesses kidney function and detects renal disorders",
    imageUrl: "https://images.unsplash.com/photo-1582719201952-ea63ac1671dc?w=800",
    tags: ["popular"],
    parametersCount: 10,
    isHomeCollectionAvailable: true,
  },

  // Diabetes
  {
    name: "HbA1c (Diabetes)",
    category: "Diabetes",
    price: 699,
    description: "Average blood sugar levels over 3 months for diabetes management",
    imageUrl: "https://images.unsplash.com/photo-1581595220921-32f2c1f17f92?w=800",
    tags: ["popular", "bestseller"],
    parametersCount: 1,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Fasting Blood Sugar",
    category: "Diabetes",
    price: 299,
    description: "Measures blood glucose levels after fasting",
    imageUrl: "https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?w=800",
    tags: ["diabetes"],
    parametersCount: 1,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Post Prandial Blood Sugar",
    category: "Diabetes",
    price: 349,
    description: "Measures blood glucose levels after meal",
    imageUrl: "https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800",
    tags: ["diabetes"],
    parametersCount: 1,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Glucose Tolerance Test",
    category: "Diabetes",
    price: 899,
    description: "Comprehensive test for diabetes diagnosis",
    imageUrl: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800",
    tags: ["diabetes"],
    parametersCount: 4,
    isHomeCollectionAvailable: false,
  },

  // Thyroid
  {
    name: "Thyroid Profile (T3/T4/TSH)",
    category: "Thyroid",
    price: 799,
    description: "Screens thyroid function and hormonal balance",
    imageUrl: "https://images.unsplash.com/photo-1582719201952-ea63ac1671dc?w=800",
    tags: ["popular", "bestseller"],
    parametersCount: 3,
    isHomeCollectionAvailable: true,
  },
  {
    name: "TSH Test",
    category: "Thyroid",
    price: 399,
    description: "Measures Thyroid Stimulating Hormone levels",
    imageUrl: "https://images.unsplash.com/photo-1576602976047-174e57a47881?w=800",
    tags: ["thyroid"],
    parametersCount: 1,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Free T3 & T4",
    category: "Thyroid",
    price: 599,
    description: "Measures active thyroid hormones",
    imageUrl: "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800",
    tags: ["thyroid"],
    parametersCount: 2,
    isHomeCollectionAvailable: true,
  },

  // Full Body
  {
    name: "Full Body Checkup",
    category: "Full Body",
    price: 1999,
    description: "Comprehensive package including blood, liver, kidney, thyroid and more",
    imageUrl: "https://images.unsplash.com/photo-1582719478183-2ab71b7f44fb?w=800",
    tags: ["popular", "bestseller", "value-pack"],
    parametersCount: 50,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Master Health Checkup",
    category: "Full Body",
    price: 2999,
    description: "Premium comprehensive health screening with 70+ parameters",
    imageUrl: "https://images.unsplash.com/photo-1581595220921-32f2c1f17f92?w=800",
    tags: ["premium", "bestseller"],
    parametersCount: 70,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Basic Health Package",
    category: "Full Body",
    price: 999,
    description: "Essential health screening package",
    imageUrl: "https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800",
    tags: ["value-pack"],
    parametersCount: 25,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Senior Citizen Health Package",
    category: "Full Body",
    price: 2499,
    description: "Specialized health checkup for seniors above 60 years",
    imageUrl: "https://images.unsplash.com/photo-1550572017-edd951aa8f7e?w=800",
    tags: ["senior-care"],
    parametersCount: 60,
    isHomeCollectionAvailable: true,
  },

  // Heart
  {
    name: "Cardiac Risk Markers",
    category: "Heart",
    price: 1499,
    description: "Advanced cardiac biomarkers for heart disease risk",
    imageUrl: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800",
    tags: ["heart-health", "advanced"],
    parametersCount: 6,
    isHomeCollectionAvailable: true,
  },
  {
    name: "ECG Test",
    category: "Heart",
    price: 599,
    description: "Electrocardiogram to check heart rhythm and electrical activity",
    imageUrl: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800",
    tags: ["heart-health"],
    parametersCount: 1,
    isHomeCollectionAvailable: false,
  },

  // Kidney
  {
    name: "Kidney Care Package",
    category: "Kidney",
    price: 1299,
    description: "Comprehensive kidney function assessment",
    imageUrl: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800",
    tags: ["kidney"],
    parametersCount: 15,
    isHomeCollectionAvailable: true,
  },
  {
    name: "Urine Routine",
    category: "Kidney",
    price: 199,
    description: "Basic urine analysis for kidney and urinary tract health",
    imageUrl: "https://images.unsplash.com/photo-1582719478291-6c2b7b29ea62?w=800",
    tags: ["basic"],
    parametersCount: 12,
    isHomeCollectionAvailable: true,
  },
];

async function seedLabTests() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("Connected to MongoDB");

    // Clear existing lab tests
    await LabTest.deleteMany({});
    console.log("Cleared existing lab tests");

    // Insert new lab tests
    const result = await LabTest.insertMany(labTests);
    console.log(`Inserted ${result.length} lab tests`);

    console.log("✅ Database seeded successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    process.exit(1);
  }
}

seedLabTests();
