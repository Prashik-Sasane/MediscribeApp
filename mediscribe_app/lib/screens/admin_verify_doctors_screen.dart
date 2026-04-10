import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminVerifyDoctorsScreen extends StatefulWidget {
  const AdminVerifyDoctorsScreen({super.key});

  @override
  State<AdminVerifyDoctorsScreen> createState() => _AdminVerifyDoctorsScreenState();
}

class _AdminVerifyDoctorsScreenState extends State<AdminVerifyDoctorsScreen> {
  List<Map<String, dynamic>> unverifiedDoctors = [];
  bool _loading = true;
  String? _token; // Admin token
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUnverifiedDoctors() async {
    if (_token == null || _token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter admin token first')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse('https://mediscribeapp.onrender.com/api/doctors/admin/unverified'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          unverifiedDoctors = List<Map<String, dynamic>>.from(data['doctors'] ?? []);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}. Check admin token.')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _verifyDoctor(String doctorId, String doctorName) async {
    if (_token == null || _token!.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse('https://mediscribeapp.onrender.com/api/doctors/$doctorId/verify'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isVerified': true,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $doctorName verified successfully!')),
        );
        _loadUnverifiedDoctors(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          'Admin - Verify Doctors',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Token Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _tokenController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter Admin Token',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: Color(0xFF2E7DFF)),
                      onPressed: () {
                        _token = _tokenController.text.trim();
                        _loadUnverifiedDoctors();
                      },
                    ),
                  ),
                  onChanged: (value) => _token = value.trim(),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tip: Login as admin and copy token from debug/console',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),

          // Load Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _loadUnverifiedDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('Load Unverified Doctors'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7DFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Doctors List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
                : unverifiedDoctors.isEmpty
                    ? const Center(
                        child: Text(
                          'No doctors found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: unverifiedDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = unverifiedDoctors[index];
                          return _buildDoctorCard(doctor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final isVerified = doctor['isVerified'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7DFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialty'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isVerified ? 'VERIFIED' : 'PENDING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.work_outline, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '${doctor['experience'] ?? 0} years exp',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${doctor['rating'] ?? 0}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.attach_money, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                '₹${doctor['fee'] ?? 0}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Email: ${doctor['email'] ?? 'N/A'}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (!isVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _verifyDoctor(doctor['id'], doctor['name']),
                icon: const Icon(Icons.verified, size: 20),
                label: const Text('VERIFY DOCTOR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
