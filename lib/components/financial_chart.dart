import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/financial_entry_model.dart';

enum ViewType { daily, weekly, monthly, yearly }

class FinancialChart extends StatefulWidget {
  final List<FinancialEntry> entries;

  const FinancialChart({
    super.key,
    required this.entries, required ViewType viewType,
  });

  @override
  State<FinancialChart> createState() => _FinancialChartState();
}

class _FinancialChartState extends State<FinancialChart> {
  ViewType _viewType = ViewType.daily;

  final Map<ViewType, String> _viewLabels = {
    ViewType.daily: 'Daily',
    ViewType.weekly: 'Weekly',
    ViewType.monthly: 'Monthly',
    ViewType.yearly: 'Yearly',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pastelGreen = const Color(0xFF00D09C);
    final pastelBlue = const Color(0xFFB2EBF2);
    final background = const Color(0xFFE0F7F4);
    final lightShadow = Colors.white;
    final darkShadow = Colors.grey.shade300;

    final incomeMap = <int, double>{};
    final expenseMap = <int, double>{};
    double totalIncome = 0;
    double totalExpense = 0;

    void aggregate(int key, FinancialEntry entry) {
      if (entry.type == 'income') {
        incomeMap[key] = (incomeMap[key] ?? 0) + entry.amount;
        totalIncome += entry.amount;
      } else {
        expenseMap[key] = (expenseMap[key] ?? 0) + entry.amount;
        totalExpense += entry.amount;
      }
    }

    for (var entry in widget.entries) {
      switch (_viewType) {
        case ViewType.daily:
          aggregate(entry.date.weekday, entry);
          break;
        case ViewType.weekly:
          final week = ((entry.date.day - 1) ~/ 7) + 1;
          aggregate(week, entry);
          break;
        case ViewType.monthly:
          aggregate(entry.date.month, entry);
          break;
        case ViewType.yearly:
          aggregate(entry.date.year, entry);
          break;
      }
    }

    List<int> spots;
    switch (_viewType) {
      case ViewType.daily:
        spots = List.generate(7, (i) => i + 1);
        break;
      case ViewType.weekly:
        spots = List.generate(5, (i) => i + 1);
        break;
      case ViewType.monthly:
        spots = List.generate(12, (i) => i + 1);
        break;
      case ViewType.yearly:
        final currentYear = DateTime.now().year;
        spots = List.generate(currentYear - 2020 + 1, (i) => 2020 + i);
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleBar(pastelGreen),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: lightShadow,
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: darkShadow,
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "Income & Expenses",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    _iconCircle(Icons.search, pastelGreen),
                    const SizedBox(width: 8),
                    _iconCircle(Icons.calendar_today_rounded, pastelBlue),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _getLabel(value.toInt()),
                                style: GoogleFonts.poppins(
                                    fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        drawHorizontalLine: true,
                        horizontalInterval: 2000,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: spots.map((x) {
                        return BarChartGroupData(
                          x: x,
                          barRods: [
                            BarChartRodData(
                              toY: incomeMap[x] ?? 0,
                              width: 10,
                              borderRadius: BorderRadius.circular(6),
                              color: pastelGreen,
                            ),
                            BarChartRodData(
                              toY: expenseMap[x] ?? 0,
                              width: 10,
                              borderRadius: BorderRadius.circular(6),
                              color: pastelBlue,
                            ),
                          ],
                          barsSpace: 6,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryCard("Income", totalIncome, pastelGreen),
              _summaryCard("Expense", totalExpense, pastelBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: bgColor, size: 18),
    );
  }

  Widget _buildToggleBar(Color activeColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ViewType.values.map((type) {
          final isSelected = type == _viewType;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                _viewLabels[type]!,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[800],
                ),
              ),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (_) {
                setState(() => _viewType = type);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(int value) {
    switch (_viewType) {
      case ViewType.daily:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return (value >= 1 && value <= 7) ? days[value - 1] : '';
      case ViewType.weekly:
        return "W${value}";
      case ViewType.monthly:
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return (value >= 1 && value <= 12) ? months[value - 1] : '';
      case ViewType.yearly:
        return value.toString();
    }
  }

  Widget _summaryCard(String label, double amount, Color color) {
    return Column(
      children: [
        Icon(
          label == "Income" ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
        ),
        Text(label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
