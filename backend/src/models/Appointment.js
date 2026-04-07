const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema(
  {
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    doctorId:  { type: mongoose.Schema.Types.ObjectId, ref: "DoctorAccount", required: true },
    doctorName:  { type: String, required: true },
    specialty:   { type: String, required: true },
    dateLabel:   { type: String, required: true },
    timeLabel:   { type: String, required: true },
    type:        { type: String, default: "General checkup" },
    location:    { type: String, default: "Clinic" },
    status: {
      type: String,
      enum: ["upcoming", "completed", "cancelled"],
      default: "upcoming",
    },
    prescriptionText: { type: String, default: "" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Appointment", appointmentSchema);
