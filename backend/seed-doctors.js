const mongoose = require('mongoose');
const Doctor = require('./src/models/Doctor');

async function seedDoctors() {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://prashiksasane9_db_user:kIuu8wc2jo5ZYI94@cluster0.rng0jwz.mongodb.net/mediscribe?retryWrites=true&w=majority');
    console.log('✅ Connected to MongoDB');

    // Sample doctors data
    const doctors = [
      {
        name: "Dr. Sarah Johnson",
        specialty: "Cardiologist",
        imageUrl: "https://img.freepik.com/free-photo/friendly-smiling-woman-doctor-nurse-wearing-medical-mask-holding-stethoscope_114579-111162.jpg",
        rating: 4.9,
        experience: 15,
        fee: 500,
        lat: 18.5204,
        lng: 73.8567,
        location: {
          type: "Point",
          coordinates: [73.8567, 18.5204]
        },
        isOnline: true
      },
      {
        name: "Dr. Michael Chen",
        specialty: "Dentist",
        imageUrl: "https://img.freepik.com/free-photo/handsome-young-doctor-man-with-stethoscope-grey-wall_23-2148110996.jpg",
        rating: 4.8,
        experience: 10,
        fee: 400,
        lat: 18.5304,
        lng: 73.8667,
        location: {
          type: "Point",
          coordinates: [73.8667, 18.5304]
        },
        isOnline: true
      },
      {
        name: "Dr. Priya Sharma",
        specialty: "Neurologist",
        imageUrl: "https://img.freepik.com/free-photo/attractive-female-doctor-presenting_23-2148332159.jpg",
        rating: 4.9,
        experience: 12,
        fee: 600,
        lat: 18.5104,
        lng: 73.8467,
        location: {
          type: "Point",
          coordinates: [73.8467, 18.5104]
        },
        isOnline: true
      },
      {
        name: "Dr. Rajesh Kumar",
        specialty: "Orthopedic",
        imageUrl: "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-coat_23-2148332148.jpg",
        rating: 4.7,
        experience: 18,
        fee: 550,
        lat: 18.5404,
        lng: 73.8767,
        location: {
          type: "Point",
          coordinates: [73.8767, 18.5404]
        },
        isOnline: true
      },
      {
        name: "Dr. Anita Desai",
        specialty: "Dermatologist",
        imageUrl: "https://img.freepik.com/free-photo/pleased-young-female-doctor-wearing-medical-robe-stethoscope-around-neck-standing-closed-posture_409827-254.jpg",
        rating: 4.8,
        experience: 8,
        fee: 450,
        lat: 18.5004,
        lng: 73.8367,
        location: {
          type: "Point",
          coordinates: [73.8367, 18.5004]
        },
        isOnline: true
      },
      {
        name: "Dr. Vikram Patel",
        specialty: "General Physician",
        imageUrl: "https://img.freepik.com/free-photo/smiling-doctor-with-strethoscope-isolated-grey_651396-974.jpg",
        rating: 4.6,
        experience: 20,
        fee: 350,
        lat: 18.5304,
        lng: 73.8567,
        location: {
          type: "Point",
          coordinates: [73.8567, 18.5304]
        },
        isOnline: true
      }
    ];

    // Clear existing doctors
    await Doctor.deleteMany({});
    console.log('🗑️ Cleared existing doctors');

    // Insert new doctors
    const inserted = await Doctor.insertMany(doctors);
    console.log(`\n✅ Successfully added ${inserted.length} doctors to database:`);
    inserted.forEach((d, i) => {
      console.log(`  ${i + 1}. ${d.name} - ${d.specialty} (Rating: ${d.rating})`);
    });

    console.log('\n✅ Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

seedDoctors();
