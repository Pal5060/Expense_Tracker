import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loop/CurrencySelectorPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_all_expenses_page.dart';
import 'expense_model.dart';
import 'expense_database.dart';
import 'add_expense_page.dart';
import 'expense_chart.dart';
import 'settings_page.dart';
import 'filter_expense_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];

  double _totalCredit = 0;
  double _totalDebit = 0;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  double? _minAmount;
  double? _maxAmount;
  String? _username;

  String _currencyCode = 'USD';
  String _currencySymbol = '\$';

  final Map<String, String> _currencySymbols = {
    'USD': '\$', 'INR': '₹', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
    'CAD': 'C\$', 'AUD': 'A\$', 'CNY': '¥', 'KRW': '₩', 'BRL': 'R\$',
    'ZAR': 'R', 'RUB': '₽', 'TRY': '₺', 'MXN': '\$', 'SGD': 'S\$',
    'HKD': 'HK\$', 'AED': 'د.إ', 'CHF': 'CHF',
  };

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadUserInfo();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final selected = prefs.getString('currency') ?? 'USD';
    setState(() {
      _currencyCode = selected;
      _currencySymbol = _currencySymbols[selected] ?? selected;
    });
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _username = doc.data()?['username'] ?? "No Name";
    });
  }

  Future<void> _loadExpenses() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final expenses =
    await ExpenseDatabase.instance.getExpensesForUser(currentUser.uid);
    setState(() {
      _expenses = expenses ?? [];
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredExpenses = _expenses.where((e) {
        final dateMatch = (_startDate == null || _endDate == null) ||
            (e.date != null &&
                e.date!.isAfter(_startDate!.subtract(Duration(days: 1))) &&
                e.date!.isBefore(_endDate!.add(Duration(days: 1))));

        final categoryMatch = _selectedCategory == null || e.category == _selectedCategory;

        final amountMatch = (_minAmount == null || (e.amount ?? 0) >= _minAmount!) &&
            (_maxAmount == null || (e.amount ?? 0) <= _maxAmount!);

        return dateMatch && categoryMatch && amountMatch;
      }).toList();

      _updateTotals();
    });
  }

  void _updateTotals() {
    _totalCredit = _filteredExpenses
        .where((e) => e.isCredit)
        .fold(0, (sum, e) => sum + (e.amount ?? 0));
    _totalDebit = _filteredExpenses
        .where((e) => !e.isCredit)
        .fold(0, (sum, e) => sum + (e.amount ?? 0));
  }

  Future<void> _navigateToAddPage() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpensePage()))
        .then((_) => _loadExpenses());
  }

  Future<void> _navigateToFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FilterExpensePage()),
    );

    if (result != null) {
      setState(() {
        if (result == 'reset') {
          _startDate = null;
          _endDate = null;
          _selectedCategory = null;
          _minAmount = null;
          _maxAmount = null;
        } else if (result is Map) {
          _startDate = result['start'];
          _endDate = result['end'];
          _selectedCategory = result['category'];
          _minAmount = result['minAmount'];
          _maxAmount = result['maxAmount'];
        }
        _applyFilters();
      });
    }
  }


  Widget _buildSummaryCard() {
    final balance = _totalCredit - _totalDebit;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Balance Summary",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryTile("Credit", _totalCredit, Colors.tealAccent),
              _summaryTile("Debit", _totalDebit, Colors.orangeAccent),
              _summaryTile("Balance", balance,
                  balance >= 0 ? Colors.lightGreenAccent : Colors.pinkAccent),
            ],
          ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                  "From: ${DateFormat.yMMMd().format(_startDate!)} To: ${DateFormat.yMMMd().format(_endDate!)}",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),

          if (_selectedCategory != null && _selectedCategory!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Category: $_selectedCategory',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),


          if (_minAmount != null || _maxAmount != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Amount: $_currencySymbol${_minAmount?.toStringAsFixed(0) ?? '0'} - $_currencySymbol${_maxAmount?.toStringAsFixed(0) ?? '∞'}",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
        SizedBox(height: 6),
        Text("$_currencySymbol${amount.toStringAsFixed(2)}",
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExpenseList() {
    final theme = Theme.of(context);

    if (_filteredExpenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 80,
                color: theme.primaryColor.withOpacity(0.4),
              ),
              SizedBox(height: 24),

              Text(
                "No Transactions Yet!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 12),

              Text(
                "Tap the + button below to add your first transaction",
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredExpenses.length,
      itemBuilder: (_, index) {
        final expense = _filteredExpenses[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Credit/Debit icon
                CircleAvatar(
                  backgroundColor: expense.isCredit
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Icon(
                    expense.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    color: expense.isCredit ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(width: 16), // Spacing between the icon and text

                // Expense details (title, category, date)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title ?? 'No Title',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.85),
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                          ),
                          SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().format(expense.date ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        expense.category ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent, // Category color
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount and currency display
                Text(
                  "$_currencySymbol${expense.amount?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: expense.isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          color: theme.primaryColor,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: theme.primaryColorDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_circle, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(_username ?? "No Name",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Currency: $_currencyCode ($_currencySymbol)",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              _drawerTile(Icons.home, "Home", () => Navigator.pop(context)),
              _drawerTile(Icons.pie_chart, "Chart", () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseChart(expenses: _expenses),
                    )).then((_) => _loadExpenses());
              }),
              _drawerTile(Icons.attach_money, "Change Currency", () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CurrencySelectorPage()),
                );
                if (selected != null) {
                  await _loadCurrency();
                }
              }),
              _drawerTile(Icons.filter_alt_outlined, "Filter Expenses",
                  _navigateToFilterPage),
              _drawerTile(Icons.settings, "Settings", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsPage()))
                    .then((_) => _loadExpenses());
              }),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Transactions",
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () async {
                    final modified = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewAllExpensesPage(expenses: _expenses),
                      ),
                    );

                    if (modified == true) {
                      _loadExpenses();
                    }
                  },
                  child: Text("View All"),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(child: _buildExpenseList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: Icon(Icons.add),
        backgroundColor: Colors.grey,
      ),
    );
  }
}
