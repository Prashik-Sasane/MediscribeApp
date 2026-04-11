const mongoose = require('mongoose');
const Doctor = require('./src/models/Doctor');
const Medicine = require('./src/models/Medicine');
const LabTest = require('./src/models/LabTest');

async function checkDatabase() {
  try {
    // Connect to database
    await mongoose.connect(process.env.MONGO_URI || 'mongodb+srv://prashiksasane9_db_user:kIuu8wc2jo5ZYI94@cluster0.rng0jwz.mongodb.net/mediscribe?retryWrites=true&w=majority');
    console.log('✅ Connected to MongoDB');

    // Check Doctors
    const doctors = await Doctor.find({});
    console.log(`\n📊 Doctors in database: ${doctors.length}`);
    if (doctors.length > 0) {
      console.log('Sample doctors:');
      doctors.slice(0, 3).forEach(d => {
        console.log(`  - ${d.name} (${d.specialty})`);
      });
    }

    // Check Medicines/Products
    const medicines = await Medicine.find({});
    console.log(`\n📊 Medicines/Products in database: ${medicines.length}`);
    if (medicines.length > 0) {
      console.log('Sample medicines/products:');
      medicines.slice(0, 5).forEach(m => {
        console.log(`  - ${m.name} (${m.category}) - $${m.price}`);
      });
    }

    // Check Lab Tests
    const labTests = await LabTest.find({});
    console.log(`\n📊 Lab Tests in database: ${labTests.length}`);
    if (labTests.length > 0) {
      console.log('Sample lab tests:');
      labTests.slice(0, 3).forEach(l => {
        console.log(`  - ${l.name} (${l.category}) - $${l.price}`);
      });
    }

    console.log('\n✅ Database check complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkDatabase();
