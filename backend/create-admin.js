// Create Admin Account Script
// Run: node create-admin.js

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./src/models/User');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mediscribe')
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

async function createAdmin() {
  try {
    const adminEmail = 'admin@mediscribe.com';
    const adminPassword = 'admin123';

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email: adminEmail.toLowerCase() });
    
    if (existingAdmin) {
      console.log('\n⚠️  Admin account already exists!');
      console.log(`   Email: ${existingAdmin.email}`);
      console.log(`   Role: ${existingAdmin.role}`);
      console.log('\n💡 To reset password, delete the account first:');
      console.log(`   db.users.deleteOne({ email: "${adminEmail}" })`);
      process.exit(0);
    }

    // Create admin account
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    const admin = await User.create({
      name: 'Admin User',
      email: adminEmail.toLowerCase(),
      passwordHash: passwordHash,
      role: 'admin',
      coins: 0,
      city: 'Pune'
    });

    console.log('\n✅ Admin account created successfully!');
    console.log('\n📋 Login Credentials:');
    console.log(`   Email: ${admin.email}`);
    console.log(`   Password: ${adminPassword}`);
    console.log(`   Role: ${admin.role}`);
    console.log('\n🚀 Next Steps:');
    console.log('   1. Login with these credentials in the app');
    console.log('   2. Copy your auth token from debug/console');
    console.log('   3. Open Admin Dashboard and paste the token');
    console.log('   4. Start verifying doctors!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createAdmin();
