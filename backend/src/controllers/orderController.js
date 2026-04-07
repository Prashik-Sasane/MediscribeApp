const Order = require("../models/Order");

// POST /api/orders  (patient)
async function placeOrder(req, res) {
  const { items, total, address } = req.body;
  if (!items || !Array.isArray(items) || items.length === 0 || !total) {
    return res.status(400).json({ message: "items and total are required" });
  }

  const order = await Order.create({
    patientId: req.userId,
    items,
    total,
    address: address || "",
  });

  return res.status(201).json({ order: orderPublic(order) });
}

// GET /api/orders/mine  (patient)
async function getMyOrders(req, res) {
  const orders = await Order.find({ patientId: req.userId }).sort({ createdAt: -1 });
  return res.json({ orders: orders.map(orderPublic) });
}

function orderPublic(o) {
  return {
    id: o._id.toString(),
    items: o.items,
    total: o.total,
    status: o.status,
    address: o.address,
    createdAt: o.createdAt,
  };
}

module.exports = { placeOrder, getMyOrders };
