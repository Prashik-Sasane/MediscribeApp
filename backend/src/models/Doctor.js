const mongoose = require("mongoose");

const doctorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    specialty: { type: String, required: true },
    imageUrl: { type: String },
    rating: { type: Number, default: 0 },
    fee: { type: Number, required: true },
    reviews: { type: Number, default: 0 },
    experience: { type: Number, default: 0 }, // in years
    isOnline: { type: Boolean, default: false },
    lng: { type: Number, required: true },
    lat: { type: Number, required: true },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: true
      }
    }
  },
  { timestamps: true }
);

doctorSchema.index({ location: "2dsphere" });

module.exports = mongoose.model("Doctor", doctorSchema);
