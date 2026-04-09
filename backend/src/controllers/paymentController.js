const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const Order = require("../models/Order");
const LabBooking = require("../models/LabBooking");

/**
 * POST /api/payment/create-order
 * Create a Stripe PaymentIntent for payment
 */
async function createPaymentOrder(req, res) {
  try {
    const { amount, currency = 'usd', orderType, orderId } = req.body;

    if (!amount || !orderType || !orderId) {
      return res.status(400).json({ 
        success: false, 
        message: "amount, orderType, and orderId are required" 
      });
    }

    // Create Stripe PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency,
      metadata: {
        orderType,
        orderId: orderId.toString(),
      },
    });

    return res.json({
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error("Error creating Stripe PaymentIntent:", error);
    return res.status(500).json({ 
      success: false, 
      message: "Failed to create payment order" 
    });
  }
}

/**
 * POST /api/payment/verify
 * Verify Stripe payment after completion
 */
async function verifyPayment(req, res) {
  try {
    const {
      paymentIntentId,
      orderId,
      orderType,
    } = req.body;

    if (!paymentIntentId || !orderId || !orderType) {
      return res.status(400).json({ 
        success: false, 
        message: "Missing payment details" 
      });
    }

    // Retrieve payment intent from Stripe
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      // Update order based on type
      if (orderType === "pharmacy") {
        const order = await Order.findById(orderId);
        if (!order) {
          return res.status(404).json({ message: "Order not found" });
        }

        order.paymentStatus = "paid";
        order.paymentMethod = "stripe";
        order.stripePaymentIntentId = paymentIntentId;
        order.status = "confirmed";
        order.trackingHistory.push({
          status: "Payment Confirmed",
          note: `Payment verified via Stripe. Payment Intent: ${paymentIntentId}`,
        });
        await order.save();
      } else if (orderType === "lab_test") {
        const booking = await LabBooking.findById(orderId);
        if (!booking) {
          return res.status(404).json({ message: "Booking not found" });
        }

        booking.paymentStatus = "paid";
        booking.paymentMethod = "stripe";
        booking.stripePaymentIntentId = paymentIntentId;
        booking.status = "confirmed";
        await booking.save();
      }

      return res.json({
        success: true,
        message: "Payment verified successfully",
        paymentId: paymentIntentId,
      });
    } else {
      return res.status(400).json({ 
        success: false, 
        message: "Payment not completed" 
      });
    }
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
 * Handle Stripe webhook events
 */
async function paymentWebhook(req, res) {
  const sig = req.headers['stripe-signature'];
  
  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );

    // Handle the event
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        const orderId = paymentIntent.metadata.orderId;
        const orderType = paymentIntent.metadata.orderType;

        console.log(`PaymentIntent succeeded for ${orderType} order: ${orderId}`);
        
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
        break;
      
      case 'payment_intent.payment_failed':
        const failedIntent = event.data.object;
        console.log(`PaymentIntent failed: ${failedIntent.id}`);
        break;
      
      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    return res.status(200).json({ received: true });
  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(400).json({ message: "Webhook verification failed" });
  }
}

module.exports = { createPaymentOrder, verifyPayment, paymentWebhook };
