import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewTournamentsScreen extends StatefulWidget {
  const ViewTournamentsScreen({super.key});

  @override
  State<ViewTournamentsScreen> createState() => _ViewTournamentsScreenState();
}

class _ViewTournamentsScreenState extends State<ViewTournamentsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Map<MarkerId, Map<String, dynamic>> markerDataMap = {};
  Map<String, dynamic>? _selectedTournament;

  /// Firestore collections
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference orgsRef = FirebaseFirestore.instance.collection(
    'organizations',
  );
  final CollectionReference tournamentsRef = FirebaseFirestore.instance
      .collection('tournaments');

  /// Logged-in org's sport
  String? organizationSport;

  @override
  void initState() {
    super.initState();
    fetchOrganizationSport();
  }

  /// Fetch the organization sport using logged-in user's organizationId
  Future<void> fetchOrganizationSport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData == null) {
      debugPrint("User data is null.");
      return;
    }

    final sport = userData['sport'];
    debugPrint("✅ Loaded sport from user document: $sport");

    if (sport != null) {
      setState(() {
        organizationSport = sport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (organizationSport == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tournaments Map')),
      body: Stack(
        children: [
          // 1. StreamBuilder only updates markers, not the whole map
          StreamBuilder<QuerySnapshot>(
            stream:
                tournamentsRef
                    .where('sport', isEqualTo: organizationSport)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(); // Don't block the map with a loader
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // Optionally clear markers if no tournaments
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_markers.isNotEmpty) {
                    setState(() {
                      _markers = {};
                      markerDataMap = {};
                    });
                  }
                });
                return const SizedBox();
              }

              final docs = snapshot.data!.docs;
              Set<Marker> updatedMarkers = {};
              Map<MarkerId, Map<String, dynamic>> updatedMarkerDataMap = {};

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final location = data['location'];
                final markerId = MarkerId(doc.id);

                updatedMarkers.add(
                  Marker(
                    markerId: markerId,
                    position: LatLng(location['lat'], location['lng']),
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(location['lat'], location['lng']),
                        ),
                      );
                      setState(() {
                        _selectedTournament = data;
                      });
                    },
                  ),
                );
                updatedMarkerDataMap[markerId] = data;
              }

              // Only update markers if changed
              if (_markers.length != updatedMarkers.length ||
                  !_markers.containsAll(updatedMarkers)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _markers = updatedMarkers;
                    markerDataMap = updatedMarkerDataMap;
                  });
                });
              }
              return const SizedBox(); // Don't block the map
            },
          ),
          // 2. GoogleMap is always present, only markers update
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629), // India
              zoom: 4,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          // 3. Tournament dialog
          if (_selectedTournament != null)
            Center(
              child: _TournamentDetailCard(
                data: _selectedTournament!,
                onClose: () => setState(() => _selectedTournament = null),
              ),
            ),
        ],
      ),
    );
  }
}

// Tournament detail card widget
class _TournamentDetailCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;

  const _TournamentDetailCard({
    required this.data,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final location = data['location'];
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.deepPurple,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.sports,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          data['sport'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.flag, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          data['level'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.teal,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format((data['date'] as Timestamp).toDate()),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          color: Colors.purple,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['time'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location['address'] ?? '',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                  onPressed: onClose,
                  tooltip: "Close",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
