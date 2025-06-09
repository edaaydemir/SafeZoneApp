import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  String? get displayName => _auth.currentUser?.displayName;
  String? get email => _auth.currentUser?.email;

  Future<Map<String, dynamic>?> fetchUserData() async {
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String avatar,
  }) async {
    final fullName = '$firstName $lastName';

    await currentUser?.updateDisplayName(fullName);
    await currentUser?.reload();

    await _firestore.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'displayName': fullName,
      'avatar': avatar,
    }, SetOptions(merge: true));
  }

  Future<void> signUpWithEmail({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final userCredential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final uid = userCredential.user!.uid;
  final fullName = '$firstName $lastName';

  await userCredential.user!.updateDisplayName(fullName);
  await userCredential.user!.reload();

  await firestore.collection('users').doc(uid).set({
    'firstName': firstName,
    'lastName': lastName,
    'displayName': fullName,
    'avatar': '',
  });
}

}
