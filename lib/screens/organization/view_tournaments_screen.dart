// At the top of your file
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class ViewTournamentsScreen extends StatefulWidget {
  const ViewTournamentsScreen({super.key});

  @override
  State<ViewTournamentsScreen> createState() => _ViewTournamentsScreenState();
}

class _ViewTournamentsScreenState extends State<ViewTournamentsScreen> {
  final List<String> levels = ['District', 'State', 'National', 'International'];
  final List<String> sports = ['Football', 'Cricket', 'Basketball', 'Tennis']; // Example sports

  List<String> selectedLevels = [];
  DateTime? selectedDate;
  String? selectedLocation;
  String? selectedSport;
  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('View Tournaments'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...selectedLevels.map((level) => Chip(
                                label: Text(level),
                                onDeleted: () => setState(() => selectedLevels.remove(level)),
                              )),
                          if (selectedSport != null)
                            Chip(
                              label: Text(selectedSport!),
                              onDeleted: () => setState(() => selectedSport = null),
                            ),
                          if (selectedLocation != null)
                            Chip(
                              label: Text(selectedLocation!),
                              onDeleted: () => setState(() => selectedLocation = null),
                            ),
                          if (selectedDate != null)
                            Chip(
                              label: Text(DateFormat('yyyy-MM-dd').format(selectedDate!)),
                              onDeleted: () => setState(() => selectedDate = null),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => setState(() => showFilters = !showFilters),
                        icon: Icon(showFilters ? Icons.close : Icons.filter_list),
                        label: Text(showFilters ? "Hide Filters" : "Show Filters"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: showFilters ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  firstChild: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Filter Tournaments",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Sport",
                              filled: true,
                              fillColor: Color(0xFFF7F8FA),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                            ),
                            value: selectedSport,
                            hint: const Text("Select Sport"),
                            items: sports.map((sport) {
                              return DropdownMenuItem(value: sport, child: Text(sport));
                            }).toList(),
                            onChanged: (val) => setState(() => selectedSport = val),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Location",
                              filled: true,
                              fillColor: Color(0xFFF7F8FA),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) => setState(() => selectedLocation = val),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: levels.map((level) {
                              final isSelected = selectedLevels.contains(level);
                              return FilterChip(
                                label: Text(level),
                                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                                selected: isSelected,
                                selectedColor: Colors.blue,
                                backgroundColor: const Color(0xFFEFEFEF),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedLevels.add(level);
                                    } else {
                                      selectedLevels.remove(level);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2022),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() => selectedDate = picked);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(selectedDate == null ? 'Pick Date' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedLevels.clear();
                                    selectedLocation = null;
                                    selectedDate = null;
                                    selectedSport = null;
                                  });
                                },
                                icon: const Icon(Icons.refresh, color: Colors.red),
                                tooltip: "Clear Filters",
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tournaments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final matchLevel = selectedLevels.isEmpty || selectedLevels.contains(data['level']);
                  final matchSport = selectedSport == null || data['sport'] == selectedSport;
                  final matchLocation = selectedLocation == null || data['location']['address'].toString().toLowerCase().contains(selectedLocation!.toLowerCase());
                  final matchDate = selectedDate == null || (data['date'] as Timestamp).toDate().toString().startsWith(DateFormat('yyyy-MM-dd').format(selectedDate!));

                  return matchLevel && matchSport && matchLocation && matchDate;
                }).toList();

                if (docs.isEmpty) return const Center(child: Text('No tournaments found.'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final location = data['location'];

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 6,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.emoji_events, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text("${data['level']}", style: const TextStyle(color: Colors.black54))
                            ]),
                            Row(children: [
                              Icon(Icons.sports, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text("${data['sport'] ?? ''}", style: const TextStyle(color: Colors.black54))
                            ]),
                            Row(children: [
                              Icon(Icons.date_range, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate()), style: const TextStyle(color: Colors.black54))
                            ]),
                            Row(children: [
                              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text("${data['time'] ?? ''}", style: const TextStyle(color: Colors.black54))
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(child: Text("${location['address'] ?? ''}", style: const TextStyle(color: Colors.black54))),
                            ]),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(location['lat'], location['lng']),
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId(data['name']),
                                      position: LatLng(location['lat'], location['lng']),
                                    ),
                                  },
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  liteModeEnabled: true,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
