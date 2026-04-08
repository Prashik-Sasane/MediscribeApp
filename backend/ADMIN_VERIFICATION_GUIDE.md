# 🔐 Admin Doctor Verification Guide

## 📋 **Overview**
Doctors must be verified before they appear in the "Find Doctors" screen. You have **3 professional options**:

---

## 🎯 **Option 1: Auto-Verify on Registration** (For Development/Testing)

**Best for:** Development, testing, or if you trust all doctors

### How to Enable:

**Method A: Environment Variable**
```bash
# In your .env file
AUTO_VERIFY_DOCTORS=true
```

**Method B: Send flag during registration**
```javascript
// In app_state.dart or registration screen
await appState.doctorSignup(
  name: name,
  email: email,
  password: password,
  specialty: specialty,
  autoVerify: true, // Add this!
);
```

**Result:** Doctors are instantly visible after registration ✅

---

## 🎨 **Option 2: Admin Dashboard** (Recommended for Production)

**Best for:** Managing 10-1000+ doctors professionally

### Features:
✅ View all pending doctors  
✅ Verify doctors one-by-one  
✅ **Bulk verify all doctors** (1000+ at once!)  
✅ See doctor details (experience, rating, license)  
✅ Reject fraudulent doctors  

### How to Use:

1. **Open Admin Dashboard:**
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
   );
   ```

2. **Enter Admin Token** (from admin login)

3. **Choose Action:**
   - **Single Verify:** Click "Verify" button on individual doctor
   - **Bulk Verify:** Click "Verify All Listed" button
   - **Database Bulk:** Click "Bulk Verify DB" to verify ALL pending doctors

### Bulk Verification API:

```http
PUT http://localhost:5000/api/doctors/admin/bulk-verify
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "verifyAll": true
}
```

**Response:**
```json
{
  "message": "Verified 1247 doctors",
  "modifiedCount": 1247
}
```

---

## 📄 **Option 3: Document Upload + Manual Review** (Enterprise)

**Best for:** High-security healthcare platforms

### Workflow:

1. **Doctor Registration:**
   - Doctor uploads: Medical License, Certificates, ID Proof
   - Status: `isVerified: false`

2. **Admin Review:**
   - Admin opens dashboard
   - Reviews uploaded documents
   - Clicks "Verify" or "Reject"

3. **Notification:**
   - Doctor gets email/SMS notification
   - Status updated in database

*(This requires additional document upload implementation)*

1. **Create Admin Account First** (one-time setup):
   ```javascript
   // In MongoDB Compass or Shell
   db.users.insertOne({
     name: "Admin",
     email: "admin@mediscribe.com",
     passwordHash: "$2a$10$...", // Hash of "admin123"
     role: "admin",
     coins: 0,
     city: "Pune"
   })
   ```

2. **Login as Admin** in the app

3. **Open Admin Verification Screen**:
   - Navigate to: `AdminVerifyDoctorsScreen`
   - Or add a button in your app to access it

4. **Enter Admin Token** and click refresh

5. **Click "VERIFY DOCTOR"** button for each doctor

---

### **Method 2: Using Command Line Script**

```bash
# Navigate to backend folder
cd d:\Mesdiscribe\MediscribeApp\backend

# View all unverified doctors
node verify-doctor.js

# Verify a specific doctor
node verify-doctor.js doctor@example.com

# Verify with license number
node verify-doctor.js doctor@example.com ML12345
```

**Example Output:**
```
✅ Doctor verified successfully!
   Name: Dr. John Smith
   Email: john@example.com
   Specialty: Cardiologist
   License: ML12345

🎉 This doctor will now appear in the "Find Doctors" screen!
```

---

### **Method 3: Using Postman/API**

**Step 1: Login as Admin and get token**
```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "admin@mediscribe.com",
  "password": "admin123"
}
```

**Step 2: View unverified doctors**
```http
GET http://localhost:5000/api/doctors/admin/unverified
Authorization: Bearer YOUR_ADMIN_TOKEN
```

**Step 3: Verify a doctor**
```http
PUT http://localhost:5000/api/doctors/DOCTOR_ID/verify
Authorization: Bearer YOUR_ADMIN_TOKEN
Content-Type: application/json

{
  "isVerified": true,
  "licenseNumber": "ML12345"
}
```

---

### **Method 4: Using MongoDB Directly**

```javascript
// In MongoDB Compass or Mongo Shell

// Find unverified doctors
db.doctoraccounts.find({ isVerified: false })

// Verify a specific doctor
db.doctoraccounts.updateOne(
  { email: "doctor@example.com" },
  { $set: { isVerified: true, licenseNumber: "ML12345" } }
)

// Verify ALL doctors (for testing)
db.doctoraccounts.updateMany(
  {},
  { $set: { isVerified: true } }
)
```

---

## 🎯 **Quick Testing Workflow**

### **Test Doctor Registration & Verification:**

1. **Register a new doctor:**
   - Open app → Login Screen
   - Select "Doctor" toggle
   - Click "Don't have an account? Sign Up"
   - Fill in: Name, Email, Password, Specialty
   - Click "Create Account"

2. **Check doctor is NOT visible (unverified):**
   - Login as patient
   - Go to "Find Doctors" screen
   - Doctor should NOT appear ❌

3. **Verify the doctor:**
   ```bash
   cd d:\Mesdiscribe\MediscribeApp\backend
   node verify-doctor.js
   # Copy doctor email from list
   node verify-doctor.js doctor@example.com
   ```

4. **Check doctor IS visible (verified):**
   - Go back to "Find Doctors" screen
   - Pull down to refresh
   - Doctor NOW appears with green ✓ badge ✅

---

## 📊 **Doctor Status Flow**

```
┌─────────────────────────────────────┐
│  Doctor Registers                   │
│  isVerified: false                  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  NOT visible to patients            │
│  Cannot receive appointments        │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Admin verifies doctor              │
│  (via panel/script/API/MongoDB)     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  isVerified: true                   │
│  VISIBLE in Find Doctors screen ✅  │
│  Can receive appointments ✅        │
└─────────────────────────────────────┘
```

---

## 🔧 **Admin Panel Setup (Optional)**

To add the admin verification screen to your app navigation:

```dart
// In main_screen.dart or wherever you manage routes
import 'package:mediscribe_app/screens/admin_verify_doctors_screen.dart';

// Add to navigation or create a secret route
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AdminVerifyDoctorsScreen()),
);
```

---

## ❓ **Troubleshooting**

### **Problem: "No verified doctors found" message**
**Solution:** No doctors have been verified yet. Use one of the methods above to verify doctors.

### **Problem: Doctor still not visible after verification**
**Solution:** 
1. Pull down to refresh the "Find Doctors" screen
2. Check if backend is running
3. Verify the doctor in database: `db.doctoraccounts.findOne({email: "doctor@example.com"})`

### **Problem: Admin token not working**
**Solution:**
1. Make sure admin account has `role: "admin"`
2. Re-login to get fresh token
3. Check token expiration (tokens expire in 7 days)

---

## 🎉 **Summary**

- ✅ New doctors register with `isVerified: false`
- ✅ Unverified doctors are HIDDEN from patients
- ✅ Admin must verify doctors before they appear
- ✅ 4 methods to verify: Admin Panel, CLI Script, Postman, MongoDB
- ✅ Once verified, doctors appear immediately in "Find Doctors"

**Recommended:** Use `node verify-doctor.js` for quick verification during development!
