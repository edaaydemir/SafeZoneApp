import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_zone/common/avatar_data.dart';
import 'package:safe_zone/screens/welcome_screen.dart';
import 'package:safe_zone/common/theme.dart';
import 'package:safe_zone/screens/profile_edit_screen.dart';
import 'package:safe_zone/screens/signup_screen.dart';

PreferredSizeWidget buildCommonAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? extraActions,
}) {
  return AppBar(
    title: Text(title),
    actions: [
      FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          String avatarEmoji = '👤';
          if (snapshot.hasData) {
            final avatarId = snapshot.data?.get('avatar');
            if (avatarId != null && avatarMap.containsKey(avatarId)) {
              avatarEmoji = avatarMap[avatarId]!;
            }
          }
          return IconButton(
            icon: Text(
              avatarEmoji,
              style: const TextStyle(fontSize: 22),
            ),
            tooltip: 'Edit Profile',
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              final isGuest = user?.isAnonymous ?? true;

              if (isGuest) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Profile unavailable"),
                    content: const Text(
                      "You're currently using the app as a guest.\n\nTo access your profile and personalize your experience, please sign up.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add),
                        label: const Text("Sign Up"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ).then((_) => (context as Element).markNeedsBuild());
            },
          );
        },
      ),
      ...?extraActions,
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