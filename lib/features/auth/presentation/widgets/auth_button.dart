// lib/features/auth/presentation/widgets/auth_button.dart
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}