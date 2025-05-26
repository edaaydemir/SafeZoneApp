import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../models/place_marker.dart';

class MarkerService {
  final _db = FirebaseFirestore.instance;

  Future<void> addMarker({
    required LatLng position,
    required String title,
    required String? description,
    required bool isSafe,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final doc = await _db.collection('users').doc(uid).get();
    final userName = doc.data()?['displayName'] ?? 'Anonymous';

    final newDoc = _db.collection('markers').doc();
    await newDoc.set({
      'userId': uid,
      'userName': userName,
      'title': title,
      'description': description,
      'isSafe': isSafe,
      'timestamp': DateTime.now().toIso8601String(),
      'position': {'lat': position.latitude, 'lng': position.longitude},
    });
  }

  Future<void> deleteMarker(String docId) async {
    await _db.collection('markers').doc(docId).delete();
  }

  Future<List<PlaceMarker>> getUserMarkers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot =
        await _db.collection('markers').where('userId', isEqualTo: uid).get();

    return snapshot.docs
        .map((doc) => PlaceMarker.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateMarker({
    required String docId,
    required String newTitle,
    required String newDescription,
    required bool isSafe, 
  }) async {
    await FirebaseFirestore.instance.collection('markers').doc(docId).update({
      'title': newTitle,
      'description': newDescription,
      'isSafe': isSafe, 
    });
  }
}
