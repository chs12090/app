import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int seconds = 0;
  int countdownSeconds = 0; // For countdown mode
  bool isRunning = false;
  bool isStopwatch = true;
  Timer? _timer;
  Timer? _imageTimer;
  int _currentImageIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _minutesController = TextEditingController();
  final List<String> _backgroundImages = [
    'images/pomodoro_backgrounds/b1.jpg',
    'images/pomodoro_backgrounds/b2.jpg',
    'images/pomodoro_backgrounds/b3.jpg',
    // Add more images as needed
  ];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/pomodoro_music.mp3'), mode: PlayerMode.mediaPlayer);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer); // Enable looping
      if (!isRunning) {
        await _audioPlayer.pause();
      }
    } catch (e) {
      debugPrint('Error playing background music: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load background music'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _startImageCycling() {
    if (_imageTimer != null) {
      _imageTimer!.cancel();
    }
    _imageTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
      });
    });
  }

  void _stopImageCycling() {
    if (_imageTimer != null) {
      _imageTimer!.cancel();
      _imageTimer = null;
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (isStopwatch) {
          seconds++;
        } else {
          if (seconds > 0) {
            seconds--;
          } else {
            _timer!.cancel();
            isRunning = false;
            _stopImageCycling();
            _audioPlayer.pause();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Countdown completed!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }
      });
    });
    _startImageCycling();
    _audioPlayer.resume();
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _stopImageCycling();
    _audioPlayer.pause();
  }

  void _resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      seconds = isStopwatch ? 0 : countdownSeconds;
      isRunning = false;
    });
    _stopImageCycling();
    _audioPlayer.pause();
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        if (!isStopwatch && seconds == 0) {
          _showCountdownDialog();
        } else {
          _startTimer();
        }
      } else {
        _pauseTimer();
      }
    });
  }

  Future<void> _showCountdownDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    _minutesController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Set Countdown Duration',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Minutes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(_minutesController.text) ?? 0;
                if (minutes > 0) {
                  setState(() {
                    countdownSeconds = minutes * 60;
                    seconds = countdownSeconds;
                    isRunning = true;
                  });
                  _startTimer();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid number of minutes'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Start'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _imageTimer?.cancel();
    _audioPlayer.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            _backgroundImages[_currentImageIndex],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Text(
                  'Failed to load background',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          // Semi-transparent overlay for better text visibility
          Container(
            color: colorScheme.surface.withOpacity(0.5),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // AppBar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    isStopwatch ? 'Stopwatch' : 'Countdown Timer',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                ),
                // Main content
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Timer Display
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isStopwatch) ...[
                          SizedBox(height: 16),
                          // Progress Indicator for Countdown
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: countdownSeconds > 0 ? seconds / countdownSeconds : 0,
                              strokeWidth: 8,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                            ),
                          ),
                        ],
                        SizedBox(height: 32),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: toggleTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                minimumSize: Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isRunning ? 'Pause' : 'Start',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _resetTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                minimumSize: Size(120, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                        // Switch Mode Button
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isStopwatch = !isStopwatch;
                              seconds = isStopwatch ? 0 : countdownSeconds;
                              if (isRunning) {
                                _pauseTimer();
                                isRunning = false;
                              }
                            });
                            if (!isStopwatch) {
                              _showCountdownDialog();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.tertiary,
                            foregroundColor: colorScheme.onTertiary,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isStopwatch ? 'Switch to Countdown' : 'Switch to Stopwatch',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}