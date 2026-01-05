import 'package:flutter/material.dart';

class AppTextStyles {
  // Use Theme.of(context) colors for dynamic theme support
  static TextStyle heroTitle(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onSurface,
    height: 1.3,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );

  // Legacy static styles (kept for backward compatibility)
  static const TextStyle heroTitleStatic = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle subtitleStatic = TextStyle(
    fontSize: 16,
    height: 1.5,
  );

  static const TextStyle sectionTitleStatic = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}
