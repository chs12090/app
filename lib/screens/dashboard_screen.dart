import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:profocus/screens/pomodoro/pomodoro_timer_screen.dart';
import 'package:profocus/screens/project/project_list_screen.dart';
import 'package:profocus/screens/tools/flashcard_screen.dart';
import 'package:profocus/screens/tools/note_screen.dart';
import 'package:profocus/screens/tools/timer_screen.dart';
import 'package:profocus/screens/tools/timer_animation.dart';
import 'package:profocus/screens/progress/progress_tracker_screen.dart';
import 'package:profocus/services/auth_service.dart';
import 'package:profocus/widgets/theme_toggle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animations/animations.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _signOutAnimationController;
  late Animation<double> _fadeAnimation;
  User? currentUser;
  bool _isSigningOut = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _signOutAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _signOutAnimationController.reset();
          setState(() {
            _isSigningOut = false;
          });
        }
      });
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _signOutAnimationController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: colorScheme.surfaceContainer,
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (context, openContainer) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSigningOut
                    ? null
                    : () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        _signOutAnimationController.forward();
                        await context.read<AuthService>().signOut();
                        Navigator.of(context).pop();
                      },
                child: _isSigningOut
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: TimerAnimation(controller: _signOutAnimationController),
                      )
                    : Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              openBuilder: (context, _) => Container(),
              closedElevation: 0,
              closedColor: Colors.transparent,
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getUserName() {
    return currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.3),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      _getUserName()[0].toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _getUserName(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.timer, color: colorScheme.onSurface),
              title: Text('Pomodoro', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => PomodoroTimerScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_outlined, color: colorScheme.onSurface),
              title: Text('Projects', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ProjectListScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: colorScheme.onSurface),
              title: Text('Timer', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => TimerScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.quiz_outlined, color: colorScheme.onSurface),
              title: Text('Flashcards', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => FlashcardScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.note_outlined, color: colorScheme.onSurface),
              title: Text('Notes', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => NoteScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.trending_up, color: colorScheme.onSurface),
              title: Text('Progress', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => ProgressTrackerScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_outlined, color: colorScheme.onSurface),
              title: Text('Profile', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                // Add profile screen navigation here
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
              title: Text('Settings', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.pop(context);
                // Add settings screen navigation here
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Sign Out', style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ThemeToggle(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.menu, color: colorScheme.onSurface),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer.withOpacity(0.3),
                          colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _getUserName(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  SizedBox(width: 8),
                ],
              ),
              // Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Pomodoros',
                              '5',
                              Icons.timer_outlined,
                              colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Focus Time',
                              '2h 30m',
                              Icons.access_time,
                              colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Notifications Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notifications = [
                        {
                          'title': 'Project Deadline',
                          'message': 'Your project "App Development" is due tomorrow.',
                          'time': '10:30 AM',
                          'icon': Icons.calendar_today,
                        },
                        {
                          'title': 'Task Reminder',
                          'message': 'Complete UI design for homepage.',
                          'time': 'Yesterday',
                          'icon': Icons.check_circle_outline,
                        },
                        {
                          'title': 'Flashcard Review',
                          'message': '10 flashcards are due for review today.',
                          'time': '8:00 AM',
                          'icon': Icons.quiz_outlined,
                        },
                      ];
                      final notification = notifications[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: colorScheme.surfaceContainer,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              notification['icon'] as IconData,
                              color: colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            notification['message'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Text(
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 3, // Placeholder for 3 notifications
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}