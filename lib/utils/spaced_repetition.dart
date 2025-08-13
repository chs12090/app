import 'package:profocus/models/flashcard.dart';

class SpacedRepetition {
  static void updateFlashcard(Flashcard flashcard, int quality) {
    // Quality: 0-5 (0 = complete failure, 5 = perfect recall)
    if (quality < 3) {
      flashcard.interval = 1;
    } else {
      flashcard.easiness = (flashcard.easiness + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))).clamp(1.3, 2.5);
      flashcard.interval = (flashcard.interval * flashcard.easiness).round();
    }
    flashcard.nextReview = DateTime.now().add(Duration(days: flashcard.interval));
  }
}