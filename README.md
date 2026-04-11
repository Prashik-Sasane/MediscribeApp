# 🏥 MediscribeApp

**Mediscribe** is a comprehensive AI-powered healthcare platform built with Flutter and Node.js that transforms how patients interact with medical services. From digitizing handwritten prescriptions to booking lab tests, ordering medicines, and consulting doctors — all in one seamless mobile experience.

---

## 🌟 Overview

MediscribeApp is a full-stack healthcare application that combines:
- **AI-powered prescription scanning** using Google ML Kit OCR + Gemini API
- **Real-time location services** with interactive maps (OpenStreetMap + flutter_map)
- **Doctor consultation booking** with geolocation-based nearby doctor discovery
- **Pharmacy & medicine ordering** with Stripe payment integration
- **Lab test booking** with home collection service
- **Order tracking** and appointment management
- **Push notifications** and real-time call handling

The app serves patients by providing a one-stop solution for all healthcare needs, from prescription digitization to medicine delivery and doctor consultations.

---

## ✨ Key Features

### 📸 Prescription Scanner
- Upload prescription images from Camera or Gallery
- On-device OCR using Google ML Kit (privacy-friendly, no internet required)
- AI-powered structuring via Google Gemini API
- Extracts medicine names, dosages, frequency, and instructions
- Medicine highlighting in results
- Export extracted data as PDF
- Share results using system share sheet

### 🗺️ Interactive Location & Maps
- Real-time GPS location detection
- Interactive OpenStreetMap with pan, zoom, and tap gestures
- Search any city/location with autocomplete suggestions
- Color-coded markers for different facility types:
  - 🔴 Hospitals (red)
  - 🔵 Clinics (blue)
  - 🟢 Medical Stores/Pharmacies (green)
  - 🟣 Doctors (purple)
- Real-time nearby places from OpenStreetMap Overpass API
- Fallback sample places when API is unavailable

### 👨‍⚕️ Doctor Discovery & Booking
- Location-based nearby doctor discovery
- Filter by specialty, distance, and rating
- Doctor profiles with experience, fees, and reviews
- Appointment booking with date/time selection
- Video consultation support
- Appointment rating system

### 💊 Pharmacy & Medicine Orders
- Browse medicines by category
- Search medicines by name
- Product cards with images, prices, and descriptions
- Shopping cart with persistent storage (SharedPreferences)
- Address management with multiple saved locations
- Stripe payment integration
- Order tracking with live status updates
- Order history

### 🧪 Lab Test Booking
- Browse lab tests by category (Blood, Diabetes, Thyroid, Full Body)
- Test packages with pricing and features
- Home collection service booking
- Address selection for sample collection
- Stripe payment processing
- Booking history and status tracking

### 📍 Address Management
- Multiple address support (Home, Office, etc.)
- Default address selection
- GPS-based location detection
- Manual address entry
- Address picker with saved locations
- Cross-screen address sharing (home → pharmacy/lab test)

### 🔔 Notifications & Calls
- In-app notification system
- Appointment reminders
- Order status updates
- Incoming call handling for video consultations
- Real-time socket connections

