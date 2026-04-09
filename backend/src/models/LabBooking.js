const mongoose = require("mongoose");

const addressSchema = new mongoose.Schema(
  {
    label: { type: String, default: "" },
    fullAddress: { type: String, default: "" },
    lat: { type: Number },
    lng: { type: Number },
    phone: { type: String, default: "" }
  },
  { _id: false }
);

const labBookingSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    labTestId: { type: mongoose.Schema.Types.ObjectId, ref: "LabTest", required: true },
    address: { type: addressSchema, required: true },
    preferredDate: { type: Date, required: true },
    timeSlot: { type: String, required: true },
    status: {
      type: String,
      enum: ["pending", "confirmed", "sample_collected", "processing", "report_ready", "delivered", "cancelled"],
      default: "pending",
    },
    paymentMethod: {
      type: String,
      enum: ["razorpay", "cod"],
      default: "razorpay"
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "failed"],
      default: "pending"
    },
    razorpayOrderId: { type: String },
    razorpayPaymentId: { type: String },
    amount: { type: Number, required: true },
    reportUrl: { type: String },
    notes: { type: String, default: "" },
  },
  { timestamps: true }
);

// Index for efficient queries
labBookingSchema.index({ userId: 1, createdAt: -1 });
labBookingSchema.index({ preferredDate: 1 });

module.exports = mongoose.model("LabBooking", labBookingSchema);
