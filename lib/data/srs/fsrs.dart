import 'dart:math';

/// FSRS-4.5 spaced repetition algorithm.
/// Pure Dart — no DB, no Flutter. Pluggable into [SrsRepo].
///
/// Reference: https://github.com/open-spaced-repetition/fsrs4anki

class FsrsState {
  static const int newCard = 0;
  static const int learning = 1;
  static const int review = 2;
  static const int relearning = 3;
}

class FsrsRating {
  static const int again = 1;
  static const int hard = 2;
  static const int good = 3;
  static const int easy = 4;
}

class FsrsCard {
  final double stability;
  final double difficulty;
  final int state; // FsrsState.*
  final int lapses;
  final int reps;
  final int elapsedDays;
  final int scheduledDays;
  final DateTime? lastReview;

  const FsrsCard({
    this.stability = 0,
    this.difficulty = 0,
    this.state = FsrsState.newCard,
    this.lapses = 0,
    this.reps = 0,
    this.elapsedDays = 0,
    this.scheduledDays = 0,
    this.lastReview,
  });
}

class FsrsSchedulingInfo {
  final FsrsCard card;
  final DateTime due;
  final int interval;
  const FsrsSchedulingInfo({
    required this.card,
    required this.due,
    required this.interval,
  });
}

class Fsrs {
  final List<double> w;
  final double requestRetention;
  final int maximumInterval;

  const Fsrs({
    this.w = const [
      0.4072, 1.1829, 3.1262, 15.4722, 7.2102, 0.5316, 1.0651, 0.0234,
      1.616, 0.1544, 1.0824, 1.9813, 0.0953, 0.2975, 2.2042, 0.2407, 2.9466,
    ],
    this.requestRetention = 0.9,
    this.maximumInterval = 36500,
  });

  double _initStability(int rating) {
    final v = w[rating - 1];
    return v < 0.1 ? 0.1 : v;
  }

  double _initDifficulty(int rating) {
    return (w[4] - (rating - 3) * w[5]).clamp(1.0, 10.0);
  }

  double _meanReversion(double init, double current) {
    return w[7] * init + (1 - w[7]) * current;
  }

  double _nextDifficulty(double d, int rating) {
    final newD = d - w[6] * (rating - 3);
    return _meanReversion(w[4], newD).clamp(1.0, 10.0);
  }

  double _nextRecallStability(double d, double s, double r, int rating) {
    final hardPenalty = rating == FsrsRating.hard ? w[15] : 1.0;
    final easyBonus = rating == FsrsRating.easy ? w[16] : 1.0;
    return s *
        (exp(w[8]) *
                (11 - d) *
                pow(s, -w[9]) *
                (exp(w[10] * (1 - r)) - 1) *
                hardPenalty *
                easyBonus +
            1);
  }

  double _nextForgetStability(double d, double s, double r) {
    return w[11] *
        pow(d, -w[12]) *
        (pow(s + 1, w[13]) - 1) *
        exp(w[14] * (1 - r));
  }

  double retrievability(int elapsedDays, double stability) {
    if (stability <= 0) return 0;
    return pow(1 + elapsedDays / (9 * stability), -1).toDouble();
  }

  int _nextInterval(double s) {
    final i = 9 * s * (1 / requestRetention - 1);
    final r = i.round();
    if (r < 1) return 1;
    if (r > maximumInterval) return maximumInterval;
    return r;
  }

  /// Apply a rating and return the updated card + next due date.
  FsrsSchedulingInfo schedule({
    required FsrsCard card,
    required int rating,
    required DateTime now,
  }) {
    final last = card.lastReview;
    final elapsed = last == null
        ? 0
        : now.difference(last).inDays.clamp(0, maximumInterval);

    late double newS;
    late double newD;
    late int newState;
    late int interval;
    int newLapses = card.lapses;
    final newReps = card.reps + 1;

    if (card.state == FsrsState.newCard) {
      newS = _initStability(rating);
      newD = _initDifficulty(rating);
      if (rating == FsrsRating.again) {
        newState = FsrsState.learning;
        newLapses++;
        interval = 1;
      } else if (rating == FsrsRating.hard) {
        newState = FsrsState.learning;
        interval = 1;
      } else {
        newState = FsrsState.review;
        interval = _nextInterval(newS);
      }
    } else {
      final r = retrievability(elapsed, card.stability);
      newD = _nextDifficulty(card.difficulty, rating);
      if (rating == FsrsRating.again) {
        newS = _nextForgetStability(card.difficulty, card.stability, r);
        newState = FsrsState.relearning;
        newLapses++;
        interval = 1;
      } else {
        newS = _nextRecallStability(card.difficulty, card.stability, r, rating);
        newState = FsrsState.review;
        interval = _nextInterval(newS);
      }
    }

    final due = now.add(Duration(days: interval));
    final updated = FsrsCard(
      stability: newS,
      difficulty: newD,
      state: newState,
      lapses: newLapses,
      reps: newReps,
      elapsedDays: elapsed,
      scheduledDays: interval,
      lastReview: now,
    );

    return FsrsSchedulingInfo(card: updated, due: due, interval: interval);
  }

  /// Compute the interval (in days) that each rating would produce, so the
  /// Review UI can show "Again 1d · Hard 3d · Good 14d · Easy 40d" before
  /// the user taps.
  Map<int, int> previewIntervals(FsrsCard card, DateTime now) {
    final out = <int, int>{};
    for (final r in [
      FsrsRating.again,
      FsrsRating.hard,
      FsrsRating.good,
      FsrsRating.easy,
    ]) {
      out[r] = schedule(card: card, rating: r, now: now).interval;
    }
    return out;
  }
}
