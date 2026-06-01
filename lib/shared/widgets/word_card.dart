import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../core/emoji_map.dart';
import '../../data/models/models.dart';
import '../tts.dart';

class WordCard extends StatelessWidget {
  final Word word;
  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    EmojiMap.of(word.wordEn),
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      word.wordEn,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                  onPressed: () => Tts.instance.speakEn(word.wordEn),
                ),
              ],
            ),
            if (word.ipa.isNotEmpty)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '/${word.ipa}/',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              word.meaningAr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      word.exampleEn,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.exampleAr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
