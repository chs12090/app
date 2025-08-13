import 'package:flutter/material.dart';
import 'package:profocus/models/flashcard.dart';
import 'package:profocus/services/database_service.dart';
import 'package:profocus/utils/spaced_repetition.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animations/animations.dart';
import 'package:profocus/screens/tools/timer_animation.dart';

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  late AnimationController _animationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          setState(() {
            _isSaving = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final databaseService = DatabaseService(userId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        title: Text(
          'Flashcards',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input fields for question and answer
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _questionController,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter question',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _answerController,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter answer',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Add Flashcard button with animation
              OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                closedBuilder: (context, openContainer) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() {
                            _isSaving = true;
                          });
                          _animationController.forward();
                          final flashcard = Flashcard(
                            id: Uuid().v4(),
                            question: _questionController.text.isEmpty
                                ? 'Untitled Question'
                                : _questionController.text,
                            answer: _answerController.text,
                            nextReview: DateTime.now(),
                          );
                          await databaseService.createFlashcard(flashcard);
                          _questionController.clear();
                          _answerController.clear();
                          setState(() {
                            _isSaving = false;
                          });
                          _animationController.reset();
                        },
                  child: _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: TimerAnimation(controller: _animationController),
                        )
                      : Text(
                          'Add Flashcard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                openBuilder: (context, _) => Container(),
                closedElevation: 2,
                closedColor: Colors.transparent,
              ),
              SizedBox(height: 16),
              // Flashcard list
              Expanded(
                child: StreamBuilder(
                  stream: databaseService.getFlashcardsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading flashcards',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      );
                    }
                    if (!snapshot.hasData || (snapshot.data as List<Flashcard>).isEmpty) {
                      return Center(
                        child: Text(
                          'No flashcards yet',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    final flashcards = snapshot.data as List<Flashcard>;
                    return ListView.builder(
                      itemCount: flashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = flashcards[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: colorScheme.surfaceContainer,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              flashcard.question,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Next Review: ${flashcard.nextReview.toString().substring(0, 16)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onTap: () {
                              SpacedRepetition.updateFlashcard(flashcard, 5); // Example quality
                              databaseService.updateFlashcard(flashcard);
                              setState(() {}); // Refresh UI
                            },
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                              ),
                              onPressed: () async {
                                await databaseService.deleteFlashcard(flashcard.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}