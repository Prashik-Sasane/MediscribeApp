import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/color.dart';

class MedicineHighlighter {
  static Widget highlight(String text) {
    final keywords = [
      'tablet',
      'capsule',
      'syrup',
      'mg',
      'ml',
      'once',
      'twice',
      'daily',
    ];

    final words = text.split(' ');

    return RichText(
      text: TextSpan(
        children: words.map((word) {
          final clean = word.toLowerCase();
          final isMedicine =
              keywords.any((k) => clean.contains(k));

          return TextSpan(
            text: '$word ',
            style: TextStyle(
              color: isMedicine
                  ? AppColors.primary
                  : AppColors.textPrimary,
              fontWeight:
                  isMedicine ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }
}
