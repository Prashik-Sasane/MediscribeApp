import 'package:flutter/material.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text("Filter", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          
          const Text("Specialist", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildChipRow(["All", "Dentist", "Cardiology", "Neurology"]),
          
          const SizedBox(height: 20),
          const Text("Reviews", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRatingOption("4.5 and above"),
          _buildRatingOption("4.0 - 4.5"),
          
          const SizedBox(height: 20),
          const Text("Consultation Fee (Price)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          RangeSlider(
            values: const RangeValues(10, 40),
            min: 0,
            max: 100,
            activeColor: const Color(0xFF2E7DFF),
            onChanged: (values) {},
          ),
          
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text("Reset Filter"))),
              const SizedBox(width: 15),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7DFF)),
                onPressed: () => Navigator.pop(context), 
                child: const Text("Apply", style: TextStyle(color: Colors.white)))),
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
        children: labels.map((label) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: label == "All" ? const Color(0xFF2E7DFF) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        )).toList(),
      ),
    );
  }

  Widget _buildRatingOption(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              Text(" $text", style: const TextStyle(color: Colors.white70)),
            ],
          ),
          Radio(value: true, groupValue: true, onChanged: (v) {}, activeColor: const Color(0xFF2E7DFF)),
        ],
      ),
    );
  }
}