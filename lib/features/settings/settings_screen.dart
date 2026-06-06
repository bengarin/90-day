import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/notifications.dart';
import '../../data/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay? _time;
  double _fontScale = 1.0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(statsRepoProvider);
    final h = int.tryParse(await repo.getSetting('reminder_hour') ?? '') ??
        AppConstants.defaultReminderHour;
    final m = int.tryParse(await repo.getSetting('reminder_minute') ?? '') ??
        AppConstants.defaultReminderMinute;
    final f = double.tryParse(await repo.getSetting('font_scale') ?? '') ?? 1.0;
    setState(() {
      _time = TimeOfDay(hour: h, minute: m);
      _fontScale = f;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final statsAsync = ref.watch(userStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          statsAsync.when(
            data: (stats) => Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.translate, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('اللغة و المستوى',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SegPicker(
                            options: const [
                              ('en', '🇬🇧 English'),
                              ('fr', '🇫🇷 Français'),
                            ],
                            value: stats.language,
                            onChanged: (v) async {
                              await ref
                                  .read(statsRepoProvider)
                                  .update(language: v);
                              ref.invalidate(userStatsProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final lvl in const ['A1', 'A2', 'B1', 'B2'])
                          ChoiceChip(
                            label: Text(lvl),
                            selected: stats.currentLevel == lvl,
                            onSelected: (_) async {
                              await ref
                                  .read(statsRepoProvider)
                                  .update(currentLevel: lvl);
                              ref.invalidate(userStatsProvider);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm, color: AppColors.primary),
              title: const Text('وقت التذكير اليومي'),
              subtitle: Text(
                  '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_left),
              onTap: _pickTime,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('حجم الخط',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
                      const Spacer(),
                      Text('×${_fontScale.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.inkSecondary)),
                    ],
                  ),
                  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    onChanged: (v) => setState(() => _fontScale = v),
                    onChangeEnd: (v) async {
                      await ref
                          .read(statsRepoProvider)
                          .setSetting('font_scale', v.toString());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.coral),
              title: const Text('إعادة ضبط التقدّم'),
              subtitle: const Text('يمحو الإحصائيات والسلسلة والمراجعات'),
              onTap: _confirmReset,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: const Text('عن التطبيق'),
              subtitle: const Text(
                  'رفيقي في الإنجليزية — رفيقك في تعلّم الإنجليزية لمدة 90 يوماً.\n100% بدون إنترنت.'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time!,
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.ltr,
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _time = picked);
    final repo = ref.read(statsRepoProvider);
    await repo.setSetting('reminder_hour', picked.hour.toString());
    await repo.setSetting('reminder_minute', picked.minute.toString());
    final stats = await repo.get();
    await Notifications.instance.scheduleDaily(
      hour: picked.hour,
      minute: picked.minute,
      streak: stats.currentStreak,
    );
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة الضبط'),
        content: const Text('هل أنت متأكد؟ سيتم محو تقدّمك بالكامل.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('إعادة الضبط',
                  style: TextStyle(color: AppColors.coral))),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(statsRepoProvider).resetAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarded');
    ref.invalidate(userStatsProvider);
    ref.invalidate(allDayStatesProvider);
    ref.invalidate(completedCountProvider);
    ref.invalidate(dueCardsProvider);
    ref.invalidate(dueCountByDayProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة الضبط. أعد تشغيل التطبيق.')),
      );
    }
  }
}

class _SegPicker extends StatelessWidget {
  final List<(String, String)> options;
  final String value;
  final ValueChanged<String> onChanged;
  const _SegPicker({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(o.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: value == o.$1
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      o.$2,
                      style: TextStyle(
                        color:
                            value == o.$1 ? Colors.white : AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
