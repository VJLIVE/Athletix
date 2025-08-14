import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:athletix/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  late Future<List<Tournament>> _tournaments;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;
    final localizations = AppLocalizations.of(context)!;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(localizations.locationServicesDisabled);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(localizations.locationPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(localizations.locationPermissionDeniedForever);
    }
  }

  Future<List<Tournament>> _fetchTournaments(
    AppLocalizations localizations,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final userSport = userDoc['sport'] ?? '';
    final now = Timestamp.now();

    final snapshot =
        await FirebaseFirestore.instance
            .collection('tournaments')
            .where('sport', isEqualTo: userSport)
            .where('date', isGreaterThanOrEqualTo: now)
            .orderBy('date')
            .get();

    return snapshot.docs
        .map((doc) => Tournament.fromDocument(doc, localizations))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _tournaments = _fetchTournaments(localizations);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.tournamentsTitle)),
      body: FutureBuilder<List<Tournament>>(
        future: _tournaments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('${localizations.errorPrefix}: ${snapshot.error}'),
            );
          }

          final tournaments = snapshot.data ?? [];

          final CameraPosition initialCameraPosition =
              tournaments.isNotEmpty
                  ? CameraPosition(
                    target: LatLng(
                      tournaments.first.lat,
                      tournaments.first.lng,
                    ),
                    zoom: 10,
                  )
                  : const CameraPosition(
                    target: LatLng(20.5937, 78.9629),
                    zoom: 4,
                  );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: initialCameraPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers:
                    tournaments
                        .map(
                          (tournament) => Marker(
                            markerId: MarkerId(tournament.id),
                            position: LatLng(tournament.lat, tournament.lng),
                            onTap: () {
                              _showTournamentDialog(context, tournament);
                            },
                          ),
                        )
                        .toSet(),
              ),

              if (tournaments.isEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    color: Colors.red.withOpacity(0.8),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      localizations.noTournamentsFound,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showTournamentDialog(BuildContext context, Tournament t) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              t.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoRow(localizations.tournamentLevelLabel, t.level),
                const SizedBox(height: 6),
                _buildInfoRow(localizations.sportLabel, t.sport),
                const SizedBox(height: 6),
                _buildInfoRow(localizations.dateLabel, t.dateString),
                const SizedBox(height: 6),
                _buildInfoRow(localizations.timeLabel, t.time),
                const SizedBox(height: 12),
                Text(
                  localizations.addressLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  t.address,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    localizations.closeButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

class Tournament {
  final String id;
  final String name;
  final String level;
  final String sport;
  final String dateString;
  final String time;
  final String address;
  final double lat;
  final double lng;

  Tournament({
    required this.id,
    required this.name,
    required this.level,
    required this.sport,
    required this.dateString,
    required this.time,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory Tournament.fromDocument(
    DocumentSnapshot doc,
    AppLocalizations localizations,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    final Timestamp? dateTs = data['date'];
    final String dateStr =
        dateTs != null
            ? DateFormat.yMMMd(
              localizations.localeName,
            ).format(dateTs.toDate().toLocal())
            : localizations.notAvailableAbbreviation;

    final loc = data['location'] ?? {};

    return Tournament(
      id: doc.id,
      name: data['name'] ?? localizations.notAvailableAbbreviation,
      level: data['level'] ?? localizations.notAvailableAbbreviation,
      sport: data['sport'] ?? localizations.notAvailableAbbreviation,
      dateString: dateStr,
      time: data['time'] ?? localizations.notAvailableAbbreviation,
      address: loc['address'] ?? localizations.notAvailableAbbreviation,
      lat: (loc['lat'] ?? 0).toDouble(),
      lng: (loc['lng'] ?? 0).toDouble(),
    );
  }
}
