import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Firebase options for Web (replace with your Firebase config from the Firebase Console)
        await Firebase.initializeApp(
          options: const FirebaseOptions(
  apiKey: "AIzaSyAuH9wxZePPgkpAbF-9JjyEWFYZmDQVAu8",
  authDomain: "todoapp-93779.firebaseapp.com",
  databaseURL: "https://todoapp-93779-default-rtdb.firebaseio.com",
  projectId: "todoapp-93779",
  storageBucket: "todoapp-93779.firebasestorage.app",
  messagingSenderId: "990823203118",
  appId: "1:990823203118:web:e8644f39c0bd7cbd253abf",
  measurementId: "G-3CYL6J42WR"          ),
        );
      } else {
        // For mobile, use default initialization with config files
        await Firebase.initializeApp();
      }
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }
}