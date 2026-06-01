import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../achraf.dart';

/// Avatar + speech-bubble card for Achraf.
/// Use [AchrafCard.message] when you have a prebuilt string.
class AchrafCard extends StatelessWidget {
  final String message;
  final EdgeInsets padding;
  final bool compact;

  const AchrafCard({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.all(14),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x260F6E56)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AchrafAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      Achraf.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x1A0F6E56),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        Achraf.role,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 2 : 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    height: 1.5,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchrafAvatar extends StatelessWidget {
  final double size;
  const AchrafAvatar({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF14A37F)],
        ),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x400F6E56),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'أ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
