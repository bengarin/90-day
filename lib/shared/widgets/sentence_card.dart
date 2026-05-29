import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../data/models/models.dart';
import '../tts.dart';

class SentenceCard extends StatelessWidget {
  final Sentence sentence;
  const SentenceCard({super.key, required this.sentence});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                sentence.sentenceEn,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sentence.translationAr,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => Tts.instance.speakEn(sentence.sentenceEn),
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('استمع'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
