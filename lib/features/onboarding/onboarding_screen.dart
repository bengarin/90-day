import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../core/notifications.dart';
import '../../data/providers.dart';
import '../../shared/widgets/achraf_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _goalCtrl =
      TextEditingController(text: 'أتحدث الإنجليزية بثقة بعد 90 يوماً.');
  TimeOfDay _time = const TimeOfDay(
    hour: AppConstants.defaultReminderHour,
    minute: AppConstants.defaultReminderMinute,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'مرحباً 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              const AchrafCard(
                message:
                    'أنا أشرف، مدرّبك الشخصي ف الإنجليزية. غادي نمشي معاك يوم بيوم — 90 يوم وغادي تهضر بثقة.\nقبل ما نبداو، عرّفني على راسك.',
              ),
              const SizedBox(height: 20),
              _label('اسمك'),
              TextField(
                controller: _nameCtrl,
                decoration: _input('مثلاً: أحمد'),
              ),
              const SizedBox(height: 16),
              _label('هدفك من التطبيق'),
              TextField(
                controller: _goalCtrl,
                maxLines: 2,
                decoration: _input('اكتب هدفك بكلماتك'),
              ),
              const SizedBox(height: 16),
              _label('وقت التذكير اليومي'),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                    builder: (ctx, child) => Directionality(
                      textDirection: TextDirection.ltr,
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finish,
                  child: const Text('ابدأ التحدي'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.inkSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      );

  Future<void> _finish() async {
    final stats = ref.read(statsRepoProvider);
    await stats.update(
      name: _nameCtrl.text.trim(),
      dailyGoal: _goalCtrl.text.trim(),
    );
    await stats.setSetting('first_open_date', fmtDate(today()));
    await stats.setSetting('reminder_hour', _time.hour.toString());
    await stats.setSetting('reminder_minute', _time.minute.toString());

    await Notifications.instance.requestPermissions();
    await Notifications.instance.scheduleDaily(
      hour: _time.hour,
      minute: _time.minute,
      streak: 0,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);

    widget.onDone();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }
}
