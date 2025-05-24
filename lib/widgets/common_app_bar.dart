import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_zone/screens/welcome_screen.dart';
import 'package:safe_zone/theme.dart';

PreferredSizeWidget buildCommonAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? extraActions, // 💥 Bunu mutlaka ekle
}) {
  return AppBar(
    title: Text(title),
    actions: [
      ...?extraActions, // 💥 Eğer varsa dışarıdan gelen aksiyonları da ekle
      IconButton(
        icon: const Icon(Icons.brightness_6),
        tooltip: "Toggle Theme",
        onPressed: AppThemes.toggleTheme,
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: "Sign Out",
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            );
          }
        },
      ),
    ],
  );
}
