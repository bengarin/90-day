import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../shared/achraf.dart';
import '../../shared/widgets/achraf_card.dart';

class DayCompleteScreen extends StatelessWidget {
  final int dayId;
  final int streak;
  const DayCompleteScreen(
      {super.key, required this.dayId, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text(
                'أحسنت!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أنهيت اليوم $dayId من 90.',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.amberSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      'سلسلة $streak يوماً',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AchrafCard(
                  message: Achraf.dayDoneCheer(streak: streak, dayId: dayId),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('فتح اليوم التالي'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
