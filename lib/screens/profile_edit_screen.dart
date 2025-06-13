import 'package:flutter/material.dart';
import 'package:safe_zone/common/avatar_data.dart';
import 'package:safe_zone/services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final userService = UserService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? selectedAvatarKey;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await userService.fetchUserData();
    if (data != null) {
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      selectedAvatarKey = data['avatar'];
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    if (userService.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in!')));
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      await userService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        avatar: selectedAvatarKey ?? '',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarKeys = avatarMap.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'First Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: _firstNameController),
            const SizedBox(height: 12),
            const Text(
              'Last Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: _lastNameController),
            const SizedBox(height: 20),
            const Text(
              'Choose an Avatar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: avatarKeys.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final key = avatarKeys[index];
                final emoji = avatarMap[key]!;
                final isSelected = selectedAvatarKey == key;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatarKey = key;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.deepPurple.shade100
                              : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
