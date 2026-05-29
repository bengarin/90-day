import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/sentence_card.dart';
import '../../shared/widgets/word_card.dart';
import '../day_complete/day_complete_screen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;
  final int dayId;
  const TaskDetailScreen({super.key, required this.task, required this.dayId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  // Speaking task — record + playback
  final _record = AudioRecorder();
  final _player = AudioPlayer();
  bool _recording = false;
  String? _recordedPath;

  // Writing task
  final _writeCtrl = TextEditingController();

  @override
  void dispose() {
    _record.dispose();
    _player.dispose();
    _writeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    return Scaffold(
      appBar: AppBar(title: Text(t.labelAr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined,
                            color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(t.labelAr,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink))),
                        Text('${t.durationMin} د',
                            style: const TextStyle(
                                color: AppColors.inkSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(t.instructionsAr,
                        style: const TextStyle(
                            color: AppColors.inkSecondary, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _content()),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _markDone,
                child: const Text('تم ✓'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    switch (widget.task.type) {
      case 'vocabulary':
        return _wordsList();
      case 'listening':
      case 'shadowing':
        return _sentencesList();
      case 'speaking':
        return _speakingArea();
      case 'writing':
        return _writingArea();
      case 'review':
        return _reviewHint();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _wordsList() {
    final wordsAsync = ref.watch(wordsForDayProvider(widget.dayId));
    return wordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (ws) => ListView.separated(
        itemCount: ws.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => WordCard(word: ws[i]),
      ),
    );
  }

  Widget _sentencesList() {
    final sentAsync = ref.watch(sentencesForDayProvider(widget.dayId));
    return sentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (ss) => ListView.separated(
        itemCount: ss.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => SentenceCard(sentence: ss[i]),
      ),
    );
  }

  Widget _speakingArea() {
    final sentAsync = ref.watch(sentencesForDayProvider(widget.dayId));
    return sentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (ss) {
        final pickThree = ss.take(3).toList();
        return ListView(
          children: [
            for (final s in pickThree) ...[
              SentenceCard(sentence: s),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text(
                      'سجل صوتك',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(_recording ? Icons.stop : Icons.mic),
                          label: Text(_recording ? 'إيقاف' : 'تسجيل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _recording ? AppColors.coral : AppColors.primary,
                          ),
                          onPressed: _toggleRecord,
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('استمع'),
                          onPressed: _recordedPath == null
                              ? null
                              : () async {
                                  await _player.setFilePath(_recordedPath!);
                                  await _player.play();
                                },
                        ),
                      ],
                    ),
                    if (_recordedPath != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('تم حفظ التسجيل ✓',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _record.stop();
      setState(() {
        _recording = false;
        _recordedPath = path;
      });
    } else {
      final ok = await _record.hasPermission();
      if (!ok) return;
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path,
          'rec_${DateTime.now().millisecondsSinceEpoch}.m4a');
      await _record.start(const RecordConfig(), path: path);
      setState(() {
        _recording = true;
        _recordedPath = null;
      });
    }
  }

  Widget _writingArea() {
    final wordsAsync = ref.watch(wordsForDayProvider(widget.dayId));
    return Column(
      children: [
        wordsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (ws) {
            final picks = ws.take(6).map((w) => w.wordEn).join(' · ');
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('استعمل بعض هذه الكلمات:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkSecondary)),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(picks,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _writeCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Write 4–6 sentences about yourself...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewHint() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 64, color: AppColors.primary),
            const SizedBox(height: 8),
            const Text('افتح تبويب "مراجعة" من الأسفل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                )),
            const SizedBox(height: 6),
            const Text(
              'راجع البطاقات المستحقة اليوم ثم اضغط "تم ✓".',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markDone() async {
    final vocabRepo = ref.read(vocabRepoProvider);
    final dayRepo = ref.read(dayRepoProvider);
    final srsRepo = ref.read(srsRepoProvider);
    final statsRepo = ref.read(statsRepoProvider);

    await vocabRepo.setTaskDone(widget.task.id, true);
    await dayRepo.addMinutes(widget.dayId, widget.task.durationMin);
    if (widget.task.type == 'vocabulary') {
      await srsRepo.seedWordsFromDay(widget.dayId);
    }

    // Check if all tasks are done -> mark day complete & bump streak.
    final tasks = await vocabRepo.tasksForDay(widget.dayId);
    final states = await vocabRepo.taskStatesForDay(widget.dayId);
    final allDone = tasks.every((tt) => states[tt.id]?.isDone == true);

    ref.invalidate(taskStatesForDayProvider(widget.dayId));
    ref.invalidate(dueCardsProvider);
    ref.invalidate(dueCountByDayProvider);
    ref.read(refreshCounterProvider.notifier).state++;

    if (!mounted) return;

    if (allDone) {
      await dayRepo.setDayCompleted(widget.dayId);
      final words = await vocabRepo.wordsForDay(widget.dayId);
      final minutesSum = tasks.fold<int>(0, (a, b) => a + b.durationMin);
      final stats =
          await statsRepo.bumpStreakOnDayComplete(minutesSum, words.length);
      ref.invalidate(userStatsProvider);
      ref.invalidate(completedCountProvider);
      ref.invalidate(allDayStatesProvider);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DayCompleteScreen(
            dayId: widget.dayId,
            streak: stats.currentStreak,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
