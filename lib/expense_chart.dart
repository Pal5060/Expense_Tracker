import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseChart extends StatefulWidget {
  final List<Expense> expenses;

  const ExpenseChart({Key? key, required this.expenses}) : super(key: key);

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  late List<Expense> filteredExpenses;
  int? touchedIndex;
  String currency = 'USD';

  @override
  void initState() {
    super.initState();
    filteredExpenses = widget.expenses;
    _getSavedCurrency();
  }

  @override
  void didUpdateWidget(covariant ExpenseChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expenses != widget.expenses) {
      setState(() {
        filteredExpenses = widget.expenses; // Update when parent changes
      });
    }
  }

  Future<void> _getSavedCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currency = prefs.getString('currency') ?? 'USD';
    });
  }

  String getCurrencySymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'INR': return '₹';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'KRW': return '₩';
      case 'RUB': return '₽';
      case 'TRY': return '₺';
      case 'MXN': return 'M\$';
      case 'SGD': return 'S\$';
      case 'HKD': return 'H\$';
      case 'CAD': return 'C\$';
      case 'AUD': return 'A\$';
      case 'BRL': return 'R\$';
      case 'ZAR': return 'R';
      case 'AED': return 'د.إ';
      case 'CHF': return 'CHF';
      default: return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryData = _processExpenseData();
    final totalAmount = categoryData.values.fold(0.0, (sum, e) => sum + e);
    final currencySymbol = getCurrencySymbol(currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.iconTheme.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredExpenses.isEmpty
            ? Center(child: Text("No expenses to display.", style: theme.textTheme.bodyLarge))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(theme, currencySymbol, totalAmount, categoryData),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Category Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPieChart(theme, categoryData, totalAmount)),
            const SizedBox(height: 16),
            _buildLegend(categoryData, totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, String currencySymbol, double totalAmount, Map<String, double> categoryData) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Total Transactions',
              style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            Text(
              '$currencySymbol${totalAmount.toStringAsFixed(2)}',  // This is where the negative sign will be shown correctly
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
            ),
            const SizedBox(height: 8),
            Text(
              '${filteredExpenses.length} transactions across ${categoryData.length} categories',
              style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme, Map<String, double> categoryData, double totalAmount) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions || pieTouchResponse?.touchedSection == null) {
                        touchedIndex = -1;
                      } else {
                        touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
                      }
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildSections(categoryData, totalAmount),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
            _buildCenterLabel(theme, categoryData, totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterLabel(ThemeData theme, Map<String, double> categoryData, double totalAmount) {
    final currencySymbol = getCurrencySymbol(currency);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          touchedIndex != null && touchedIndex! >= 0
              ? categoryData.keys.toList()[touchedIndex!]
              : "Total",
          style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          touchedIndex != null && touchedIndex! >= 0
              ? '$currencySymbol${categoryData.values.toList()[touchedIndex!].toStringAsFixed(2)}'
              : '$currencySymbol${totalAmount.toStringAsFixed(2)}', // Ensures the negative sign appears here too
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
        ),
      ],
    );
  }

  Map<String, double> _processExpenseData() {
    final Map<String, double> categoryTotals = {};

    for (var expense in filteredExpenses) {
      final key = expense.isCredit ? '💰 ${expense.category}' : '💸 ${expense.category}';
      categoryTotals.update(key, (value) => value + (expense.amount ?? 0.0), ifAbsent: () => expense.amount ?? 0.0);
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  List<PieChartSectionData> _buildSections(Map<String, double> categoryData, double totalAmount) {
    final colorList = _getCategoryColors(categoryData.length);

    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 65.0 : 60.0;
      final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colorList[index],
        value: entry.value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, double> categoryData, double totalAmount) {
    final colorList = _getCategoryColors(categoryData.length);

    return SizedBox(
      height: 140,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            final isTouched = index == touchedIndex;
            final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);

            return GestureDetector(
              onTap: () => setState(() => touchedIndex = index),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorList[index],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key} ($percentage%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                      color: isTouched ? Colors.greenAccent : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Color> _getCategoryColors(int count) {
    const List<Color> palette = [
      Color(0xFF4285F4),
      Color(0xFF34A853),
      Color(0xFFFBBC05),
      Color(0xFFEA4335),
      Color(0xFF673AB7),
      Color(0xFFFF9800),
      Color(0xFF009688),
      Color(0xFFE91E63),
      Color(0xFF795548),
      Color(0xFF9E9E9E),
    ];

    return List.generate(count, (index) => palette[index % palette.length]);
  }
}
