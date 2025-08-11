
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PerformanceLogScreen extends StatefulWidget {
  const PerformanceLogScreen({super.key});

  @override
  State<PerformanceLogScreen> createState() => _PerformanceLogScreenState();
}

class _PerformanceLogScreenState extends State<PerformanceLogScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _logDate;
  bool _isLoading = false;
  DateTime? _logdate;
  String? _filterLogType;
  TextEditingController _FilterController = TextEditingController();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _activityController.addListener(() => setState(() {}));
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _activityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _activityController.text.trim().isNotEmpty && _logDate != null;

  void _clearForm() {
    _activityController.clear();
    _notesController.clear();
    _dateController.clear();
    setState(() {
      _logDate = null;
    });
  }

  Future<void> _addLog() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter activity & date")),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    await _firestore.collection('performance_logs').add({
      'uid': uid,
      'activity': _activityController.text.trim(),
      'notes': _notesController.text.trim(),
      'date': Timestamp.fromDate(_logDate!),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);
    _clearForm();

    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Future<void> _deleteLog(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Delete Log"),
            content: const Text(
              "Are you sure you want to delete this performance log entry?",
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
      await _firestore.collection('performance_logs').doc(docId).delete();
    }
  }

  void _showAddLogSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        DateTime? modalLogDate = _logDate;
        _dateController.text =
            modalLogDate != null
                ? DateFormat('yyyy-MM-dd').format(modalLogDate)
                : '';

        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset + 20,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: modalLogDate ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setModalState(() {
                    modalLogDate = picked;
                    _dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(picked);
                  });
                  setState(() {
                    _logDate = picked;
                  });
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Performance Log",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _activityController,
                      decoration: const InputDecoration(
                        labelText: "Activity *",
                        hintText: "What did you do?",
                        prefixIcon: Icon(Icons.fitness_center),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: "Date *",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Notes (optional)",
                        hintText: "Any notes you want to add",
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _isFormValid ? _addLog : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: _isFormValid ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),
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
                                controller: _FilterController,
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
                                  _FilterController.clear();
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
                            controller: _FilterController,
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
                                  _FilterController.clear();
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

  Widget _buildLogCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final activity = data['activity'] ?? '';
    final notes = data['notes'] ?? '';
    final rawDate = data['date'];
    String dateStr = '';
    if (rawDate is Timestamp) {
      dateStr = DateFormat('MMM d, yyyy').format(rawDate.toDate());
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(
          activity,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("Date: $dateStr\nNotes: $notes"),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _deleteLog(doc.id),
          tooltip: "Delete entry",
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
        title: const Text(
          "Performance Logs",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: EdgeInsets.all(basePadding),
        child: ListView(
          children: [
            _buildFilters(),

            // CustomeSearch(filterLogType: _filterLogType, logdate: _logdate),
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

            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('performance_logs')
                      .where('uid', isEqualTo: uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show progress indicator but keep filters visible above
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

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
                        final date = (doc['date'] as Timestamp).toDate();
                        return (date.isAtSameMomentAs(startOfDay) ||
                                date.isAfter(startOfDay)) &&
                            date.isBefore(endOfDay);
                      }).toList();
                }

                if (_filterLogType != null && _filterLogType!.isNotEmpty) {
                  final search = _filterLogType!.toLowerCase();
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final activity =
                            (doc['activity'] as String).toLowerCase();
                        return activity.contains(search);
                      }).toList();
                }

                if (filteredDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text("No performance logs yet.")),
                  );
                }

                // Render filtered logs inside a Column (non-scrollable) since outer ListView handles scrolling
                return Column(
                  children:
                      filteredDocs
                          .map((doc) => _buildLogCard(context, doc))
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLogSheet(context),
        icon: const Icon(Icons.add, color: Color(0xFF1565C0)),
        label: const Text(
          "Add Log",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}
