import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/models/place_marker.dart';
import 'package:safe_zone/services/user_service.dart';

class MarkerService {
  final _db = FirebaseFirestore.instance;
  final _userService = UserService();

  Future<void> addMarker({
    required LatLng position,
    required String title,
    required String? description,
    required bool isSafe,
  }) async {
    final uid = _userService.uid;
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
    if (uid == null || isGuest) return;

    final userName = _userService.displayName ?? "Anonymous";

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
    final uid = _userService.uid;
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
    await _db.collection('markers').doc(docId).update({
      'title': newTitle,
      'description': newDescription,
      'isSafe': isSafe,
    });
  }

  Future<List<PlaceMarker>> getAllMarkers() async {
    final snapshot = await _db.collection('markers').get();
    return snapshot.docs
        .map((doc) => PlaceMarker.fromMap(doc.data(), doc.id))
        .toList();
  }
}
