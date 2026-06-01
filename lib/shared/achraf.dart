import 'dart:math';

/// Achraf — the in-app guide. Generates contextual messages
/// (greetings, encouragement, tips) in Arabic with a Moroccan-Darija flavor.
/// All messages are scripted and offline.
class Achraf {
  static const String name = 'أشرف';
  static const String role = 'مدرّبك';
  static final Random _rand = Random();

  /// Greeting card shown on the Today screen.
  static String greet({
    required String userName,
    required int streak,
    required int dayId,
    required int doneTasks,
    required int totalTasks,
  }) {
    final hour = DateTime.now().hour;
    final you = userName.trim().isEmpty ? '' : ' $userName';

    final timeOpeners = hour < 12
        ? <String>['صباح الخير', 'صباح النور', 'صباح الفل']
        : hour < 17
            ? <String>['أهلاً', 'مرحبا', 'مساء الخير']
            : <String>['مساء الخير', 'مساء النور', 'أهلاً'];

    final opener = timeOpeners[_rand.nextInt(timeOpeners.length)];

    // Context-aware second sentence.
    final List<String> contexts;
    if (doneTasks == 0 && streak == 0) {
      contexts = [
        'يلا نبداو اليوم رقم $dayId. 5 دقايق وكفى.',
        'مستعد؟ راه أول خطوة هي الأصعب — وغادي نديرها بجوج.',
        'اليوم $dayId. ما تخمم بزاف، بدا بكلمة وحدة.',
      ];
    } else if (doneTasks == 0 && streak > 0) {
      contexts = [
        'streak ديالك $streak يوم — ما تخسرهاش اليوم 🔥',
        '$streak يوم متتالي. حافظ على الزخم.',
        'كاع المهام مازال بلاصتهم. تعال نتفاكوهم.',
      ];
    } else if (doneTasks == totalTasks) {
      contexts = [
        'برافو! كملتي اليوم كاع — راحة مستحقة 🎉',
        'مبروك! اليوم $dayId ✓ — streak $streak يوم.',
        'خدمة نضيفة. شوف المراجعة قبل ما تخرج.',
      ];
    } else if (doneTasks >= totalTasks / 2) {
      contexts = [
        'تقريبا وصلتي — بقى ${totalTasks - doneTasks} ديال المهام.',
        'نص الطريق وراءك. زيد ${totalTasks - doneTasks} مهام آخرى.',
        'كملت ${doneTasks} من $totalTasks. واصل، راه قريب.',
      ];
    } else {
      contexts = [
        'بدات مزيان. خلي العادة تكبر يوم بيوم.',
        'streak $streak يوم. كل يوم خطوة.',
        'مهامك اليوم: $totalTasks. شي $doneTasks ديالها كملت.',
      ];
    }

    final ctx = contexts[_rand.nextInt(contexts.length)];
    return '$opener$you 👋\n$ctx';
  }

  /// One-line tip shown before a review session.
  static String reviewIntro(int dueCount) {
    if (dueCount == 0) {
      return 'ما كاينش شي بطاقة مستحقة دابا. زيد كلمات جداد من مهمة اليوم.';
    }
    final pool = [
      'عندك $dueCount بطاقة. ركز على المعنى قبل ما تشوف الجواب.',
      '$dueCount بطاقة — جاوب بصراحة. "نسيت" أحسن من "جيد" غير باش.',
      'دير $dueCount بطاقة بتركيز. الكمية اقل، الجودة اكثر.',
      '$dueCount بطاقة. حاول تستعمل الكلمة فجملة قبل ما تكشف المعنى.',
    ];
    return pool[_rand.nextInt(pool.length)];
  }

  /// Shown when a review session is finished (no more due cards).
  static String reviewFinished({required int reviewed, required int again}) {
    if (reviewed == 0) {
      return 'ما راجعتي والو اليوم. غدا الكروت غادي يجيو بزاف. ابدا اليوم بشي 5 بطاقات.';
    }
    if (again == 0) {
      return 'ممتاز! $reviewed بطاقة بلا ما تنسى تا وحدة 🏆';
    }
    final pct = ((reviewed - again) / reviewed * 100).round();
    if (pct >= 80) {
      return 'برافو — $pct%‎ صحيح من $reviewed. هاد المستوى ديال البطل.';
    }
    if (pct >= 60) {
      return 'مزيان — $pct%‎ صحيح. الكلمات اللي نسيتي غادي ترجع لك قريب.';
    }
    return 'خدمة مستحقة. $pct%‎ صحيح — كلمات صعيبة، ولكن بالتكرار تولي ساهلة.';
  }

  /// Shown on the Day Complete screen.
  static String dayDoneCheer({required int streak, required int dayId}) {
    if (dayId == 90) {
      return '90 يوم! 🎓 وصلتي. هاد التطبيق كان معاك في الطريق، ولكن الفضل كلو ليك.';
    }
    if (streak >= 30) {
      return 'streak $streak يوم 🔥 — راك دزتي مرحلة العادة. دابا الإنجليزية ولات جزء منك.';
    }
    if (streak >= 7) {
      return 'أسبوع متتالي! 🌟 الدماغ ولا كيتعود — هاد هو السر.';
    }
    if (streak >= 3) {
      return 'تالت يوم متتالي. العادة كتبدا تكون. بقى صافي.';
    }
    return 'اليوم $dayId ✓ — رجع غدا فنفس الوقت، خاص الدماغ مرور تالت قبل ما يحفظ.';
  }

  /// Tip shown next to a particular task type. Optional.
  static String taskTip(String taskType) {
    switch (taskType) {
      case 'vocabulary':
        return 'اقرا الكلمة بصوت عالي مرتين قبل ما تشوف المعنى.';
      case 'listening':
        return 'سمع مرتين — مرة بلا ما تركز، ومرة بتركيز.';
      case 'shadowing':
        return 'قول معاه فس نفس اللحظة — حتى لو ما فهمتيش كلشي.';
      case 'speaking':
        return 'سجل، سمع راسك، عاود. الصوت ديالك هو أحسن مدرس.';
      case 'writing':
        return 'ما تخممش بزاف — كتب اللي طلع فبالك، الأخطاء جزء من التعلم.';
      case 'review':
        return 'جاوب بصراحة. "نسيت" راه ضروري باش يقواك ف الكلمات الصعيبة.';
      default:
        return 'خد وقتك، الجودة قبل السرعة.';
    }
  }
}
