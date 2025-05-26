import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? selectedAvatarKey;

  final Map<String, String> avatarMap = {
    'avatar_astronaut': '👩‍🚀',
    'avatar_artist': '🧑‍🎨',
    'avatar_scientist': '👨‍🔬',
    'avatar_programmer': '👩‍💻',
    'avatar_wizard': '🧙‍♀️',
    'avatar_vampire': '🧛‍♂️',
    'avatar_elf': '🧝‍♀️',
    'avatar_firefighter': '🧑‍🚒',
    'avatar_judge': '👨‍⚖️',
    'avatar_farmer': '👩‍🌾',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _firstNameController.text = data['firstName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      selectedAvatarKey = data['avatar']; // artık avatar ID geliyor
      setState(() {});
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("HATA: Kullanıcı null, giriş yapılmamış!");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in!')));
      return;
    }

    final uid = user.uid;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = "$firstName $lastName";

    print("=== PROFİL KAYDI BAŞLIYOR ===");
    print("UID: $uid");
    print("Ad: $firstName");
    print("Soyad: $lastName");
    print("Avatar: $selectedAvatarKey");

    try {
      // Firebase Auth'a displayName güncelle
      await user.updateDisplayName(fullName);
      await user.reload();

      // Firestore'a veri yaz
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': fullName,
        'avatar': selectedAvatarKey,
      }, SetOptions(merge: true));

      print("Firestore'a veri yazıldı ✅");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated!')));

      Navigator.pop(context);
    } catch (e) {
      print("HATA: $e");
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
      body: Padding(
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
            Expanded(
              child: GridView.builder(
                itemCount: avatarKeys.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
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
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
