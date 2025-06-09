import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_zone/screens/places_screen.dart';
import 'package:safe_zone/widgets/common_app_bar.dart';
import 'package:safe_zone/models/place_marker.dart';
import 'package:safe_zone/services/marker_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MarkerService _markerService = MarkerService();
  List<PlaceMarker> _markers = [];

  LatLng? _selectedMarkerPosition;
  String? _selectedMarkerTitle;
  String? _selectedMarkerDescription;
  DateTime? _selectedMarkerTimestamp;

  LatLng? _userLocation;
  bool _filterNearby = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadUserMarkers();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadUserMarkers() async {
    final markers = await _markerService.getAllMarkers();
    setState(() {
      _markers = markers;
    });
  }

  List<PlaceMarker> get _filteredMarkers {
    if (!_filterNearby || _userLocation == null) return _markers;
    final Distance distance = Distance();
    return _markers.where((marker) {
      final km = distance.as(
        LengthUnit.Kilometer,
        _userLocation!,
        marker.position,
      );
      return km <= 5.0;
    }).toList();
  }

  void _addMarkerWithTitle(LatLng position) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark this place'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter place name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Optional description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await _showSafetyChoice(
                  position,
                  titleController.text,
                  descController.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSafetyChoice(
    LatLng position,
    String title,
    String? description,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Is this place safe?'),
        actions: [
          TextButton(
            onPressed: () async {
              await _markerService.addMarker(
                position: position,
                title: title,
                description: description,
                isSafe: true,
              );
              await _loadUserMarkers();
              Navigator.of(context).pop();
            },
            child: const Text('Safe (Green)'),
          ),
          TextButton(
            onPressed: () async {
              await _markerService.addMarker(
                position: position,
                title: title,
                description: description,
                isSafe: false,
              );
              await _loadUserMarkers();
              Navigator.of(context).pop();
            },
            child: const Text('Unsafe (Red)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _userLocation ?? LatLng(39.7667, 30.5256);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final userMarkers = _markers
        .where((m) => m.userId == currentUid)
        .map((m) => {
              'position': m.position,
              'title': m.title,
              'isSafe': m.isSafe,
              'description': m.description,
              'timestamp': m.timestamp.toIso8601String(),
              'docId': m.docId,
              'userId': m.userId,
            })
        .toList();

    return Scaffold(
      appBar: buildCommonAppBar(
        context,
        title: 'SafeZone Map',
        extraActions: [
          IconButton(
            icon: Icon(_filterNearby ? Icons.location_on : Icons.location_off),
            tooltip: 'Toggle Nearby Filter',
            onPressed: () => setState(() => _filterNearby = !_filterNearby),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlacesScreen(
                    markers: userMarkers,
                    userName: FirebaseAuth.instance.currentUser?.displayName ?? 'Guest',
                  ),
                ),
              );
              if (result == true) {
                await _loadUserMarkers();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: center,
              zoom: 13.0,
              onLongPress: (tapPos, latlng) => _addMarkerWithTitle(latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.safezone',
              ),
              MarkerLayer(
                markers: [
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    ),
                  ..._filteredMarkers.map((marker) {
                    return Marker(
                      point: marker.position,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMarkerPosition = marker.position;
                            _selectedMarkerTitle = marker.title;
                            _selectedMarkerDescription =
                                "${marker.description ?? ''}\nAdded by: ${marker.userName}";
                            _selectedMarkerTimestamp = marker.timestamp;
                          });
                        },
                        child: Icon(
                          Icons.location_on,
                          color: marker.isSafe ? Colors.green : Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
          if (_selectedMarkerPosition != null && _selectedMarkerTitle != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                color: Colors.white,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📍 $_selectedMarkerTitle',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${_selectedMarkerPosition!.latitude.toStringAsFixed(4)}, Lng: ${_selectedMarkerPosition!.longitude.toStringAsFixed(4)}',
                          ),
                          if (_selectedMarkerDescription?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '✏️ $_selectedMarkerDescription',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          if (_selectedMarkerTimestamp != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '🕒 ${DateFormat('dd MMM yyyy – HH:mm').format(_selectedMarkerTimestamp!)}',
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedMarkerPosition = null;
                            _selectedMarkerTitle = null;
                            _selectedMarkerDescription = null;
                            _selectedMarkerTimestamp = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
