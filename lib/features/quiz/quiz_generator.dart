import 'dart:math';

import '../../data/models/models.dart';
import 'quiz_models.dart';

/// Builds a per-day quiz from the bundled words + sentences.
/// Mix:  ~4 word-meaning MCQ  +  ~3 fill-in-blank  +  ~2 reverse MCQ.
class QuizGenerator {
  final Random _rand;
  QuizGenerator({int? seed}) : _rand = Random(seed);

  List<QuizQuestion> build({
    required List<Word> dayWords,
    required List<Sentence> daySentences,
    int wantedMcq = 4,
    int wantedFill = 3,
    int wantedReverse = 2,
  }) {
    final qs = <QuizQuestion>[];
    if (dayWords.length < 4) return qs;

    final wordsShuffled = [...dayWords]..shuffle(_rand);

    // 1) Word → meaning (English prompt, 4 Arabic options)
    final mcqWords = wordsShuffled.take(wantedMcq).toList();
    for (final w in mcqWords) {
      final distractors = [...dayWords]
        ..removeWhere((x) => x.id == w.id)
        ..shuffle(_rand);
      final pickedDistractors =
          distractors.take(3).map((d) => d.meaningAr).toList();
      final options = [w.meaningAr, ...pickedDistractors]..shuffle(_rand);
      final correct = options.indexOf(w.meaningAr);
      qs.add(QuizQuestion(
        kind: QuizKind.multipleChoice,
        prompt: w.wordEn,
        hint: w.ipa.isEmpty ? null : '/${w.ipa}/',
        options: options,
        correctIndex: correct,
      ));
    }

    // 2) Fill-in-the-blank from sentences using day words.
    final fillCandidates = <(Sentence, Word)>[];
    for (final s in daySentences) {
      for (final w in dayWords) {
        if (_sentenceContains(s.sentenceEn, w.wordEn)) {
          fillCandidates.add((s, w));
          break;
        }
      }
    }
    fillCandidates.shuffle(_rand);
    for (final (s, w) in fillCandidates.take(wantedFill)) {
      final blanked = _blankWord(s.sentenceEn, w.wordEn);
      qs.add(QuizQuestion(
        kind: QuizKind.fillBlank,
        prompt: blanked,
        hint: s.translationAr,
        acceptedAnswer: w.wordEn.toLowerCase(),
      ));
    }

    // 3) Reverse: Arabic meaning → English word (MCQ)
    final remaining = wordsShuffled
        .skip(wantedMcq)
        .toList()
      ..shuffle(_rand);
    final reversePool = remaining.isEmpty ? wordsShuffled : remaining;
    for (final w in reversePool.take(wantedReverse)) {
      final distractors = [...dayWords]
        ..removeWhere((x) => x.id == w.id)
        ..shuffle(_rand);
      final pickedDistractors =
          distractors.take(3).map((d) => d.wordEn).toList();
      final options = [w.wordEn, ...pickedDistractors]..shuffle(_rand);
      final correct = options.indexOf(w.wordEn);
      qs.add(QuizQuestion(
        kind: QuizKind.translateAr,
        prompt: w.meaningAr,
        options: options,
        correctIndex: correct,
      ));
    }

    qs.shuffle(_rand);
    return qs;
  }

  bool _sentenceContains(String sentence, String word) {
    final s = sentence.toLowerCase();
    final w = word.toLowerCase();
    final pattern = RegExp(r'\b' + RegExp.escape(w) + r'\b');
    return pattern.hasMatch(s);
  }

  String _blankWord(String sentence, String word) {
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b',
        caseSensitive: false);
    return sentence.replaceFirst(pattern, '____');
  }
}
