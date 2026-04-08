// Check Doctors in Database
// Run: node check-doctors.js

const mongoose = require('mongoose');
const DoctorAccount = require('./src/models/DoctorAccount');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mediscribe')
  .then(() => console.log('✅ Connected to MongoDB\n'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

async function checkDoctors() {
  try {
    // Get all doctors
    const allDoctors = await DoctorAccount.find().select('-passwordHash');
    
    console.log('📊 DOCTOR STATISTICS:');
    console.log('═'.repeat(50));
    console.log(`Total Doctors in Database: ${allDoctors.length}\n`);

    // Count verified vs unverified
    const verified = allDoctors.filter(d => d.isVerified === true);
    const unverified = allDoctors.filter(d => d.isVerified === false);

    console.log(`✅ Verified: ${verified.length}`);
    console.log(`⏳ Unverified: ${unverified.length}\n`);

    if (unverified.length > 0) {
      console.log('⏳ UNVERIFIED DOCTORS:');
      console.log('─'.repeat(50));
      unverified.forEach((doc, i) => {
        console.log(`${i + 1}. ${doc.name}`);
        console.log(`   Email: ${doc.email}`);
        console.log(`   Specialty: ${doc.specialty}`);
        console.log(`   Experience: ${doc.experience} years`);
        console.log(`   Fee: ₹${doc.fee}`);
        console.log(`   Registered: ${doc.createdAt}\n`);
      });
    }

    if (verified.length > 0) {
      console.log('\n✅ VERIFIED DOCTORS:');
      console.log('─'.repeat(50));
      verified.forEach((doc, i) => {
        console.log(`${i + 1}. ${doc.name}`);
        console.log(`   Email: ${doc.email}`);
        console.log(`   Specialty: ${doc.specialty}`);
        console.log(`   License: ${doc.licenseNumber || 'N/A'}\n`);
      });
    }

    if (allDoctors.length === 0) {
      console.log('⚠️  No doctors found in database!');
      console.log('\n💡 To add doctors:');
      console.log('   1. Open the app');
      console.log('   2. Select "Doctor" role');
      console.log('   3. Sign up with doctor details');
      console.log('   4. Run this script again to see them\n');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

checkDoctors();
