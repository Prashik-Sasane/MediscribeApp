const mongoose = require("mongoose");

const orderItemSchema = new mongoose.Schema(
  {
    productId: { type: String, required: true },
    name:      { type: String, default: "" },
    qty:       { type: Number, required: true },
    price:     { type: Number, required: true },
  },
  { _id: false }
);

const trackingHistorySchema = new mongoose.Schema(
  {
    status: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    note: { type: String, default: "" }
  },
  { _id: false }
);

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

const orderSchema = new mongoose.Schema(
  {
    patientId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    orderType: { 
      type: String, 
      enum: ["pharmacy", "lab_test"], 
      required: true,
      default: "pharmacy"
    },
    items:     { type: [orderItemSchema], required: true },
    total:     { type: Number, required: true },
    status: {
      type: String,
      enum: ["pending", "confirmed", "packed", "dispatched", "delivered", "cancelled"],
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
    address: { type: addressSchema, default: {} },
    trackingHistory: { type: [trackingHistorySchema], default: [] },
  },
  { timestamps: true }
);

// Automatically add initial tracking entry
orderSchema.pre('save', function(next) {
  if (this.isNew && this.trackingHistory.length === 0) {
    this.trackingHistory.push({
      status: 'Order Placed',
      note: 'Order has been successfully placed'
    });
  }
  next();
});

module.exports = mongoose.model("Order", orderSchema);
