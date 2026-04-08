const Appointment = require("../models/Appointment");
const DoctorAccount = require("../models/DoctorAccount");

// POST /api/appointments  (patient)
async function bookAppointment(req, res) {
  const { doctorId, dateLabel, timeLabel, type, location } = req.body;
  if (!doctorId || !dateLabel || !timeLabel) {
    return res.status(400).json({ message: "doctorId, dateLabel, timeLabel are required" });
  }

  const doctor = await DoctorAccount.findById(doctorId);
  if (!doctor) return res.status(404).json({ message: "Doctor not found" });

  const appt = await Appointment.create({
    patientId: req.userId,
    doctorId,
    doctorName: doctor.name,
    specialty: doctor.specialty,
    dateLabel,
    timeLabel,
    type: type || "General checkup",
    location: location || "Clinic",
  });

  return res.status(201).json({ appointment: apptPublic(appt) });
}

// GET /api/appointments/mine  (patient)
async function getMyAppointments(req, res) {
  const appts = await Appointment.find({ patientId: req.userId }).sort({ createdAt: -1 });
  return res.json({ appointments: appts.map(apptPublic) });
}

// GET /api/appointments/doctor  (doctor)
async function getDoctorAppointments(req, res) {
  const appts = await Appointment.find({ doctorId: req.userId })
    .populate("patientId", "name email phone avatarUrl")
    .sort({ createdAt: -1 });
  return res.json({ appointments: appts.map((a) => apptPublicDoctor(a)) });
}

// PATCH /api/appointments/:id/status
async function updateStatus(req, res) {
  const { status } = req.body;
  if (!["upcoming", "completed", "cancelled"].includes(status)) {
    return res.status(400).json({ message: "Invalid status" });
  }
  const appt = await Appointment.findById(req.params.id);
  if (!appt) return res.status(404).json({ message: "Appointment not found" });

  // Patient can only cancel their own; doctor can update any of theirs
  const isPatient = appt.patientId.toString() === req.userId;
  const isDoctor  = appt.doctorId.toString() === req.userId;
  if (!isPatient && !isDoctor) return res.status(403).json({ message: "Forbidden" });

  appt.status = status;
  await appt.save();
  return res.json({ appointment: apptPublic(appt) });
}

// POST /api/appointments/:id/rate (patient only)
async function rateAppointment(req, res) {
  const { rating, review } = req.body;
  
  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ message: "Rating must be between 1 and 5" });
  }

  const appt = await Appointment.findById(req.params.id);
  if (!appt) return res.status(404).json({ message: "Appointment not found" });

  // Only patient who had the appointment can rate
  if (appt.patientId.toString() !== req.userId) {
    return res.status(403).json({ message: "Only the patient can rate this appointment" });
  }

  // Update appointment with rating
  appt.rating = rating;
  appt.review = review || "";
  await appt.save();

  // Update doctor's average rating
  const doctor = await DoctorAccount.findById(appt.doctorId);
  if (doctor) {
    const totalReviews = doctor.reviews + 1;
    const newAverage = ((doctor.rating * doctor.reviews) + rating) / totalReviews;
    
    doctor.rating = Math.round(newAverage * 10) / 10; // Round to 1 decimal
    doctor.reviews = totalReviews;
    await doctor.save();
  }

  return res.json({ 
    message: "Rating submitted successfully",
    appointment: apptPublic(appt)
  });
}

function apptPublic(a) {
  return {
    id: a._id.toString(),
    doctorId: a.doctorId.toString(),
    doctorName: a.doctorName,
    specialty: a.specialty,
    dateLabel: a.dateLabel,
    timeLabel: a.timeLabel,
    type: a.type,
    location: a.location,
    status: a.status,
    prescriptionText: a.prescriptionText,
    rating: a.rating,
    review: a.review,
    createdAt: a.createdAt,
  };
}

function apptPublicDoctor(a) {
  const base = apptPublic(a);
  base.patient = a.patientId
    ? { id: a.patientId._id, name: a.patientId.name, email: a.patientId.email }
    : null;
  base.patientName = a.patientId?.name || 'Unknown';
  base.patientPhone = a.patientId?.phone || '';
  return base;
}

module.exports = { bookAppointment, getMyAppointments, getDoctorAppointments, updateStatus, rateAppointment };
