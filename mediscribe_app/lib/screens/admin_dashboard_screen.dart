import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  final String? token;
  final Map<String, dynamic>? adminUser;
  
  const AdminDashboardScreen({
    super.key,
    this.token,
    this.adminUser,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> pendingDoctors = [];
  List<Map<String, dynamic>> verifiedDoctors = [];
  bool _loading = true;
  String? _adminToken;
  int _totalPending = 0;
  int _totalVerified = 0;

  @override
  void initState() {
    super.initState();
    // If token is provided, use it directly
    if (widget.token != null) {
      _adminToken = widget.token;
      _loadAllData();
    } else {
      _showTokenDialog();
    }
  }

  void _showTokenDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Enter Admin Token', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Paste your admin token here',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _adminToken = controller.text.trim();
                Navigator.pop(context);
                _loadAllData();
              },
              child: const Text('Continue', style: TextStyle(color: Color(0xFF2E7DFF))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAllData() async {
    if (_adminToken == null) {
      print('⚠️ Admin token is null!');
      return;
    }

    print('\n${'='*50}');
    print('🔄 Loading admin data...');
    print('🔑 Token: ${_adminToken!.substring(0, 30)}...');
    setState(() => _loading = true);

    try {
      // Load pending doctors
      print('\n📡 Request: GET /api/doctors/admin/unverified');
      final pendingResponse = await http.get(
        Uri.parse('https://mediscribeapp.onrender.com/api/doctors/admin/unverified'),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );

      print('📥 Response Status: ${pendingResponse.statusCode}');
      print('📥 Response Body (first 200 chars): ${pendingResponse.body.substring(0, pendingResponse.body.length > 200 ? 200 : pendingResponse.body.length)}');

      if (pendingResponse.statusCode == 200) {
        final data = jsonDecode(pendingResponse.body);
        final doctorsList = data['doctors'] ?? [];
        print('✅ Parsed ${doctorsList.length} pending doctors');
        print('✅ Total from API: ${data['total']}');
        
        if (doctorsList.isNotEmpty) {
          print('\n📋 First doctor data:');
          print('   ID: ${doctorsList[0]['id']}');
          print('   Name: ${doctorsList[0]['name']}');
          print('   Email: ${doctorsList[0]['email']}');
          print('   Specialty: ${doctorsList[0]['specialty']}');
        }
        
        setState(() {
          pendingDoctors = List<Map<String, dynamic>>.from(doctorsList);
          _totalPending = data['total'] ?? 0;
        });
      } else {
        print('❌ Failed to load pending doctors!');
        print('❌ Status: ${pendingResponse.statusCode}');
        print('❌ Error: ${pendingResponse.body}');
        
        // Show error to user
        if (pendingResponse.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Admin access denied. Check your role.')),
          );
        } else if (pendingResponse.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Invalid token. Please login again.')),
          );
        }
      }

      // Load verified doctors count
      print('\n📡 Request: GET /api/doctors?page=1');
      final verifiedResponse = await http.get(
        Uri.parse('https://mediscribeapp.onrender.com/api/doctors?page=1'),
        headers: {'Authorization': 'Bearer $_adminToken'},
      );

      print('📥 Response Status: ${verifiedResponse.statusCode}');

      if (verifiedResponse.statusCode == 200) {
        final data = jsonDecode(verifiedResponse.body);
        print('✅ Verified doctors count: ${data['total'] ?? 0}');
        setState(() {
          _totalVerified = data['total'] ?? 0;
        });
      } else {
        print('❌ Failed to load verified doctors');
      }

      setState(() => _loading = false);
      print('\n${'='*50}');
      print('📊 Final counts - Pending: $_totalPending, Verified: $_totalVerified');
      print('${'='*50}\n');
    } catch (e, stackTrace) {
      print('\n❌ Exception loading data: $e');
      print('❌ Stack trace: $stackTrace');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _verifyDoctor(String doctorId, String doctorName) async {
    try {
      final response = await http.put(
        Uri.parse('https://mediscribeapp.onrender.com/api/doctors/$doctorId/verify'),
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'isVerified': true}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ $doctorName verified!')),
        );
        _loadAllData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _verifyAllDoctors() async {
    if (pendingDoctors.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Verify All Doctors?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to verify all ${pendingDoctors.length} pending doctors?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _loading = true);
        
        final response = await http.put(
          Uri.parse('https://mediscribeapp.onrender.com/api/doctors/admin/bulk-verify'),
          headers: {
            'Authorization': 'Bearer $_adminToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'verifyAll': true}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${data['message']}')),
          );
          _loadAllData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyAllFromMongoDB() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Bulk Verify from Database', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will verify ALL unverified doctors in the database. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // In production, call a dedicated bulk verify endpoint
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use MongoDB command or backend script for bulk verification')),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (widget.adminUser != null)
              Text(
                'Welcome, ${widget.adminUser!['name']}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7DFF)))
          : Column(
              children: [
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          '$_totalPending',
                          Colors.orange,
                          Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Verified',
                          '$_totalVerified',
                          Colors.green,
                          Icons.verified,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bulk Actions
                if (pendingDoctors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _verifyAllDoctors,
                            icon: const Icon(Icons.done_all),
                            label: const Text('Verify All Listed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _verifyAllFromMongoDB,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Bulk Verify DB'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Pending Doctors List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pending Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pendingDoctors.length} doctors',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: pendingDoctors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 80,
                                color: Colors.green.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'All doctors verified!',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: pendingDoctors.length,
                          itemBuilder: (context, index) {
                            return _buildDoctorCard(pendingDoctors[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.work_outline, '${doctor['experience'] ?? 0} yrs'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.star, '${doctor['rating'] ?? 0}'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.attach_money, '₹${doctor['fee'] ?? 0}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '📧 ${doctor['email'] ?? 'N/A'}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          if ((doctor['licenseNumber'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '🎫 License: ${doctor['licenseNumber']}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _verifyDoctor(doctor['id'], doctor['name']),
                  icon: const Icon(Icons.verified, size: 18),
                  label: const Text('Verify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
