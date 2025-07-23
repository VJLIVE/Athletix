import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddTournamentScreen extends StatefulWidget {
  const AddTournamentScreen({super.key});

  @override
  State<AddTournamentScreen> createState() => _AddTournamentScreenState();
}

class _AddTournamentScreenState extends State<AddTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String _level = 'District';
  DateTime? _date;
  TimeOfDay? _time;
  LatLng? _pickedLocation;
  String? _address;
  String? _sport;

  final List<String> _levels = [
    'District',
    'State',
    'National',
    'International',
  ];

  @override
  void initState() {
    super.initState();
    _loadSport();
  }

  Future<void> _loadSport() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _sport = doc['sport'];
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickLocation() async {
    // Check & request permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, please enable them in settings.',
          ),
        ),
      );
      return;
    }

    // Permission granted → get position
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng initial = LatLng(pos.latitude, pos.longitude);

    LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapScreen(initialLocation: initial)),
    );

    if (result != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );
      String readableAddress =
          "${placemarks.first.street ?? ''}, ${placemarks.first.locality ?? ''}";
      setState(() {
        _pickedLocation = result;
        _address = readableAddress;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _date == null ||
        _time == null ||
        _pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields!')),
      );
      return;
    }

    _formKey.currentState!.save();

    final tournament = {
      'name': _name,
      'level': _level,
      'date': Timestamp.fromDate(_date!),
      'time': _time!.format(context),
      'location': {
        'lat': _pickedLocation!.latitude,
        'lng': _pickedLocation!.longitude,
        'address': _address,
      },
      'sport': _sport,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('tournaments').add(tournament);

    // ✅ Show confirmation
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Tournament added successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );

    // ✅ Reset the form
    setState(() {
      _formKey.currentState!.reset();
      _name = null;
      _level = 'District';
      _date = null;
      _time = null;
      _pickedLocation = null;
      _address = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Tournament")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tournament Name'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _level,
                decoration: const InputDecoration(labelText: 'Level'),
                items:
                    _levels
                        .map(
                          (lvl) =>
                              DropdownMenuItem(value: lvl, child: Text(lvl)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _level = val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _date == null
                            ? 'Pick Date'
                            : _date!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _time == null ? 'Pick Time' : _time!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(
                  _pickedLocation == null
                      ? 'Pick Location'
                      : _address ?? 'Location picked',
                ),
                onPressed: _pickLocation,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Tournament'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapScreen({super.key, required this.initialLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_picked != null) Navigator.pop(context, _picked);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 17, // 👈 zoom in a bit more
        ),
        myLocationEnabled: true, // 👈 blue dot shows real-time location
        myLocationButtonEnabled:
            true, // 👈 button to center back to your location
        onTap: (latLng) {
          setState(() {
            _picked = latLng; // 👈 only set marker when tapped
          });
        },
        markers:
            _picked == null
                ? {}
                : {
                  Marker(
                    markerId: const MarkerId('picked'),
                    position: _picked!,
                  ),
                },
      ),
    );
  }
}
