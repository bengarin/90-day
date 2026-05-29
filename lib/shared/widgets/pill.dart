import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// A small rounded pill — used for "Day X / 90", phase chips, etc.
class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color bg;
  final Color fg;

  const Pill({
    super.key,
    required this.text,
    this.icon,
    this.bg = AppColors.primarySoft,
    this.fg = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
