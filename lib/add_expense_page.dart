import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_model.dart';
import 'expense_database.dart';
import 'expense_category.dart';
import 'category_picker_page.dart';

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
    default: return '₹';
  }
}

class AddExpensePage extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpensePage({Key? key, this.existingExpense}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDateTime;
  late bool _isCredit;
  ExpenseCategory? _selectedCategory;
  String _currencySymbol = '₹'; // Default

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();

    if (widget.existingExpense != null) {
      final e = widget.existingExpense!;
      _title = e.title;
      _amount = e.amount;
      _selectedDateTime = e.date;
      _isCredit = e.isCredit;
      _selectedCategory = expenseCategories.firstWhere(
            (cat) => cat.name == e.category,
        orElse: () => ExpenseCategory(name: e.category, icon: Icons.help, color: Colors.grey),
      );
    } else {
      _title = '';
      _amount = 0.0;
      _selectedDateTime = DateTime.now();
      _isCredit = false;
    }
  }

  Future<void> _loadCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency') ?? 'USD';
    setState(() {
      _currencySymbol = getCurrencySymbol(code);
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in.")),
      );
      return;
    }

    final newExpense = Expense(
      id: widget.existingExpense?.id,
      title: _title,
      amount: _amount,
      category: _selectedCategory?.name ?? 'Other',
      date: _selectedDateTime,
      isCredit: _isCredit,
      userId: currentUser.uid,
    );

    try {
      if (widget.existingExpense != null) {
        await ExpenseDatabase.instance.updateExpense(newExpense);
      } else {
        await ExpenseDatabase.instance.insertExpense(newExpense);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Widget _buildInputCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleType(isCredit: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: !_isCredit ? Colors.red.shade300 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_upward, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Debit", style: TextStyle(color:Colors.purple,fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Credit Button
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleType(isCredit: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isCredit ? Colors.green.shade300 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_downward, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Credit", style: TextStyle(color:Colors.purple,fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

// Helper method to toggle between Credit/Debit type
  void _toggleType({required bool isCredit}) {
    setState(() {
      _isCredit = isCredit;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.existingExpense != null ? 'Edit Expense' : 'Add Expense', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputCard(
                child: TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                  onSaved: (value) => _title = value!.trim(),
                ),
              ),
              _buildInputCard(
                child: TextFormField(
                  initialValue: _amount > 0 ? _amount.toString() : '',
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          _currencySymbol,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                    border: InputBorder.none,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                  onSaved: (value) => _amount = double.tryParse(value ?? '') ?? 0.0,
                ),
              ),

              _buildInputCard(
                child: InkWell(
                  onTap: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoryPickerPage()),
                    );
                    if (selected != null && selected is ExpenseCategory) {
                      setState(() => _selectedCategory = selected);
                    }
                  },
                  child: Row(
                    children: [
                      Icon(_selectedCategory?.icon ?? Icons.category, color: _selectedCategory?.color ?? Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedCategory?.name ?? 'Select Category',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.edit, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              _buildInputCard(
                child: InkWell(
                  onTap: _pickDateTime,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(DateFormat('yyyy-MM-dd – kk:mm').format(_selectedDateTime)),
                      ),
                      const Icon(Icons.edit, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              _buildTypeSelector(),
              // Adding appropriate spacing and aligning the button
              const SizedBox(height: 24), // Spacing before the button

// ElevatedButton widget
              ElevatedButton.icon(
                onPressed: _saveExpense, // Action when button is pressed
                icon: const Icon(Icons.save_rounded, size: 20), // Icon for the button
                label: Text(widget.existingExpense != null ? 'Update' : 'Save'), // Button label text
                style: ElevatedButton.styleFrom(
                  elevation: 4, // Shadow effect
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.tealAccent[700] // Color for dark mode
                      : Colors.indigo, // Color for light mode
                  foregroundColor: Colors.white, // Text color
                  minimumSize: const Size(double.infinity, 48), // Ensures the button takes full width
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Rounded corners
                  padding: const EdgeInsets.symmetric(vertical: 14), // Adjust padding for a better look
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
