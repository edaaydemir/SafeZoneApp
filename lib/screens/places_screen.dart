import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class PlacesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> markers;
  final String userName;

  const PlacesScreen({
    super.key,
    required this.markers,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final safeMarkers = markers.where((m) => m['isSafe'] == true).toList();
    final unsafeMarkers = markers.where((m) => m['isSafe'] == false).toList();

    return Scaffold(
      appBar: AppBar(title: Text("$userName's SafeZone List")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (safeMarkers.isNotEmpty) ...[
            const Text(
              '🟢 Safe Places',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...safeMarkers.map((marker) => _buildMarkerTile(marker, true)),
            const SizedBox(height: 16),
          ],
          if (unsafeMarkers.isNotEmpty) ...[
            const Text(
              '🔴 Unsafe Places',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...unsafeMarkers.map((marker) => _buildMarkerTile(marker, false)),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkerTile(Map<String, dynamic> marker, bool isSafe) {
    final LatLng position = marker['position'];
    final String title = marker['title'];
    final String? description = marker['description'];
    final String timestampString = marker['timestamp'];
    final DateTime timestamp = DateTime.parse(timestampString);

    return ListTile(
      leading: Icon(
        Icons.location_on,
        color: isSafe ? Colors.green : Colors.red,
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lat: ${position.latitude.toStringAsFixed(4)}, '
            'Lng: ${position.longitude.toStringAsFixed(4)}',
          ),
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📝 $description',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '🕒 ${DateFormat('dd MMM yyyy – HH:mm').format(timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
