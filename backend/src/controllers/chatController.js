const Message = require("../models/Message");
const Appointment = require("../models/Appointment");
const User = require("../models/User");
const DoctorAccount = require("../models/DoctorAccount");

async function _getApptAndVerify(apptId, userId, role) {
  const appt = await Appointment.findById(apptId);
  if (!appt) return null;
  const isPatient = appt.patientId.toString() === userId;
  const isDoctor  = appt.doctorId.toString() === userId;
  if (!isPatient && !isDoctor) return null;
  return appt;
}

// GET /api/chat/:appointmentId
async function getMessages(req, res) {
  const appt = await _getApptAndVerify(req.params.appointmentId, req.userId, req.role);
  if (!appt) return res.status(403).json({ message: "Forbidden or not found" });

  const msgs = await Message.find({ appointmentId: req.params.appointmentId })
    .sort({ createdAt: 1 })
    .limit(200);

  return res.json({ messages: msgs.map(msgPublic) });
}

// POST /api/chat/:appointmentId
async function sendMessage(req, res) {
  const { text } = req.body;
  if (!text || !text.trim()) return res.status(400).json({ message: "text is required" });

  const appt = await _getApptAndVerify(req.params.appointmentId, req.userId, req.role);
  if (!appt) return res.status(403).json({ message: "Forbidden or not found" });

  // Resolve sender name
  let senderName = "Unknown";
  if (req.role === "doctor") {
    const doc = await DoctorAccount.findById(req.userId).select("name");
    if (doc) senderName = doc.name;
  } else {
    const user = await User.findById(req.userId).select("name");
    if (user) senderName = user.name;
  }

  const msg = await Message.create({
    appointmentId: req.params.appointmentId,
    senderId: req.userId,
    senderRole: req.role,
    senderName,
    text: text.trim(),
  });

  return res.status(201).json({ message: msgPublic(msg) });
}

function msgPublic(m) {
  return {
    id: m._id.toString(),
    senderId: m.senderId,
    senderRole: m.senderRole,
    senderName: m.senderName,
    text: m.text,
    createdAt: m.createdAt,
  };
}

module.exports = { getMessages, sendMessage };
