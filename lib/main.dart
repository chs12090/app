import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:profocus/config/firebase_config.dart';
import 'package:profocus/screens/auth/login_screen.dart';
import 'package:profocus/screens/dashboard_screen.dart';
import 'package:profocus/services/auth_service.dart';
import 'package:profocus/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();

    // Keep database synced on mobile
    if (!kIsWeb) {
      await FirebaseDatabase.instance.ref().keepSynced(true);
    }

    runApp(const ProFocusApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class ProFocusApp extends StatelessWidget {
  const ProFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'ProFocus',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            if (snapshot.hasData) {
              return  DashboardScreen();
            }
            return  LoginScreen();
          },
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $error'),
        ),
      ),
    );
  }
}
