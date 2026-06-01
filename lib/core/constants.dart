/// App-wide constants. Kept simple and small.
class AppConstants {
  static const totalDays = 90;
  static const tasksPerDay = 6;

  // FSRS-4.5: target retention rate. 0.9 = aim to remember 90% of cards.
  static const fsrsRequestRetention = 0.9;

  // Default daily reminder time (24h).
  static const defaultReminderHour = 19;
  static const defaultReminderMinute = 0;

  // Streak-aware motivational messages used in notifications.
  static const motivationByStreak = <int, String>{
    0: 'هيا نبدأ اليوم! 5 دقائق فقط تكفي.',
    1: 'رائع! يومان متتاليان قادمان.',
    3: 'ثلاثة أيام متتالية! استمر.',
    7: 'أسبوع كامل! أنت بطل.',
    14: 'أسبوعان! الالتزام يصنع الفرق.',
    30: 'شهر كامل! أنت لا تُصدّق.',
    60: 'ستون يوماً! المرحلة الأخيرة قريبة.',
    89: 'يوم واحد فقط ويكتمل التحدي!',
  };
}
