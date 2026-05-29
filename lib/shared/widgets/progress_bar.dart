import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// A teal progress bar with rounded ends.
class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Color color;
  final Color bg;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.color = AppColors.primary,
    this.bg = AppColors.primarySoft,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return LayoutBuilder(builder: (ctx, c) {
      final w = c.maxWidth;
      return Stack(
        children: [
          Container(
            height: height,
            width: w,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
          Container(
            height: height,
            width: w * v,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ],
      );
    });
  }
}
