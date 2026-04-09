import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../services/auth_api_service.dart';

class AddressPickerSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelected;

  const AddressPickerSheet({super.key, required this.onSelected});

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  List<dynamic> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final token = AppScope.of(context).token;
    if (token == null) return;
    
    // Assuming AuthApiService has getAddresses
    final addresses = await AuthApiService.getAddresses(token);
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  // Navigate to Add Address Screen
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add New"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_addresses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text("No saved addresses", style: TextStyle(color: Colors.white38))),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final addr = _addresses[index];
                  return ListTile(
                    onTap: () => widget.onSelected(Map<String, dynamic>.from(addr)),
                    leading: const Icon(Icons.location_on_outlined, color: Color(0xFF2E7DFF)),
                    title: Text(addr['label'] ?? 'Address', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(addr['fullAddress'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: addr['isDefault'] == true 
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : null,
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
