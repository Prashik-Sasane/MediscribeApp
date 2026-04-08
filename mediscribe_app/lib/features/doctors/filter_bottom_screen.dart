import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final String currentSpecialty;
  final Function(String specialty) onApply;

  const FilterBottomSheet({
    super.key,
    this.currentSpecialty = '',
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedSpecialty;
  late RangeValues _feeRange;

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = widget.currentSpecialty.isEmpty ? 'All' : widget.currentSpecialty;
    _feeRange = const RangeValues(0, 2000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Filter",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Specialty Filter
          const Text(
            "Specialist",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildChipRow([
            "All",
            "Dentist",
            "Cardiology",
            "Neurology",
            "General Physician",
            "Dermatology",
            "Orthopedics",
            "Pediatrics",
          ]),

          const SizedBox(height: 20),

          // Consultation Fee Filter
          const Text(
            "Consultation Fee (₹)",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${_feeRange.start.toInt()}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '₹${_feeRange.end.toInt()}',
                style: const TextStyle(color: Color(0xFF2E7DFF), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _feeRange,
            min: 0,
            max: 2000,
            divisions: 20,
            activeColor: const Color(0xFF2E7DFF),
            inactiveColor: Colors.white24,
            labels: RangeLabels(
              '₹${_feeRange.start.toInt()}',
              '₹${_feeRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() => _feeRange = values);
            },
          ),

          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSpecialty = 'All';
                      _feeRange = const RangeValues(0, 2000);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Reset Filter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7DFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final specialty = _selectedSpecialty == 'All' ? '' : _selectedSpecialty;
                    widget.onApply(specialty);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Apply",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow(List<String> labels) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.map((label) {
          final isSelected = label == _selectedSpecialty;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSpecialty = label);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7DFF) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2E7DFF) : Colors.white24,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}