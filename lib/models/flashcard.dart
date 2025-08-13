class Flashcard {
  String id;
  String question;
  String answer;
  DateTime nextReview;
  int interval; // Days until next review
  double easiness; // Spaced repetition easiness factor

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.nextReview,
    this.interval = 1,
    this.easiness = 2.5,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'nextReview': nextReview.toIso8601String(),
        'interval': interval,
        'easiness': easiness,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        question: json['question'],
        answer: json['answer'],
        nextReview: DateTime.parse(json['nextReview']),
        interval: json['interval'],
        easiness: json['easiness'].toDouble(),
      );
}