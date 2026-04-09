const Order = require("../models/Order");

// POST /api/orders  (patient)
async function placeOrder(req, res) {
  const { items, total, address, orderType = "pharmacy", paymentMethod = "razorpay" } = req.body;
  
  if (!items || !Array.isArray(items) || items.length === 0 || !total) {
    return res.status(400).json({ message: "items and total are required" });
  }

  try {
    const order = await Order.create({
      patientId: req.userId,
      orderType,
      items,
      total,
      paymentMethod,
      address: address || {},
    });

    return res.status(201).json({ 
      success: true,
      order: orderPublic(order) 
    });
  } catch (error) {
    console.error("Error placing order:", error);
    return res.status(500).json({ message: "Failed to place order" });
  }
}

// GET /api/orders/mine  (patient)
async function getMyOrders(req, res) {
  try {
    const { orderType, status, page = 1, limit = 20 } = req.query;
    
    const query = { patientId: req.userId };
    if (orderType) query.orderType = orderType;
    if (status) query.status = status;

    const skip = (Number(page) - 1) * Number(limit);
    
    const [orders, total] = await Promise.all([
      Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(Number(limit)),
      Order.countDocuments(query)
    ]);

    return res.json({ 
      orders: orders.map(orderPublic),
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit))
      }
    });
  } catch (error) {
    console.error("Error fetching orders:", error);
    return res.status(500).json({ message: "Failed to fetch orders" });
  }
}

// GET /api/orders/:id/tracking
async function getOrderTracking(req, res) {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      patientId: req.userId,
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    return res.json({
      success: true,
      orderId: order._id,
      status: order.status,
      trackingHistory: order.trackingHistory,
    });
  } catch (error) {
    console.error("Error fetching tracking:", error);
    return res.status(500).json({ message: "Failed to fetch tracking info" });
  }
}

// POST /api/orders/:id/cancel
async function cancelOrder(req, res) {
  try {
    const order = await Order.findOne({
      _id: req.params.id,
      patientId: req.userId,
    });

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (!["pending", "confirmed"].includes(order.status)) {
      return res.status(400).json({ 
        message: "Order cannot be cancelled at this stage" 
      });
    }

    order.status = "cancelled";
    order.trackingHistory.push({
      status: "Cancelled",
      note: "Order cancelled by user",
    });
    await order.save();

    return res.json({
      success: true,
      message: "Order cancelled successfully",
      order: orderPublic(order),
    });
  } catch (error) {
    console.error("Error cancelling order:", error);
    return res.status(500).json({ message: "Failed to cancel order" });
  }
}

function orderPublic(o) {
  return {
    id: o._id.toString(),
    orderType: o.orderType,
    items: o.items,
    total: o.total,
    status: o.status,
    paymentMethod: o.paymentMethod,
    paymentStatus: o.paymentStatus,
    address: o.address,
    trackingHistory: o.trackingHistory,
    createdAt: o.createdAt,
    updatedAt: o.updatedAt,
  };
}

module.exports = { placeOrder, getMyOrders, getOrderTracking, cancelOrder };
