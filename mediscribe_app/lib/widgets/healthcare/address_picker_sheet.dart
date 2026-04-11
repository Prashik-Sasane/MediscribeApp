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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _fetchAddresses();
    }
  }

  Future<void> _fetchAddresses() async {
    try {
      // Safe to call here because didChangeDependencies() ensures context is ready
      final token = AppScope.of(context).token;

    if (token == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final addresses = await AuthApiService.getAddresses(token);

    if (mounted) {
      setState(() {
        _addresses = addresses;
        _loading = false;
      });
    }
  } catch (e) {
    print("Address fetch error: $e");

    if (mounted) {
      setState(() {
        _loading = false; 
      });
    }
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
                onPressed: () => _showAddAddressDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add New"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.location_off, color: Colors.white24, size: 48),
                    const SizedBox(height: 12),
                    const Text("No saved addresses", style: TextStyle(color: Colors.white38)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAddressDialog(),
                      icon: const Icon(Icons.add_location),
                      label: const Text("Add Address"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7DFF),
                      ),
                    ),
                  ],
                ),
              ),
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
                    title: Text(addr['label'] ?? addr['street'] ?? 'Address', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      addr['fullAddress'] ?? '${addr['city'] ?? ''}, ${addr['state'] ?? ''}', 
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
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

  Future<void> _showAddAddressDialog() async {
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final labelController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Add New Address', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g., Home, Office)',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: streetController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'City',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: stateController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'State',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: zipController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          labelStyle: TextStyle(color: Colors.white54),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7DFF),
              ),
              onPressed: () async {
                if (streetController.text.isEmpty || cityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in street and city')),
                  );
                  return;
                }

                try {
                  final token = AppScope.of(context).token;
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login first')),
                    );
                    return;
                  }

                  final newAddress = {
                    'label': labelController.text.isEmpty ? 'Home' : labelController.text,
                    'street': streetController.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'zip': zipController.text,
                    'fullAddress': '${streetController.text}, ${cityController.text}, ${stateController.text} ${zipController.text}',
                    'isDefault': _addresses.isEmpty,
                  };

                  print('AddressPicker: Saving address: $newAddress');
                  final updatedAddresses = await AuthApiService.addAddress(token, newAddress);
                  print('AddressPicker: Updated addresses: ${updatedAddresses.length}');
                  
                  if (updatedAddresses.isNotEmpty) {
                    if (mounted) {
                      setState(() {
                        _addresses = updatedAddresses;
                      });
                      
                      // Auto-select the new address
                      widget.onSelected(Map<String, dynamic>.from(updatedAddresses.last));
                    }
                    
                    // Close the dialog with success
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to save address')),
                    );
                  }
                } catch (e) {
                  print('AddressPicker: Error saving address: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving address: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
