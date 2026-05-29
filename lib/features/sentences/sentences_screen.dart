import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/colors.dart';
import '../../data/providers.dart';
import '../../shared/widgets/sentence_card.dart';

class SentencesScreen extends ConsumerWidget {
  const SentencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(refreshCounterProvider);
    final dayIdAsync = ref.watch(currentDayIdProvider);

    return dayIdAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (dayId) {
        final day = ref.watch(dayProvider(dayId));
        final sentences = ref.watch(sentencesForDayProvider(dayId));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('جمل اليوم',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        )),
                    if (day.value != null)
                      Text(
                        'اليوم ${day.value!.id} • ${day.value!.titleAr}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: sentences.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('خطأ: $e')),
                data: (ss) => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ss.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => SentenceCard(sentence: ss[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
