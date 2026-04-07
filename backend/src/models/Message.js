const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema(
  {
    appointmentId: { type: mongoose.Schema.Types.ObjectId, ref: "Appointment", required: true },
    senderId:   { type: String, required: true },
    senderRole: { type: String, enum: ["patient", "doctor"], required: true },
    senderName: { type: String, default: "" },
    text:       { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Message", messageSchema);
