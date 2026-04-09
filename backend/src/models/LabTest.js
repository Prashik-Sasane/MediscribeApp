const mongoose = require("mongoose");

const labTestSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    category: { 
      type: String, 
      required: true, 
      enum: ["Blood", "Diabetes", "Heart", "Full Body", "Kidney", "Thyroid"] 
    },
    price: { type: Number, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String, required: true },
    tags: { type: [String], default: [] },
    parametersCount: { type: Number, default: 1 },
    isHomeCollectionAvailable: { type: Boolean, default: true },
  },
  { timestamps: true }
);

labTestSchema.index({ name: "text", tags: "text" });

module.exports = mongoose.model("LabTest", labTestSchema);
