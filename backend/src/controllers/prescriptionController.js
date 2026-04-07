const Prescription = require("../models/Prescription");
const Appointment = require("../models/Appointment");
const DoctorAccount = require("../models/DoctorAccount");

// POST /api/prescriptions  (doctor only)
async function createPrescription(req, res) {
  const { appointmentId, patientId, medicines, notes } = req.body;
  if (!appointmentId || !patientId)
    return res.status(400).json({ message: "appointmentId and patientId are required" });

  const appt = await Appointment.findById(appointmentId);
  if (!appt) return res.status(404).json({ message: "Appointment not found" });
  if (appt.doctorId.toString() !== req.userId)
    return res.status(403).json({ message: "Forbidden" });

  const doc = await DoctorAccount.findById(req.userId).select("name");

  const presc = await Prescription.create({
    appointmentId,
    patientId,
    doctorId: req.userId,
    doctorName: doc ? doc.name : "",
    medicines: medicines || [],
    notes: notes || "",
  });

  // Optionally stamp prescriptionText on appointment
  if (medicines && medicines.length) {
    const summary = medicines.map((m) => `${m.name} ${m.dose} for ${m.duration}`).join("; ");
    appt.prescriptionText = summary;
    await appt.save();
  }

  return res.status(201).json({ prescription: prescPublic(presc) });
}

// GET /api/prescriptions/mine  (patient)
async function getMyPrescriptions(req, res) {
  const list = await Prescription.find({ patientId: req.userId })
    .sort({ createdAt: -1 });
  return res.json({ prescriptions: list.map(prescPublic) });
}

// GET /api/prescriptions/:id
async function getPrescription(req, res) {
  const presc = await Prescription.findById(req.params.id);
  if (!presc) return res.status(404).json({ message: "Prescription not found" });

  const isOwner =
    presc.patientId.toString() === req.userId ||
    presc.doctorId.toString() === req.userId;
  if (!isOwner) return res.status(403).json({ message: "Forbidden" });

  return res.json({ prescription: prescPublic(presc) });
}

function prescPublic(p) {
  return {
    id: p._id.toString(),
    appointmentId: p.appointmentId.toString(),
    patientId: p.patientId.toString(),
    doctorId: p.doctorId.toString(),
    doctorName: p.doctorName,
    medicines: p.medicines,
    notes: p.notes,
    createdAt: p.createdAt,
  };
}

module.exports = { createPrescription, getMyPrescriptions, getPrescription };