### 🔐 Authentication & User Management
- Email/password registration and login
- JWT token-based authentication
- User profile management
- Address book management
- Order and booking history

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     MOBILE APP (Flutter)                     │
├─────────────────────────────────────────────────────────────┤
│  UI Layer                                                    │
│  ├── Home Screen (Dashboard, Services, Nearby Places)       │
│  ├── Prescription Scanner (Upload, OCR, Results)            │
│  ├── Doctor Discovery & Booking                             │
│  ├── Pharmacy Shop (Products, Cart, Checkout)               │
│  ├── Lab Test Booking                                       │
│  ├── Location Screen (Interactive Map)                      │
│  ├── Order Tracking & History                               │
│  └── User Profile & Settings                                │
│                                                              │
│  Service Layer                                               │
│  ├── DoctorApiService (Doctor search, profiles)             │
│  ├── ProductService (Medicine catalog)                      │
│  ├── OrderService (Order management)                        │
│  ├── LabService (Lab test booking)                          │
│  ├── AuthService (Login, registration, addresses)           │
│  ├── PaymentService (Stripe integration)                    │
│  ├── SearchService (Global search)                          │
│  ├── NearbyPlacesService (OpenStreetMap API)                │
│  ├── LocationService (GPS, geocoding)                       │
│  ├── NotificationService (In-app notifications)             │
│  ├── CartService (Local cart management)                    │
│  └── IncomingCallService (Video calls)                      │
│                                                              │
│  State Management                                            │
│  └── AppScope (InheritedWidget for global state)            │
└─────────────────────────────────────────────────────────────┘
                              ↕ HTTP/WebSocket
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND API (Node.js + Express)            │
├─────────────────────────────────────────────────────────────┤
│  Controllers                                                 │
│  ├── authController (Registration, login, addresses)        │
│  ├── doctorController (Doctor CRUD, nearby search)          │
│  ├── productController (Medicine catalog)                   │
│  ├── orderController (Order management)                     │
│  ├── labController (Lab tests, bookings)                    │
│  ├── paymentController (Stripe integration)                 │
│  ├── locationController (Nearby clinics)                    │
│  └── notificationController                                 │
│                                                              │
│  Middleware                                                  │
│  ├── requireAuth (JWT verification)                         │
│  └── Error handling                                         │
│                                                              │
│  Models (MongoDB/Mongoose)                                   │
│  ├── User                                                   │
│  ├── DoctorAccount                                          │
│  ├── Product                                                │
│  ├── Order                                                  │
│  ├── LabTest                                                │
│  ├── LabBooking                                             │
│  └── Address                                                │
│                                                              │
│  Routes                                                      │
│  ├── /api/auth/*                                            │
│  ├── /api/doctors/*                                         │
│  ├── /api/products/*                                        │
│  ├── /api/orders/*                                          │
│  ├── /api/labs/*                                            │
│  ├── /api/payments/*                                        │
│  └── /api/location/*                                        │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                    DATABASE & EXTERNAL APIs                  │
├─────────────────────────────────────────────────────────────┤
│  MongoDB Atlas (Cloud Database)                              │
│  ├── Users collection                                       │
│  ├── Doctors collection (with 2dsphere geospatial index)    │
│  ├── Products collection                                    │
│  ├── Orders collection                                      │
│  ├── LabTests collection                                    │
│  └── LabBookings collection                                 │
│                                                              │
│  External APIs                                               │
│  ├── Google ML Kit OCR (On-device text recognition)         │
│  ├── Google Gemini API (AI text structuring)                │
│  ├── OpenStreetMap Overpass API (Nearby places)             │
│  ├── Nominatim API (Geocoding & reverse geocoding)          │
│  ├── Stripe API (Payment processing)                        │
│  └── flutter_map + TileLayer (Map rendering)                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Application Workflows

### 1. Prescription Scanning Workflow
```
User opens app
  ↓
Navigate to Upload Screen
  ↓
Select Image (Camera/Gallery)
  ↓
Image Compression (optional)
  ↓
Google ML Kit OCR (On-device)
  ↓
Raw Text Extracted
  ↓
Send to Gemini API
  ↓
AI Structures Data:
  - Medicine names
  - Dosages
  - Frequency
  - Instructions
  ↓
Display in Result Screen
  ↓
Export as PDF / Share
```

### 2. Nearby Doctor Discovery Workflow
```
App Launch
  ↓
Detect GPS Location
  ↓
Reverse Geocode (lat/lng → City name)
  ↓
Fetch Nearby Doctors (50km radius)
  ├─ Query: /api/doctors/nearby?lat=X&lng=Y&radiusKm=50
  └─ MongoDB $near with 2dsphere index
  ↓
If no nearby doctors → Fetch all doctors
  ↓
Display in Home Screen
  ↓
User taps doctor
  ↓
View Doctor Details
  ↓
Book Appointment
```

### 3. Medicine Ordering Workflow
```
User navigates to Pharmacy
  ↓
Browse/Search Medicines
  ↓
Add to Cart
  ├─ Cart stored in SharedPreferences
  └─ Persistent across sessions
  ↓
View Cart
  ↓
Select/Confirm Delivery Address
  ↓
Proceed to Checkout
  ↓
Stripe Payment
  ├─ Create payment intent
  ├─ Show payment sheet
  └─ Process payment
  ↓
Create Order in Backend
  ↓
Order Confirmation
  ↓
Track Order Status
```

### 4. Lab Test Booking Workflow
```
User navigates to Lab Tests
  ↓
Browse Test Categories
  ↓
Select Lab Test
  ↓
Choose Collection Address
  ↓
Confirm Booking Details
  ↓
Create Booking
  ├─ POST /api/labs/book
  └─ Returns booking ID
  ↓
Stripe Payment
  ↓
Booking Confirmed
  ↓
Home collection scheduled
  ↓
Report delivered in 24h
```

### 5. Location-Based Place Discovery Workflow
```
Home Screen loads
  ↓
Get GPS Coordinates
  ↓
Fetch Nearby Places (OpenStreetMap)
  ├─ Overpass API query
  ├─ 10km radius
  ├─ Hospitals, Clinics, Pharmacies, Doctors
  └─ Timeout: 15s, 2 retries
  ↓
If success → Show real places
  ↓
If fail/empty → Show sample places
  └─ 6 sample facilities with city name
  ↓
User taps "See All"
  ↓
Open Interactive Map Screen
  ├─ Full map interaction
  ├─ Search cities with Nominatim
  ├─ Color-coded markers
  └─ Real-time place data
```

---

## 🌐 API Endpoints

### Authentication
```
POST   /api/auth/register          Register new user
POST   /api/auth/login             User login
GET    /api/auth/profile           Get user profile
POST   /api/auth/addresses         Add new address
GET    /api/auth/addresses         Get user addresses
PUT    /api/auth/addresses/:id     Update address
DELETE /api/auth/addresses/:id     Delete address
```

### Doctors
```
GET    /api/doctors                Get all doctors (with filters)
GET    /api/doctors/nearby         Get nearby doctors by location
GET    /api/doctors/:id            Get doctor by ID
GET    /api/doctors/specialties    Get all specialties
```

### Products (Pharmacy)
```
GET    /api/products               Get all products
GET    /api/products/:id           Get product by ID
POST   /api/products               Create product (admin)
PUT    /api/products/:id           Update product (admin)
DELETE /api/products/:id           Delete product (admin)
```

### Orders
```
POST   /api/orders                 Create new order
GET    /api/orders/my              Get user's orders
GET    /api/orders/:id             Get order by ID
PUT    /api/orders/:id/status      Update order status
```

### Lab Tests
```
GET    /api/labs                   Get all lab tests
POST   /api/labs/book              Book a lab test
GET    /api/labs/my-bookings       Get user's bookings
```

### Payments
```
POST   /api/payments/create-intent  Create Stripe payment intent
POST   /api/payments/webhook        Stripe webhook handler
```

### Location
```
GET    /api/location/nearby-clinics  Get nearby clinics
```

---

## 🔧 Environment Variables

### Frontend (Flutter) - `assets/.env`

```env
# Google Gemini API Key (for AI prescription structuring)
GEMINI_API_KEY=your_gemini_api_key_here

# Backend API Base URL
API_BASE_URL=https://mediscribeapp.onrender.com/api

# Stripe Publishable Key (for payments)
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

### Backend (Node.js) - `.env`

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# MongoDB Connection
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/mediscribe?retryWrites=true&w=majority

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production

# Stripe Secret Key
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key

# Stripe Webhook Secret
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Google Gemini API Key
GEMINI_API_KEY=your_gemini_api_key

# CORS Origins (comma-separated)
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Email Configuration (optional, for notifications)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
```

---

## 💻 Tech Stack

### Mobile App (Frontend)
- **Framework:** Flutter 3.x, Dart
- **State Management:** InheritedWidget (AppScope)
- **UI Components:** Material Design 3, Custom Widgets
- **Maps:** flutter_map, latlong2, OpenStreetMap
- **OCR:** google_mlkit_text_recognition (on-device)
- **AI:** Google Gemini API (text structuring)
- **Payments:** flutter_stripe
- **Location:** geolocator, geocoding
- **Storage:** shared_preferences (cart, settings)
- **HTTP:** http package
- **Image Handling:** image_picker, flutter_image_compress
- **PDF:** pdf package
- **Animations:** AnimationController, CurvedAnimation
- **Real-time:** Socket.IO client (for calls)

### Backend API
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB Atlas (Mongoose ODM)
- **Authentication:** JWT (jsonwebtoken)
- **Password Hashing:** bcryptjs
- **Payments:** Stripe SDK
- **Validation:** express-validator
- **CORS:** cors middleware
- **Environment:** dotenv

### External Services
- **Database:** MongoDB Atlas (Cloud)
- **Maps:** OpenStreetMap + Overpass API
- **Geocoding:** Nominatim API
- **Payments:** Stripe
- **AI/ML:** Google Gemini API
- **OCR:** Google ML Kit (on-device)
- **Hosting:** Render.com (backend)

---

## 📁 Project Structure

```
MediscribeApp/
│
├── mediscribe_app/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart                  # App entry point
│   │   ├── core/
│   │   │   └── app_state.dart         # Global state management
│   │   │
│   │   ├── features/                  # Feature modules
│   │   │   ├── consultant/            # Doctor consultation
│   │   │   ├── doctors/               # Doctor discovery
│   │   │   ├── labtest/               # Lab test booking
│   │   │   ├── pharmacy/              # Medicine shop
│   │   │   └── service/               # Services screen
│   │   │
│   │   ├── models/                    # Data models
│   │   │   ├── product.dart
│   │   │   ├── lab_test.dart
│   │   │   └── ...
│   │   │
│   │   ├── screens/                   # App screens
│   │   │   ├── home_screen.dart
│   │   │   ├── location_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   ├── upload_screen.dart
│   │   │   └── ...
│   │   │
│   │   ├── services/                  # API & business logic
│   │   │   ├── doctor_api_service.dart
│   │   │   ├── product_service.dart
│   │   │   ├── order_service.dart
│   │   │   ├── lab_service.dart
│   │   │   ├── auth_api_service.dart
│   │   │   ├── payment_service.dart
│   │   │   ├── nearby_places_service.dart
│   │   │   ├── location_service.dart
│   │   │   ├── search_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── cart_service.dart
│   │   │   └── incoming_call_service.dart
│   │   │
│   │   ├── widgets/                   # Reusable UI components
│   │   │   └── healthcare/            # Healthcare-specific widgets
│   │   │       ├── product_card.dart
│   │   │       ├── order_card.dart
│   │   │       ├── address_picker_sheet.dart
│   │   │       └── ...
│   │   │
│   │   └── utils/                     # Utilities
│   │       └── medicine_highlighter.dart
│   │
│   ├── assets/
│   │   ├── .env                       # Environment variables (not committed)
│   │   ├── .env.example               # Template for .env
│   │   └── images/                    # App images
│   │
│   ├── android/                       # Android platform files
│   ├── ios/                           # iOS platform files
│   ├── web/                           # Web platform files
│   ├── windows/                       # Windows platform files
│   │
│   ├── pubspec.yaml                   # Dependencies
│   └── analysis_options.yaml          # Linting rules
│
├── backend/                           # Node.js Backend API
│   ├── src/
│   │   ├── app.js                     # Express app setup
│   │   ├── server.js                  # Server entry point
│   │   │
│   │   ├── controllers/               # Route controllers
│   │   │   ├── authController.js
│   │   │   ├── doctorController.js
│   │   │   ├── productController.js
│   │   │   ├── orderController.js
│   │   │   ├── labController.js
│   │   │   ├── paymentController.js
│   │   │   └── locationController.js
│   │   │
│   │   ├── models/                    # MongoDB models
│   │   │   ├── User.js
│   │   │   ├── Doctor.js
│   │   │   ├── Product.js
│   │   │   ├── Order.js
│   │   │   ├── LabTest.js
│   │   │   └── LabBooking.js
│   │   │
│   │   ├── routes/                    # API routes
│   │   │   ├── authRoutes.js
│   │   │   ├── doctorRoutes.js
│   │   │   ├── productRoutes.js
│   │   │   ├── orderRoutes.js
│   │   │   ├── labRoutes.js
│   │   │   └── paymentRoutes.js
│   │   │
│   │   ├── middleware/                # Express middleware
│   │   │   └── authMiddleware.js
│   │   │
│   │   └── config/                    # Configuration
│   │       └── database.js
│   │
│   ├── .env                           # Backend environment variables
│   ├── .env.example                   # Environment template
│   ├── package.json                   # Node dependencies
│   ├── seed-doctors.js                # Doctor seeder script
│   ├── seed-medicines.js              # Medicine seeder script
│   └── seed-labtests.js               # Lab test seeder script
│
└── README.md                          # This file
```

---

## 🚀 Quick Start Guide

### Prerequisites

- **Flutter SDK** (3.0 or higher)
- **Node.js** (16.x or higher)
- **MongoDB Atlas** account (free tier works)
- **Google Gemini API** key
- **Stripe** account (for payments)
- **Android Studio** / **VS Code** with Flutter extensions
- Physical device or emulator

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/MediscribeApp.git
cd MediscribeApp
```

### Step 2: Setup Backend

```bash
cd backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your credentials:
# - MongoDB URI
# - JWT Secret
# - Stripe keys
# - Gemini API key

# Seed the database with sample data
node seed-doctors.js
node seed-medicines.js
node seed-labtests.js

# Start backend server
npm start
# or for development with auto-reload:
npm run dev
```

Backend will run on `http://localhost:5000`

### Step 3: Setup Flutter App

```bash
cd ../mediscribe_app

# Get Flutter dependencies
flutter pub get

# Create environment file
cp assets/.env.example assets/.env

# Edit assets/.env:
# GEMINI_API_KEY=your_gemini_key
# API_BASE_URL=http://YOUR_LOCAL_IP:5000/api
# STRIPE_PUBLISHABLE_KEY=pk_test_your_key

# Run on connected device or emulator
flutter run
```

### Step 4: Testing the App

1. **Register a new account** on the app
2. **Enable GPS** to see nearby doctors and places
3. **Upload a prescription** to test OCR + AI
4. **Browse pharmacy** and add medicines to cart
5. **Book a lab test** with home collection
6. **Explore the map** and search for cities

---

## 🧪 Testing & Quality

### Flutter App

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Build APK
flutter build apk --release

# Build for specific platform
flutter build apk          # Android
flutter build web          # Web
flutter build windows      # Windows desktop
```

### Backend

```bash
# Run tests (when added)
npm test

# Lint code
npm run lint

# Check for vulnerabilities
npm audit
```

---

## 🗄️ Database Schema

### Key Collections

**Users**
```javascript
{
  _id: ObjectId,
  name: String,
  email: String (unique),
  passwordHash: String,
  avatarUrl: String,
  phone: String,
  role: String (patient/doctor/admin),
  createdAt: Date,
  updatedAt: Date
}
```

**Doctors**
```javascript
{
  _id: ObjectId,
  name: String,
  specialty: String,
  imageUrl: String,
  rating: Number,
  experience: Number,
  fee: Number,
  lat: Number,
  lng: Number,
  location: {
    type: "Point",
    coordinates: [lng, lat]  // GeoJSON format
  },
  isVerified: Boolean,
  isOnline: Boolean,
  licenseNumber: String,
  bio: String,
  phone: String,
  email: String
}
// 2dsphere index on location field for geospatial queries
```

**Products (Medicines)**
```javascript
{
  _id: ObjectId,
  name: String,
  description: String,
  price: Number,
  category: String,
  imageUrl: String,
  inStock: Boolean,
  manufacturer: String,
  requiresPrescription: Boolean
}
```

**Orders**
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  items: [{
    productId: ObjectId,
    name: String,
    qty: Number,
    price: Number
  }],
  total: Number,
  status: String (pending/processing/shipped/delivered),
  paymentStatus: String (pending/paid/failed),
  stripePaymentIntentId: String,
  address: {
    label: String,
    fullAddress: String,
    lat: Number,
    lng: Number
  },
  createdAt: Date
}
```

**LabBookings**
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: User),
  labTestId: ObjectId (ref: LabTest),
  address: {
    label: String,
    fullAddress: String,
    lat: Number,
    lng: Number,
    phone: String
  },
  preferredDate: Date,
  timeSlot: String,
  status: String (pending/confirmed/sample_collected/processing/report_ready/delivered),
  paymentMethod: String (stripe/razorpay/cod),
  paymentStatus: String (pending/paid/failed),
  stripePaymentIntentId: String,
  amount: Number,
  reportUrl: String
}
```

---

## 🔐 Security Considerations

- **JWT Authentication:** All protected routes require valid JWT token
- **Password Hashing:** bcrypt with salt rounds
- **HTTPS:** Production backend uses HTTPS
- **Environment Variables:** Sensitive data in .env files (not committed)
- **Input Validation:** express-validator on all endpoints
- **CORS:** Configured for specific origins
- **On-device OCR:** Prescription images never leave the device
- **Payment Security:** Stripe handles all payment data (PCI compliant)

---

## 📝 Notes for Contributors

### Code Style

- **Flutter:** Follow Dart formatting (`dart format .`)
- **Backend:** Use ESLint configuration
- **Commits:** Use conventional commits (feat:, fix:, docs:, etc.)
- **Documentation:** Comment complex logic

### Important Implementation Details

1. **MongoDB Geospatial Queries:**
   - Coordinates MUST be in [longitude, latitude] order (GeoJSON standard)
   - Distance in $near queries is in meters
   - 2dsphere index required on location field

2. **OpenStreetMap Overpass API:**
   - Rate limited; implement retry logic
   - Use reasonable timeouts (15-20 seconds)
   - Provide fallback data for offline scenarios

3. **Stripe Payments:**
   - Use publishable key in Flutter
   - Use secret key ONLY in backend
   - Always verify payment on backend

4. **Address Sharing:**
   - Home screen fetches user's default address
   - Pass address to pharmacy/lab test screens via constructor
   - Reduces API calls and improves UX

5. **State Management:**
   - AppScope (InheritedWidget) for global state
   - Access in `didChangeDependencies()`, NOT `initState()`
   - Use `mounted` checks before setState()

### Common Pitfalls to Avoid

- ❌ Calling `AppScope.of(context)` in `initState()`
- ❌ Using [lat, lng] instead of [lng, lat] for GeoJSON
- ❌ Forgetting `mounted` checks before setState()
- ❌ Hardcoding API keys or secrets
- ❌ Not handling API failures gracefully
- ❌ Missing error handling in async operations

---

## 🐛 Known Issues & Limitations

1. **OCR Accuracy:** Handwritten prescriptions may have varying accuracy
2. **OpenStreetMap Data:** Some areas may have limited medical facility data
3. **Payment Testing:** Use Stripe test mode for development
4. **Backend Hosting:** Free Render tier may have cold starts
5. **Image Upload:** Large images should be compressed before processing

---

## 🗺️ Roadmap & Future Enhancements

### Short Term
- [ ] Add unit and widget tests
- [ ] Implement video calling for consultations
- [ ] Add push notifications (Firebase)
- [ ] Improve search with fuzzy matching
- [ ] Add dark/light theme toggle

### Medium Term
- [ ] Real-time order tracking with live map
- [ ] Doctor availability calendar
- [ ] Prescription refill reminders
- [ ] Health records management
- [ ] Multi-language support

### Long Term
- [ ] AI symptom checker
- [ ] Telemedicine video consultations
- [ ] Integration with wearables
- [ ] Health analytics dashboard
- [ ] Insurance claim processing
- [ ] Emergency services integration

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'feat: add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Contribution Guidelines

- Write clear, documented code
- Follow existing code style
- Add tests for new features
- Update documentation as needed
- Test on multiple devices/screen sizes

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## ⚠️ Disclaimer

**Mediscribe is NOT a medical diagnostic tool.** It assists in digitizing prescriptions and managing healthcare services but does NOT replace professional medical advice. Always consult with qualified healthcare professionals for medical decisions.

---

## 📞 Support & Contact

- **Issues:** [GitHub Issues](https://github.com/your-username/MediscribeApp/issues)
- **Discussions:** [GitHub Discussions](https://github.com/your-username/MediscribeApp/discussions)
- **Email:** your-email@example.com

---

## 🙏 Acknowledgments

- Google ML Kit for on-device OCR
- Google Gemini API for AI text processing
- OpenStreetMap community for map data
- Stripe for payment processing
- Flutter team for the amazing framework
- All contributors and early adopters

---

## 📊 Project Stats

- **Lines of Code:** ~15,000+ (Flutter + Backend)
- **Features:** 15+ major features
- **API Endpoints:** 25+
- **Database Models:** 8
- **External Integrations:** 5 (Google, Stripe, OpenStreetMap, etc.)

---

**Made with ❤️ for better healthcare accessibility**

*If you found this project helpful, please consider giving it a ⭐ on GitHub!*
