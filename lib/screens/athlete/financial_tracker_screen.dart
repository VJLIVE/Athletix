import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/financial_entry_model.dart';
import '../../services/firestore_service.dart';
import '../../components/financial_chart.dart';

class FinancialTrackerPage extends StatefulWidget {
  const FinancialTrackerPage({super.key});

  @override
  State<FinancialTrackerPage> createState() => _FinancialTrackerPageState();
}

class _FinancialTrackerPageState extends State<FinancialTrackerPage>
    with TickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  ViewType _selectedViewType = ViewType.monthly; // default view
  final _formKey = GlobalKey<FormState>();
  String _type = 'income';
  String _category = '';
  ExpenseCategory? _selectedExpenseCategory;
  IncomeCategory? _selectedIncomeCategory;
  double _amount = 0;
  String? _notes;
  DateTime _selectedDate = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _showForm = false;
  bool _showChart = false;

  DateTime? _filterStart;
  DateTime? _filterEnd;
  String? _filterCategory;

  String? _editingEntryId; // Use String? for entry ID

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final entry = FinancialEntry(
        id: _editingEntryId ?? '', // Use existing ID for update
        type: _type,
        category:
            _type == 'income'
                ? (_selectedIncomeCategory != null
                    ? incomeCategoryToString(_selectedIncomeCategory!)
                    : '')
                : (_selectedExpenseCategory != null
                    ? expenseCategoryToString(_selectedExpenseCategory!)
                    : ''),
        amount: _amount,
        date: _selectedDate,
        notes: _notes,
      );
      if (_editingEntryId != null) {
        _firestoreService.updateFinancialEntry(entry);
      } else {
        _firestoreService.addFinancialEntry(entry);
      }
      _formKey.currentState!.reset();
      setState(() {
        _showForm = false;
        _editingEntryId = null; // Reset editing ID after submission
      });
    }
  }

  void _toggleForm() {
    setState(() => _showForm = !_showForm);
  }

  void _toggleChart() {
    setState(() => _showChart = !_showChart);
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _filterStart = picked.start;
        _filterEnd = picked.end;
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
                              onPressed: _selectDateRange,
                              tooltip: 'Select Date Range',
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 8),
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
                                    (val) => setState(
                                      () =>
                                          _filterCategory =
                                              val.trim().toLowerCase(),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (_filterStart != null ||
                            (_filterCategory != null &&
                                _filterCategory!.isNotEmpty))
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              tooltip: 'Clear Filters',
                              splashRadius: 20,
                              onPressed:
                                  () => setState(() {
                                    _filterStart = null;
                                    _filterEnd = null;
                                    _filterCategory = null;
                                  }),
                            ),
                          ),
                      ],
                    )
                    : Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _selectDateRange,
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
                                (val) => setState(
                                  () =>
                                      _filterCategory =
                                          val.trim().toLowerCase(),
                                ),
                          ),
                        ),
                        if (_filterStart != null ||
                            (_filterCategory != null &&
                                _filterCategory!.isNotEmpty))
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
                              onPressed:
                                  () => setState(() {
                                    _filterStart = null;
                                    _filterEnd = null;
                                    _filterCategory = null;
                                  }),
                            ),
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildViewTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            ViewType.values.map((view) {
              final label = view.name[0].toUpperCase() + view.name.substring(1);
              final isSelected = _selectedViewType == view;

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedViewType = view),
                selectedColor: Colors.green[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green[800] : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final basePadding = MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        resizeToAvoidBottomInset: false, // Use default for smooth keyboard transitions
        backgroundColor: isDark ? const Color(0xFF181A20) : Colors.white,
        appBar: AppBar(
          title: Text(
            "💰 Financial Tracker",
            style: GoogleFonts.nunito(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 70,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Stack(
          children: [
            // Graph FAB (bottom-left)
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton(
                heroTag: 'graph_fab',
                onPressed: _toggleChart,
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.bar_chart_rounded),
                tooltip: 'View Graph',
              ),
            ),

            // Add/Close FAB (bottom-right)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'add_fab',
                onPressed: _toggleForm,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _showForm ? Icons.close : Icons.add,
                    key: ValueKey(_showForm),
                  ),
                ),
                tooltip: _showForm ? 'Close Form' : 'Add Entry',
              ),
            ),
          ],
        ),

        body: Padding(
          padding: EdgeInsets.all(basePadding),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: !_showForm
                    ? const SizedBox.shrink()
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF23262F) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: _type,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'income',
                                        child: Text('Income'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'expense',
                                        child: Text('Expense'),
                                      ),
                                    ],
                                    onChanged: (val) => setState(() {
                                      _type = val!;
                                      _selectedExpenseCategory = null;
                                      _selectedIncomeCategory = null;
                                    }),
                                    borderRadius: BorderRadius.circular(14),
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                    ),
                                    dropdownColor: Colors.white,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _type == 'income'
                                        ? DropdownButtonFormField<IncomeCategory>(
                                            value: _selectedIncomeCategory,
                                            decoration: InputDecoration(
                                              labelText: 'Category',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            items: IncomeCategory.values
                                                .map((cat) => DropdownMenuItem(
                                                      value: cat,
                                                      child: Text(
                                                        incomeCategoryToString(cat)
                                                            .replaceAll(RegExp(r'([A-Z])'), ' ' r'$1')
                                                            .replaceAll('_', ' ')
                                                            .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                                                      ),
                                                    ))
                                                .toList(),
                                            onChanged: (cat) => setState(() => _selectedIncomeCategory = cat),
                                            validator: (cat) => cat == null ? 'Required' : null,
                                            borderRadius: BorderRadius.circular(14),
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                              color: Colors.blueAccent,
                                            ),
                                            dropdownColor: Colors.white,
                                          )
                                        : DropdownButtonFormField<ExpenseCategory>(
                                            value: _selectedExpenseCategory,
                                            decoration: InputDecoration(
                                              labelText: 'Category',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            items: ExpenseCategory.values
                                                .map((cat) => DropdownMenuItem(
                                                      value: cat,
                                                      child: Text(
                                                        expenseCategoryToString(cat)
                                                            .replaceAll(RegExp(r'([A-Z])'), ' ' r'$1')
                                                            .replaceAll('_', ' ')
                                                            .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                                                      ),
                                                    ))
                                                .toList(),
                                            onChanged: (cat) => setState(() => _selectedExpenseCategory = cat),
                                            validator: (cat) => cat == null ? 'Required' : null,
                                            borderRadius: BorderRadius.circular(14),
                                            style: GoogleFonts.nunito(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                              color: Colors.blueAccent,
                                            ),
                                            dropdownColor: Colors.white,
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (val) => _amount = double.parse(val!),
                                validator: (val) => val!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Notes (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onSaved: (val) => _notes = val,
                              ),
                              const SizedBox(height: 18),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: ElevatedButton.icon(
                                  onPressed: _submitEntry,
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                  ),
                                  label: Text(
                                    _editingEntryId != null ? "Update Entry" : "Add Entry",
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    textStyle: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              _buildFilters(),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  return StreamBuilder<List<FinancialEntry>>(
                    stream: _firestoreService.getFinancialEntries(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      List<FinancialEntry> entries = snapshot.data!;
                      if (_filterStart != null && _filterEnd != null) {
                        entries = entries.where((e) {
                          return e.date.isAfter(
                                _filterStart!.subtract(const Duration(days: 1)),
                              ) &&
                              e.date.isBefore(
                                _filterEnd!.add(const Duration(days: 1)),
                              );
                        }).toList();
                      }
                      if (_filterCategory != null && _filterCategory!.isNotEmpty) {
                        entries = entries.where((e) => e.category.toLowerCase().contains(_filterCategory!)).toList();
                      }
                      final now = DateTime.now();
                      final thisMonth = entries.where((e) => e.date.month == now.month && e.date.year == now.year);
                      final income = thisMonth.where((e) => e.type == 'income').fold(0.0, (sum, e) => sum + e.amount);
                      final expense = thisMonth.where((e) => e.type == 'expense').fold(0.0, (sum, e) => sum + e.amount);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF23262F) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.only(bottom: 18),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 24,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Income",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "₹${income.toStringAsFixed(2)}",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      "Expense",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "₹${expense.toStringAsFixed(2)}",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      "Balance",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "₹${(income - expense).toStringAsFixed(2)}",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (_showChart) ...[
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: FinancialChart(
                                key: ValueKey(_showChart),
                                entries: entries,
                                viewType: _selectedViewType,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            "Transactions",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final e = entries[index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF23262F) : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: e.type == 'income' ? Colors.green[100] : Colors.red[100],
                                    child: Icon(
                                      e.type == 'income' ? Icons.call_received : Icons.call_made,
                                      color: e.type == 'income' ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(
                                    "${e.type == 'income' ? (() {
                                          try {
                                            return incomeCategoryToString(IncomeCategory.values.firstWhere((cat) => incomeCategoryToString(cat) == e.category)).replaceAll(RegExp(r'([A-Z])'), ' '
                                            r'$1').replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
                                          } catch (_) {
                                            return e.category;
                                          }
                                        })() : (() {
                                          try {
                                            return expenseCategoryToString(ExpenseCategory.values.firstWhere((cat) => expenseCategoryToString(cat) == e.category)).replaceAll(RegExp(r'([A-Z])'), ' '
                                            r'$1').replaceAll('_', ' ').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
                                          } catch (_) {
                                            return e.category;
                                          }
                                        })()} - ₹${e.amount.toStringAsFixed(2)}",
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(DateFormat.yMMMd().format(e.date)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        splashRadius: 22,
                                        onPressed: () {
                                          setState(() {
                                            _showForm = true;
                                            _type = e.type;
                                            if (e.type == 'income') {
                                              _selectedIncomeCategory = IncomeCategory.values.firstWhere(
                                                (cat) => incomeCategoryToString(cat) == e.category,
                                                orElse: () => IncomeCategory.others,
                                              );
                                              _selectedExpenseCategory = null;
                                            } else {
                                              _selectedExpenseCategory = ExpenseCategory.values.firstWhere(
                                                (cat) => expenseCategoryToString(cat) == e.category,
                                                orElse: () => ExpenseCategory.others,
                                              );
                                              _selectedIncomeCategory = null;
                                            }
                                            _amount = e.amount;
                                            _notes = e.notes;
                                            _selectedDate = e.date;
                                            _category = e.category;
                                            _editingEntryId = e.id;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        splashRadius: 22,
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Transaction'),
                                              content: const Text('Are you sure you want to delete this transaction?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _firestoreService.deleteFinancialEntry(e.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
