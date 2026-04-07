const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
  {
    name:     { type: String, required: true },
    dose:     { type: String, default: "" },
    duration: { type: String, default: "" },
  },
  { _id: false }
);

const prescriptionSchema = new mongoose.Schema(
  {
    appointmentId: { type: mongoose.Schema.Types.ObjectId, ref: "Appointment", required: true },
    patientId:     { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    doctorId:      { type: mongoose.Schema.Types.ObjectId, ref: "DoctorAccount", required: true },
    doctorName:    { type: String, default: "" },
    medicines:     { type: [medicineSchema], default: [] },
    notes:         { type: String, default: "" },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Prescription", prescriptionSchema);
