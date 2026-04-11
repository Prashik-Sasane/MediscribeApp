import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:mediscribe_app/features/doctors/bookappointment.dart';
import 'package:mediscribe_app/services/appointment_service.dart';
import 'package:mediscribe_app/services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
// import 'package:mediscribe_app/screens/cart_screen.dart'; // For MyOrdersScreen

class PaymentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final int fee;
  final String dateLabel;
  final String timeLabel;
  final String type;
  final String location;

  const PaymentScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.fee,
    required this.dateLabel,
    required this.timeLabel,
    this.type = 'General checkup',
    this.location = 'Clinic',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;

  Future<void> _processPayment() async {
    setState(() => _processing = true);

    final state = AppScope.of(context);
    final token = state.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to proceed')),
      );
      setState(() => _processing = false);
      return;
    }

    ApiAppointment? createdAppointment;

    try {
      // Step 1: Create appointment booking first
      createdAppointment = await AppointmentService.book(
        token: token,
        doctorId: widget.doctorId,
        dateLabel: widget.dateLabel,
        timeLabel: widget.timeLabel,
        type: widget.type,
        location: widget.location,
      );

      if (createdAppointment == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create appointment')),
          );
        }
        setState(() => _processing = false);
        return;
      }

      print('Payment: Appointment created with ID: ${createdAppointment.id}');

      // Step 2: Process Stripe Payment
      final result = await PaymentService.processStripePayment(
        token: token,
        amount: widget.fee.toDouble(),
        orderType: 'appointment',
        orderId: createdAppointment.id,
        publishableKey: 'pk_test_51TKLGCA0vwEId8d1ChT5p251LabT0MZ61Hlq4Jq233SOHNEa6yM80fDFRYOqfXDaHtFn8BredvwBtH974pt3olZu00Sn9lvWwp',
      );

      print('Payment: Result = $result');

      // Step 3: Handle payment result
      if (result['success'] == true) {
        // Payment succeeded - reload appointments
        await state.loadAppointments();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Appointment booked.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to BookingScreen to show updated appointments
          Navigator.pop(context, true);
        }
      } else {
        // Payment failed - check if it was cancelled
        final message = result['message'] ?? 'Payment failed';
        final isCancelled = message.toLowerCase().contains('cancelled') || 
                           message.toLowerCase().contains('canceled');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCancelled ? 'Payment cancelled' : message),
              backgroundColor: isCancelled ? Colors.orange : Colors.red,
            ),
          );
          
          // Navigate back to BookingScreen (appointment will not show as it has no payment)
          Navigator.pop(context, false);
        }
      }
    } catch (e) {
      print('Payment: Error = $e');
      
      // Check if error is about cancellation
      final errorStr = e.toString().toLowerCase();
      final isCancelled = errorStr.contains('cancelled') || errorStr.contains('canceled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCancelled ? 'Payment cancelled' : 'Error: $e'),
            backgroundColor: isCancelled ? Colors.orange : Colors.red,
          ),
        );
        
        // Navigate back to BookingScreen
        Navigator.pop(context, false);
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _processing ? null : () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Summary
                  _buildSummaryCard(),
                  const SizedBox(height: 24),

                  // Payment Method Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2E7DFF).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.credit_card, color: Color(0xFF2E7DFF), size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Stripe Payment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Secure payment with your credit or debit card',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildCardBrand('Visa'),
                            const SizedBox(width: 8),
                            _buildCardBrand('Mastercard'),
                            const SizedBox(width: 8),
                            _buildCardBrand('Amex'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7DFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _processing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing Payment...',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Pay ₹${widget.fee}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBrand(String brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        brand,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7DFF), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7DFF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Doctor', 'Dr. ${widget.doctorName}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Specialty', widget.specialty),
          const SizedBox(height: 8),
          _buildSummaryRow('Date', widget.dateLabel),
          const SizedBox(height: 8),
          _buildSummaryRow('Time', widget.timeLabel),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow('Consultation Fee', '₹${widget.fee}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
