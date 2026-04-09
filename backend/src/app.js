const express = require("express");
const cors = require("cors");
const authRoutes         = require("./routes/authRoutes");
const doctorRoutes       = require("./routes/doctorRoutes");
const productRoutes      = require("./routes/productRoutes");
const labRoutes          = require("./routes/labRoutes");
const appointmentRoutes  = require("./routes/appointmentRoutes");
const locationRoutes     = require("./routes/locationRoutes");
const chatRoutes         = require("./routes/chatRoutes");
const prescriptionRoutes = require("./routes/prescriptionRoutes");
const orderRoutes        = require("./routes/orderRoutes");
const searchRoutes       = require("./routes/searchRoutes");
const paymentRoutes      = require("./routes/paymentRoutes");

const app = express();

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"]
}));
app.use(express.json());

app.get("/", (_req, res) => {
  res.json({
    ok: true,
    message: "Mediscribe backend is running",
    endpoints: [
      "/health",
      "/api/auth/signup",
      "/api/auth/login",
      "/api/auth/doctor/signup",
      "/api/auth/doctor/login",
      "/api/auth/me",
      "/api/doctors",
      "/api/doctors/nearby",
      "/api/doctors/specialties",
      "/api/doctors/:id",
      "/api/appointments",
      "/api/appointments/mine",
      "/api/appointments/doctor",
      "/api/location/search",
      "/api/location/nearby-clinics",
      "/api/chat/:appointmentId",
      "/api/prescriptions",
      "/api/prescriptions/mine",
      "/api/orders",
      "/api/orders/mine",
      "/api/orders/:id/tracking",
      "/api/orders/:id/cancel",
      "/api/products",
      "/api/labs",
      "/api/labs/book",
      "/api/labs/my-bookings",
      "/api/search",
      "/api/payment/create-order",
      "/api/payment/verify",
    ],
  });
});

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "mediscribe-backend" });
});

app.use("/api/auth",          authRoutes);
app.use("/api/doctors",       doctorRoutes);
app.use("/api/appointments",  appointmentRoutes);
app.use("/api/location",      locationRoutes);
app.use("/api/chat",          chatRoutes);
app.use("/api/prescriptions", prescriptionRoutes);
app.use("/api/orders",        orderRoutes);
app.use("/api/products",      productRoutes);
app.use("/api/labs",          labRoutes);
app.use("/api/search",        searchRoutes);
app.use("/api/payment",       paymentRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ message: "Internal server error" });
});

module.exports = app;
