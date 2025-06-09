import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safe_zone/screens/welcome_screen.dart';
import 'common/theme.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAlbpIQiJsXy2IuNmD9DLOJMuii0U_g058",
      authDomain: "safezone-project-4161e.firebaseapp.com",
      projectId: "safezone-project-4161e",
      storageBucket: "safezone-project-4161e.firebasestorage.app",
      messagingSenderId: "469104182264",
      appId: "1:469104182264:web:aa096f8d6013aa5161cc0d",
      measurementId: "G-7KZ5L10WNM",
    ),
  );

  runApp(const SafeZoneApp());
}

class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemes.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SafeZone',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: mode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

