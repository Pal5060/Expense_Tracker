import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'expense_database.dart';
import 'expense_category.dart';
import 'add_expense_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewAllExpensesPage extends StatefulWidget {
  final List<Expense> expenses;

  const ViewAllExpensesPage({Key? key, required this.expenses}) : super(key: key);

  @override
  State<ViewAllExpensesPage> createState() => _ViewAllExpensesPageState();
}

class _ViewAllExpensesPageState extends State<ViewAllExpensesPage> {
  late List<Expense> _expenses;
  bool _modified = false;
  bool _isCurrencyVisible = true;  // Flag to control currency visibility
  String _selectedCurrency = 'INR'; // Default currency

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    _loadCurrencySetting();
  }

  // Load the currency setting from SharedPreferences
  Future<void> _loadCurrencySetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? 'INR'; // Default to INR if no setting is found
    });
  }

  // Helper function to get the currency symbol
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
      default: return '₹';  // Default currency symbol
    }
  }

  // Method to fetch the category for an expense
  ExpenseCategory _getCategory(String name) {
    return expenseCategories.firstWhere(
          (cat) => cat.name == name,
      orElse: () => ExpenseCategory(name: name, icon: Icons.help, color: Colors.grey),
    );
  }

  // Method to delete an expense
  Future<void> _deleteExpense(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Delete Expense",
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ExpenseDatabase.instance.deleteExpense(id);
      setState(() {
        _expenses.removeWhere((e) => e.id == id);
        _modified = true;
      });
    }
  }

  // Method to edit an expense
  Future<void> _editExpense(Expense expense) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpensePage(existingExpense: expense),
      ),
    );
    if (updated == true) {
      final newList = await ExpenseDatabase.instance.getAllExpenses();
      setState(() {
        _expenses = newList;
        _modified = true;
        _isCurrencyVisible = !_isCurrencyVisible; // Toggle currency visibility
      });
    }
  }

  @override
  void dispose() {
    Navigator.pop(context, _modified);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _modified);
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black87 : Colors.grey[100],
        appBar: AppBar(
          title: Text("All Expense", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 4,
          backgroundColor: theme.primaryColor,  // AppBar color based on theme
          foregroundColor: theme.iconTheme.color,  // AppBar icon color based on theme
          actions: [],
        ),
        body: _expenses.isEmpty
            ? Center(
          child: Text(
            "No expenses found.",
            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey.shade600),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _expenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final expense = _expenses[index];
            final category = _getCategory(expense.category);

            return InkWell(
              onTap: () => _editExpense(expense),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: category.color.withOpacity(0.2),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 14, color: isDarkMode ? Colors.white70 : Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                expense.date.toLocal().toString().split('.')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            expense.category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _isCurrencyVisible
                              ? '${getCurrencySymbol(_selectedCurrency)}${expense.amount.toStringAsFixed(2)}'
                              : '${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: expense.isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _deleteExpense(expense.id!),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
