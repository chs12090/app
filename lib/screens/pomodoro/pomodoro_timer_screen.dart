import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:profocus/utils/constants.dart';
import 'package:profocus/widgets/timer_animation.dart';
import 'package:audioplayers/audioplayers.dart';

class PomodoroTimerScreen extends StatefulWidget {
  @override
  _PomodoroTimerScreenState createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> with SingleTickerProviderStateMixin {
  int workDuration = 25 * 60;
  int breakDuration = 5 * 60;
  int secondsLeft = 25 * 60;
  bool isWorking = true;
  bool isRunning = false;
  AnimationController? _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _imageTimer;
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'images/pomodoro_backgrounds/b1.jpg',
    'images/pomodoro_backgrounds/b2.jpg',
    'images/pomodoro_backgrounds/b3.jpg',
    // Add more images as needed
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: workDuration));
    _controller!.addListener(() {
      setState(() {
        secondsLeft = (_controller!.duration!.inSeconds * (1 - _controller!.value)).round();
      });
      if (_controller!.isCompleted) {
        setState(() {
          isWorking = !isWorking;
          secondsLeft = isWorking ? workDuration : breakDuration;
          _controller!.duration = Duration(seconds: secondsLeft);
          _controller!.reset();
          if (isRunning) _controller!.forward();
        });
      }
    });

    // Start audio playback
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play(AssetSource('audio/pomodoro_music.mp3'), mode: PlayerMode.mediaPlayer);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer); // Ensure looping
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

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        _controller!.forward();
        _startImageCycling();
        _audioPlayer.resume();
      } else {
        _controller!.stop();
        _stopImageCycling();
        _audioPlayer.pause();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _audioPlayer.dispose();
    _stopImageCycling();
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
                // AppBar-like header
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    isWorking ? 'Work Session' : 'Break Time',
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
                            '${(secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(secondsLeft % 60).toString().padLeft(2, '0')}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        // Timer Animation
                        TimerAnimation(controller: _controller!),
                        SizedBox(height: 32),
                        // Start/Pause Button
                        ElevatedButton(
                          onPressed: toggleTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: Size(200, 50),
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