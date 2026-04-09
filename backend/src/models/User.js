const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ["patient", "doctor", "admin"], default: "patient" },
    city: { type: String, default: "Pune" },
    coins: { type: Number, default: 1200 },
    phone: { type: String, default: "" },
    bloodGroup: { type: String, default: "" },
    avatarUrl: { type: String, default: "" },
    upiId: { type: String, default: "" }, // For receiving payments (doctors)
    addresses: [{
      label: String, // Home, Office, etc.
      fullAddress: String,
      lat: Number,
      lng: Number,
      isDefault: { type: Boolean, default: false }
    }],
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
