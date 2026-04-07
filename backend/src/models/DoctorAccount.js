const mongoose = require("mongoose");

const slotSchema = new mongoose.Schema(
  {
    date: { type: String, required: true }, // e.g. "Mon 12"
    times: { type: [String], default: [] }, // e.g. ["09:00", "10:30"]
  },
  { _id: false }
);

const doctorAccountSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    specialty: { type: String, required: true },
    imageUrl: { type: String, default: "" },
    fee: { type: Number, default: 500 },
    experience: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
    reviews: { type: Number, default: 0 },
    bio: { type: String, default: "" },
    phone: { type: String, default: "" },
    isOnline: { type: Boolean, default: false },
    lat: { type: Number, default: 0 },
    lng: { type: Number, default: 0 },
    location: {
      type: { type: String, enum: ["Point"], default: "Point" },
      coordinates: { type: [Number], default: [0, 0] }, // [lng, lat]
    },
    availableSlots: { type: [slotSchema], default: [] },
    role: { type: String, default: "doctor" },
  },
  { timestamps: true }
);

doctorAccountSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("DoctorAccount", doctorAccountSchema);
