const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema(
  {
    doctorName: { type: String, required: true },
    specialty: { type: String, required: true },
    dateLabel: { type: String, required: true },
    timeLabel: { type: String, required: true },
    type: { type: String, required: true },
    location: { type: String, required: true },
  },
  { _id: false }
);

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    city: { type: String, default: "Pune" },
    coins: { type: Number, default: 1200 },
    appointments: { type: [appointmentSchema], default: [] },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
