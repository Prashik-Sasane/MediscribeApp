const Razorpay = require("razorpay");
const crypto = require("crypto");
const Order = require("../models/Order");
const LabBooking = require("../models/LabBooking");

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

/**
 * POST /api/payment/create-order
 * Create a Razorpay order for payment
 */
async function createPaymentOrder(req, res) {
  try {
    const { amount, currency = "INR", receipt, orderType, orderId } = req.body;

    if (!amount || !receipt) {
      return res.status(400).json({ message: "amount and receipt are required" });
    }

    // Create Razorpay order
    const options = {
      amount: Math.round(amount * 100), // Convert to paise
      currency,
      receipt,
      payment_capture: 1, // Auto-capture
      notes: {
        orderType,
        orderId,
      },
    };

    const razorpayOrder = await razorpay.orders.create(options);

    return res.json({
      success: true,
      razorpayOrderId: razorpayOrder.id,
      amount: razorpayOrder.amount,
      currency: razorpayOrder.currency,
    });
  } catch (error) {
    console.error("Error creating Razorpay order:", error);
    return res.status(500).json({ 
      success: false, 
      message: "Failed to create payment order" 
    });
  }
}

/**
 * POST /api/payment/verify
 * Verify Razorpay payment signature
 */
async function verifyPayment(req, res) {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      orderId,
      orderType,
    } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ 
        success: false, 
        message: "Missing payment details" 
      });
    }

    // Verify signature
    const sign = razorpay_order_id + "|" + razorpay_payment_id;
    const expectedSign = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
      .update(sign.toString())
      .digest("hex");

    if (razorpay_signature !== expectedSign) {
      return res.status(400).json({ 
        success: false, 
        message: "Invalid payment signature" 
      });
    }

    // Update order based on type
    if (orderType === "pharmacy") {
      const order = await Order.findById(orderId);
      if (!order) {
        return res.status(404).json({ message: "Order not found" });
      }

      order.paymentStatus = "paid";
      order.paymentMethod = "razorpay";
      order.razorpayOrderId = razorpay_order_id;
      order.razorpayPaymentId = razorpay_payment_id;
      order.status = "confirmed";
      order.trackingHistory.push({
        status: "Payment Confirmed",
        note: `Payment verified. Payment ID: ${razorpay_payment_id}`,
      });
      await order.save();
    } else if (orderType === "lab_test") {
      const booking = await LabBooking.findById(orderId);
      if (!booking) {
        return res.status(404).json({ message: "Booking not found" });
      }

      booking.paymentStatus = "paid";
      booking.paymentMethod = "razorpay";
      booking.razorpayOrderId = razorpay_order_id;
      booking.razorpayPaymentId = razorpay_payment_id;
      booking.status = "confirmed";
      await booking.save();
    }

    return res.json({
      success: true,
      message: "Payment verified successfully",
      paymentId: razorpay_payment_id,
    });
  } catch (error) {
    console.error("Error verifying payment:", error);
    return res.status(500).json({ 
      success: false, 
      message: "Payment verification failed" 
    });
  }
}

/**
 * POST /api/payment/webhook
 * Handle Razorpay webhook events
 */
async function paymentWebhook(req, res) {
  try {
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;
    const webhookSignature = req.headers["x-razorpay-signature"];

    // Verify webhook signature
    const expectedSignature = crypto
      .createHmac("sha256", webhookSecret)
      .update(JSON.stringify(req.body))
      .digest("hex");

    if (expectedSignature !== webhookSignature) {
      return res.status(400).json({ message: "Invalid webhook signature" });
    }

    const event = req.body;

    // Handle payment captured event
    if (event.event === "payment.captured") {
      const payment = event.payload.payment.entity;
      const orderId = payment.notes.orderId;
      const orderType = payment.notes.orderType;

      console.log(`Payment captured for ${orderType} order: ${orderId}`);
      
      // Update order status (webhook is backup, primary update happens in verifyPayment)
      if (orderType === "pharmacy" && orderId) {
        await Order.findByIdAndUpdate(orderId, {
          paymentStatus: "paid",
          status: "confirmed",
        });
      } else if (orderType === "lab_test" && orderId) {
        await LabBooking.findByIdAndUpdate(orderId, {
          paymentStatus: "paid",
          status: "confirmed",
        });
      }
    }

    return res.status(200).json({ received: true });
  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(500).json({ message: "Webhook processing failed" });
  }
}

module.exports = { createPaymentOrder, verifyPayment, paymentWebhook };
