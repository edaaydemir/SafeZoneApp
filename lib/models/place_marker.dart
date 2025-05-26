import 'package:latlong2/latlong.dart';

class PlaceMarker {
  final String docId;
  final LatLng position;
  final String title;
  final String userName;
  final bool isSafe;
  final String? description;
  final DateTime timestamp;

  PlaceMarker({
    required this.docId,
    required this.position,
    required this.title,
    required this.userName,
    required this.isSafe,
    required this.description,
    required this.timestamp,
  });

  factory PlaceMarker.fromMap(Map<String, dynamic> data, String docId) {
    return PlaceMarker(
      docId: docId,
      position: LatLng(data['position']['lat'], data['position']['lng']),
      title: data['title'],
      userName: data['userName'],
      isSafe: data['isSafe'],
      description: data['description'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() => {
        'userName': userName,
        'title': title,
        'isSafe': isSafe,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'position': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
      };
}
