const LabTest = require("../models/LabTest");
const LabBooking = require("../models/LabBooking");

async function listLabs(req, res) {
  try {
    const { category, q, tag, page = 1, limit = 20 } = req.query;

    const query = {};
    
    if (category && category !== "All Tests") {
      query.category = category;
    }
    
    if (tag) {
      query.tags = tag;
    }
    
    if (q && q.trim()) {
      query.$or = [
        { name: { $regex: q, $options: "i" } },
        { category: { $regex: q, $options: "i" } },
        { description: { $regex: q, $options: "i" } }
      ];
    }

    const skip = (Number(page) - 1) * Number(limit);
    
    const [labs, total] = await Promise.all([
      LabTest.find(query)
        .skip(skip)
        .limit(Number(limit))
        .sort({ createdAt: -1 }),
      LabTest.countDocuments(query)
    ]);

    return res.json({
      labs: labs.map(labPublic),
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error("Error fetching lab tests:", error);
    return res.status(500).json({ message: "Failed to fetch lab tests" });
  }
}

async function bookLabTest(req, res) {
  try {
    const { labTestId, address, preferredDate, timeSlot, paymentMethod = "razorpay" } = req.body;

    if (!labTestId || !address || !preferredDate || !timeSlot) {
      return res.status(400).json({ 
        message: "labTestId, address, preferredDate, and timeSlot are required" 
      });
    }

    // Get lab test details to fetch price
    const labTest = await LabTest.findById(labTestId);
    if (!labTest) {
      return res.status(404).json({ message: "Lab test not found" });
    }

    // Create booking
    const booking = await LabBooking.create({
      userId: req.userId,
      labTestId,
      address,
      preferredDate: new Date(preferredDate),
      timeSlot,
      amount: labTest.price,
      paymentMethod,
    });

    return res.status(201).json({
      success: true,
      booking: bookingPublic(booking),
    });
  } catch (error) {
    console.error("Error booking lab test:", error);
    return res.status(500).json({ message: "Failed to book lab test" });
  }
}

async function getMyBookings(req, res) {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    
    const query = { userId: req.userId };
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);
    
    const [bookings, total] = await Promise.all([
      LabBooking.find(query)
        .populate("labTestId", "name category price imageUrl")
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      LabBooking.countDocuments(query)
    ]);

    return res.json({
      bookings: bookings.map(bookingPublic),
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error("Error fetching bookings:", error);
    return res.status(500).json({ message: "Failed to fetch bookings" });
  }
}

function labPublic(l) {
  return {
    id: l._id.toString(),
    name: l.name,
    category: l.category,
    price: l.price,
    description: l.description,
    imageUrl: l.imageUrl,
    tags: l.tags,
    parametersCount: l.parametersCount,
    isHomeCollectionAvailable: l.isHomeCollectionAvailable,
    createdAt: l.createdAt,
  };
}

function bookingPublic(b) {
  return {
    id: b._id.toString(),
    labTestId: b.labTestId,
    address: b.address,
    preferredDate: b.preferredDate,
    timeSlot: b.timeSlot,
    status: b.status,
    paymentMethod: b.paymentMethod,
    paymentStatus: b.paymentStatus,
    amount: b.amount,
    reportUrl: b.reportUrl,
    createdAt: b.createdAt,
  };
}

module.exports = { listLabs, bookLabTest, getMyBookings };
