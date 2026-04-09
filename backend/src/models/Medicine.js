const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    category: { 
      type: String, 
      required: true, 
      enum: ["Medicines", "Supplements", "Devices", "Personal Care"] 
    },
    price: { type: Number, required: true },
    mrp: { type: Number, required: true },
    imageUrl: { type: String, required: true },
    stock: { type: Number, default: 0 },
    requiresPrescription: { type: Boolean, default: false },
    tags: { type: [String], default: [] },
  },
  { timestamps: true }
);

medicineSchema.index({ name: "text", tags: "text" });

module.exports = mongoose.model("Medicine", medicineSchema);
