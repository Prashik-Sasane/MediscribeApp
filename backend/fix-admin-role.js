// Fix Admin Role
// Run: node fix-admin-role.js

const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const User = require('./src/models/User');

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/mediscribe')
  .then(() => console.log('✅ Connected to MongoDB\n'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

async function fixAdminRole() {
  try {
    const adminEmail = 'admin@mediscribe.com';
    
    // Find existing admin
    let admin = await User.findOne({ email: adminEmail.toLowerCase() });
    
    if (!admin) {
      console.log('⚠️  Admin not found. Creating new admin...\n');
      
      // Create new admin
      const passwordHash = await bcrypt.hash('admin123', 10);
      admin = await User.create({
        name: 'Admin User',
        email: adminEmail.toLowerCase(),
        passwordHash: passwordHash,
        role: 'admin',
        coins: 0,
        city: 'Pune'
      });
      
      console.log('✅ New admin account created!');
    } else {
      console.log('🔧 Found existing admin account');
      console.log(`   Current role: "${admin.role}"\n`);
      
      if (admin.role !== 'admin') {
        console.log('⚠️  Role is incorrect! Fixing...\n');
        admin.role = 'admin';
        await admin.save();
        console.log('✅ Role updated to "admin"');
      } else {
        console.log('✅ Role is already "admin"');
      }
    }
    
    console.log('\n' + '='.repeat(50));
    console.log('📋 Admin Login Credentials:');
    console.log('═'.repeat(50));
    console.log(`Email: ${admin.email}`);
    console.log(`Password: admin123`);
    console.log(`Role: ${admin.role}`);
    console.log(`User ID: ${admin._id}`);
    console.log('='.repeat(50));
    
    console.log('\n🚀 Next Steps:');
    console.log('   1. Restart backend (npm start)');
    console.log('   2. Logout from app');
    console.log('   3. Login again with admin credentials');
    console.log('   4. Admin dashboard should now work!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

fixAdminRole();
