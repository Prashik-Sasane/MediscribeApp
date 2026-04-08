// Admin Utility: Verify Doctors
// Run this with Node.js to verify doctors in the database
// Usage: node verify-doctor.js <doctor-email> [license-number]

const mongoose = require('mongoose');
const DoctorAccount = require('./src/models/DoctorAccount');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mediscribe')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

async function verifyDoctor(email, licenseNumber) {
  try {
    if (!email) {
      console.log('\n📋 Usage: node verify-doctor.js <doctor-email> [license-number]');
      console.log('\n🔍 Finding all unverified doctors...\n');
      
      const unverified = await DoctorAccount.find({ isVerified: false })
        .select('name email specialty experience createdAt');
      
      if (unverified.length === 0) {
        console.log('✅ All doctors are verified!');
      } else {
        console.log(`Found ${unverified.length} unverified doctor(s):\n`);
        unverified.forEach((doc, i) => {
          console.log(`${i + 1}. ${doc.name}`);
          console.log(`   Email: ${doc.email}`);
          console.log(`   Specialty: ${doc.specialty}`);
          console.log(`   Experience: ${doc.experience} years`);
          console.log(`   Registered: ${doc.createdAt}\n`);
        });
      }
      process.exit(0);
    }

    const doctor = await DoctorAccount.findOne({ email: email.toLowerCase() });
    
    if (!doctor) {
      console.log(`❌ Doctor with email "${email}" not found`);
      process.exit(1);
    }

    if (doctor.isVerified) {
      console.log(`✅ Doctor "${doctor.name}" is already verified`);
      process.exit(0);
    }

    // Verify the doctor
    doctor.isVerified = true;
    if (licenseNumber) {
      doctor.licenseNumber = licenseNumber;
    }
    
    await doctor.save();

    console.log('\n✅ Doctor verified successfully!');
    console.log(`   Name: ${doctor.name}`);
    console.log(`   Email: ${doctor.email}`);
    console.log(`   Specialty: ${doctor.specialty}`);
    console.log(`   License: ${doctor.licenseNumber || 'Not provided'}`);
    console.log('\n🎉 This doctor will now appear in the "Find Doctors" screen!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

// Get command line arguments
const args = process.argv.slice(2);
const email = args[0];
const licenseNumber = args[1];

verifyDoctor(email, licenseNumber);
