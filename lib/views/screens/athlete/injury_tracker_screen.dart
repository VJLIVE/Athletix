import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Screen for tracking athlete injuries and adding new injury records.
class InjuryTrackerScreen extends StatefulWidget {
  /// Creates an [InjuryTrackerScreen].
  const InjuryTrackerScreen({super.key});

  @override
  State<InjuryTrackerScreen> createState() => _InjuryTrackerScreenState();
}

/// State for [InjuryTrackerScreen] that manages form and Firestore logic.
class _InjuryTrackerScreenState extends State<InjuryTrackerScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _injuryController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController(); // Date controller

  DateTime? _injuryDate;
  bool _isLoading = false;

  DateTime? _logdate;
  String? _filterLogType;

  /// Returns true if the form is valid (injury and date are provided).
  bool get _isFormValid =>
      _injuryController.text.trim().isNotEmpty && _injuryDate != null;

  /// Clears all form fields and resets the injury date.
  void _clearForm() {
    _injuryController.clear();
    _notesController.clear();
    _dateController.clear();
    setState(() {
      _injuryDate = null;
    });
  }

  /// Adds a new injury record to Firestore if the form is valid.
  Future<void> _addInjury() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter injury & date")),
      );
      return;
    }
    setState(() => _isLoading = true);

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('injuries').add({
      'uid': uid,
      'description': _injuryController.text.trim(),
      'notes': _notesController.text.trim(),
      'date': _injuryDate!.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);

    _clearForm();

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteInjury(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Delete Injury"),
            content: const Text(
              "Are you sure you want to delete this injury entry?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _firestore.collection('injuries').doc(docId).delete();
    }
  }

  void _showAddInjurySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        DateTime? modalInjuryDate = _injuryDate;
        // Set initial text for date field for immediate display
        _dateController.text =
            modalInjuryDate != null
                ? DateFormat('yyyy-MM-dd').format(modalInjuryDate)
                : '';

        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset + 32,
            top: 32,
            left: 24,
            right: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: modalInjuryDate ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setModalState(() {
                    modalInjuryDate = picked;
                    _dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  });
                  setState(() => _injuryDate = picked);
                }
              }

              final isFormValid =
                  _injuryController.text.trim().isNotEmpty &&
                  modalInjuryDate != null;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Injury",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _injuryController,
                      decoration: const InputDecoration(
                        labelText: "Injury Description *",
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                        border: OutlineInputBorder(),
                        hintText: 'Describe your injury',
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: "Injury Date *",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: "Notes (optional)",
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                        hintText: 'Additional details',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _clearForm();
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1.3,
                              ),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isFormValid
                                    ? () async {
                                      await _addInjury();
                                    }
                                    : null,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color:
                                    isFormValid
                                        ? const Color(0xFF1565C0)
                                        : Colors.grey,
                                width: 1.6,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color:
                                    isFormValid
                                        ? const Color(0xFF1565C0)
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _logdate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _logdate = picked;
      });
    }
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF23262F) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                isNarrow
                    ? Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: () {
                                pickDate();
                              },
                              tooltip: 'Select Date Range',
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                // controller: _FilterController,
                                decoration: InputDecoration(
                                  hintText: 'Filter activity',
                                  prefixIcon: const Icon(
                                    Icons.filter_alt,
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDark
                                          ? const Color(0xFF23262F)
                                          : Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                onChanged:
                                    (val) => setState(() {
                                      _filterLogType = val;
                                    }),
                              ),
                            ),
                          ],
                        ),
                        if (_logdate != null ||
                            (_filterLogType != null &&
                                _filterLogType!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              tooltip: 'Clear Filters',
                              splashRadius: 20,
                              onPressed: () {
                                setState(() {
                                  _logdate = null;
                                  _filterLogType = null;
                                  //  _FilterController.clear();
                                });
                              },
                            ),
                          ),
                      ],
                    )
                    : Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () {
                            pickDate();
                          },
                          tooltip: 'Select Date Range',
                          splashRadius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Filter Category',
                              prefixIcon: const Icon(
                                Icons.filter_alt,
                                size: 20,
                              ),
                              filled: true,
                              fillColor:
                                  isDark
                                      ? const Color(0xFF23262F)
                                      : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: GoogleFonts.nunito(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            onChanged:
                                (val) => setState(() {
                                  _filterLogType = val;
                                }),
                          ),
                        ),

                        if (_logdate != null ||
                            (_filterLogType != null &&
                                _filterLogType!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              tooltip: 'Clear Filters',
                              splashRadius: 20,
                              onPressed: () {
                                setState(() {
                                  _logdate = null;
                                  _filterLogType = null;
                                  // _FilterController.clear();
                                });
                              },
                            ),
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildInjuryCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final description = data['description'] ?? '';
    final notes = data['notes'] ?? '';
    String dateStr = '';
    try {
      final date = DateTime.parse(data['date'] ?? '');
      dateStr = DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      dateStr = data['date'] ?? '';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Date: $dateStr"),
            if (notes.isNotEmpty) Text("Notes: $notes"),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _deleteInjury(doc.id),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          tooltip: "Delete Injury",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }
    final basePadding = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          "Injury Tracker",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: EdgeInsets.all(basePadding),
        child: ListView(
          children: [
            // CustomeSearch(filterLogType: _filterLogType, logdate: _logdate),
            _buildFilters(),

            if (_logdate != null ||
                (_filterLogType != null && _filterLogType!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Showing logs for ${_logdate != null ? DateFormat('MMM d, yyyy').format(_logdate!) : 'all dates'}" +
                      (_filterLogType != null && _filterLogType!.isNotEmpty
                          ? " | Filtered by: ${_filterLogType!}"
                          : ""),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('injuries')
                      .where('uid', isEqualTo: uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No injuries logged yet.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                List<QueryDocumentSnapshot> filteredDocs = docs;

                if (_logdate != null) {
                  final startOfDay = DateTime(
                    _logdate!.year,
                    _logdate!.month,
                    _logdate!.day,
                  );
                  final endOfDay = startOfDay.add(const Duration(days: 1));

                  filteredDocs =
                      docs.where((doc) {
                        final date = DateTime.parse(
                          doc['date'] as String,
                        ); // parse ISO8601 string
                        return (date.isAtSameMomentAs(startOfDay) ||
                                date.isAfter(startOfDay)) &&
                            date.isBefore(endOfDay);
                      }).toList();
                }

                // List<QueryDocumentSnapshot> filteredDocs = docs;

                // if (_logdate != null) {
                //   final startOfDay = DateTime(
                //     _logdate!.year,
                //     _logdate!.month,
                //     _logdate!.day,
                //   );
                //   final endOfDay = startOfDay.add(const Duration(days: 1));

                //   filteredDocs =
                //       docs.where((doc) {
                //         final date = (doc['date'] as Timestamp).toDate();
                //         return (date.isAtSameMomentAs(startOfDay) ||
                //                 date.isAfter(startOfDay)) &&
                //             date.isBefore(endOfDay);
                //       }).toList();
                // }

                if (_filterLogType != null && _filterLogType!.isNotEmpty) {
                  final search = _filterLogType!.toLowerCase();
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final activity =
                            (doc['description'] as String).toLowerCase();
                        return activity.contains(search);
                      }).toList();
                }

                if (filteredDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No performance logs yet.")),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder:
                      (context, index) =>
                          _buildInjuryCard(context, filteredDocs[index]),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInjurySheet(context),
        icon: const Icon(Icons.add, color: Color(0xFF1565C0)),
        label: const Text(
          "Add Injury",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1565C0), width: 1.8),
        ),
      ),
    );
  }
}
