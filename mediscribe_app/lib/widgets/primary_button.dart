import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/color.dart';
import '../core/text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ nullable
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || onPressed == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
              : Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
