enum QuizKind { multipleChoice, fillBlank, translateAr }

class QuizQuestion {
  final QuizKind kind;
  final String prompt;
  /// Display under the prompt (e.g., Arabic gloss for an English question).
  final String? hint;
  final List<String> options;
  final int correctIndex;
  /// For fillBlank: the accepted answer in lowercase, ignoring punctuation.
  final String? acceptedAnswer;

  const QuizQuestion({
    required this.kind,
    required this.prompt,
    this.hint,
    this.options = const [],
    this.correctIndex = 0,
    this.acceptedAnswer,
  });

  bool isCorrect(int? chosen, String? typed) {
    switch (kind) {
      case QuizKind.multipleChoice:
      case QuizKind.translateAr:
        return chosen != null && chosen == correctIndex;
      case QuizKind.fillBlank:
        if (typed == null) return false;
        final normalized = typed
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s\-]'), '')
            .replaceAll(RegExp(r'\s+'), ' ');
        return normalized == acceptedAnswer;
    }
  }
}
