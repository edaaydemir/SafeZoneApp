// safe_zone/screens/places_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/models/place_marker.dart';
import 'package:safe_zone/services/marker_service.dart';

class PlacesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> markers;
  final String userName;

  const PlacesScreen({super.key, required this.markers, required this.userName});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  final MarkerService _markerService = MarkerService();

  void _deleteMarker(String docId) async {
    await _markerService.deleteMarker(docId);
    setState(() {
      widget.markers.removeWhere((m) => m['docId'] == docId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marker deleted successfully!')),
    );
    Navigator.of(context).pop(true);
  }

  void _editMarker(Map<String, dynamic> marker) async {
    final titleController = TextEditingController(text: marker['title']);
    final descriptionController = TextEditingController(text: marker['description']);
    final docId = marker['docId'];
    bool isSafe = marker['isSafe'] ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Marker'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Place Title'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Is Safe: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: isSafe,
                      onChanged: (val) => setState(() => isSafe = val),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _markerService.updateMarker(
                    docId: docId,
                    newTitle: titleController.text,
                    newDescription: descriptionController.text,
                    isSafe: isSafe,
                  );
                  setState(() {
                    marker['title'] = titleController.text;
                    marker['description'] = descriptionController.text;
                    marker['isSafe'] = isSafe;
                  });
                  Navigator.of(context).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      setState(() {});
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marker updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeMarkers = widget.markers.where((m) => m['isSafe'] == true).toList();
    final unsafeMarkers = widget.markers.where((m) => m['isSafe'] == false).toList();

    Widget buildMarkerCard(Map<String, dynamic> marker, bool isSafe) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(
            Icons.location_on,
            color: isSafe ? Colors.green : Colors.red,
          ),
          title: Text(marker['title'] ?? ''),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (marker['description'] != null && marker['description'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '✏️ ${marker['description']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              Text(
                '📍 Lat: ${marker['position'].latitude.toStringAsFixed(4)}, Lng: ${marker['position'].longitude.toStringAsFixed(4)}',
              ),
              Text(
                '🕒 ${DateFormat('dd MMM yyyy – HH:mm').format(DateTime.parse(marker['timestamp']))}',
              ),
            ],
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _editMarker(marker),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteMarker(marker['docId']),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName}'s SafeZone List"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (safeMarkers.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Safe Places", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              ),
            ...safeMarkers.map((marker) => buildMarkerCard(marker, true)),
            if (unsafeMarkers.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Unsafe Places", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
              ),
            ...unsafeMarkers.map((marker) => buildMarkerCard(marker, false)),
          ],
        ),
      ),
    );
  }
}