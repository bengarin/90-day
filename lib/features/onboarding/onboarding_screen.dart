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
  final _goalCtrl = TextEditingController();
  String _language = 'en';
  String _level = 'A1';
  TimeOfDay _time = const TimeOfDay(
    hour: AppConstants.defaultReminderHour,
    minute: AppConstants.defaultReminderMinute,
  );

  @override
  Widget build(BuildContext context) {
    final langLabel = _language == 'en' ? 'الإنجليزية' : 'الفرنسية';
    if (_goalCtrl.text.isEmpty) {
      _goalCtrl.text = 'أتحدث $langLabel بثقة بعد 90 يوماً.';
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'مرحباً 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              const AchrafCard(
                message:
                    'أنا أشرف، مدرّبك الشخصي. اختار اللغة و المستوى ديالك، '
                    'و غادي نخدمو 90 يوم باش توصل للهدف.',
              ),
              const SizedBox(height: 22),

              // --- Language ---
              _SectionLabel(text: 'شنو اللغة لي بغيتي تتعلم؟'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceCard(
                      title: 'English',
                      subtitle: 'الإنجليزية',
                      emoji: '🇬🇧',
                      selected: _language == 'en',
                      onTap: () => setState(() => _language = 'en'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChoiceCard(
                      title: 'Français',
                      subtitle: 'الفرنسية',
                      emoji: '🇫🇷',
                      selected: _language == 'fr',
                      onTap: () => setState(() => _language = 'fr'),
                    ),
                  ),
                ],
              ),
              if (_language == 'fr') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.amber, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'البطاقات المخزنة دابا بالإنجليزية، '
                          'ولكن AI prompts غادي يهضرو معاك بالفرنسية بمستواك. '
                          'محتوى فرنسي كامل قادم.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.ink,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // --- Level ---
              _SectionLabel(text: 'المستوى ديالك دابا؟'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final lvl in const [
                    ('A1', 'مبتدئ', 'كنفهم كلمات بسيطة فقط'),
                    ('A2', 'متوسط -', 'كنقدر نهضر فجمل قصار'),
                    ('B1', 'متوسط', 'كنفهم محادثات يومية'),
                    ('B2', 'متوسط +', 'كنهضر بطلاقة معقولة'),
                  ])
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 50) / 2,
                      child: _ChoiceCard(
                        title: lvl.$1,
                        subtitle: lvl.$2,
                        sub2: lvl.$3,
                        selected: _level == lvl.$1,
                        onTap: () => setState(() => _level = lvl.$1),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 22),

              // --- Name ---
              _SectionLabel(text: 'اسمك'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: _input('مثلاً: أحمد'),
              ),

              const SizedBox(height: 16),

              // --- Goal ---
              _SectionLabel(text: 'الهدف ديالك'),
              const SizedBox(height: 6),
              TextField(
                controller: _goalCtrl,
                maxLines: 2,
                decoration: _input('اكتب هدفك بكلماتك'),
              ),

              const SizedBox(height: 16),

              // --- Reminder ---
              _SectionLabel(text: 'وقت التذكير اليومي'),
              const SizedBox(height: 6),
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

              const SizedBox(height: 28),
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
      currentLevel: _level,
      language: _language,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? sub2;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    this.sub2,
    this.emoji,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sub2 != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub2!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppColors.line),
          ],
        ),
      ),
    );
  }
}
