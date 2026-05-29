import 'package:flutter/material.dart';

import '../progress/progress_screen.dart';
import '../review/review_screen.dart';
import '../sentences/sentences_screen.dart';
import '../today/today_screen.dart';
import '../vocabulary/vocabulary_screen.dart';

/// Bottom-nav shell. Order on screen (RTL): اليوم · كلمات · جمل · مراجعة · تقدّم.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  static const _pages = <Widget>[
    TodayScreen(),
    VocabularyScreen(),
    SentencesScreen(),
    ReviewScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_idx]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.today_outlined), label: 'اليوم'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined), label: 'كلمات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'جمل'),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh), label: 'مراجعة'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'تقدّم'),
        ],
      ),
    );
  }
}
