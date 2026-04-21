import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loop/SelectCategoriesPage.dart';  // Assuming you have a SelectCategoriesPage to handle category selection

class FilterExpensePage extends StatefulWidget {
  @override
  _FilterExpensePageState createState() => _FilterExpensePageState();
}

class _FilterExpensePageState extends State<FilterExpensePage> {
  DateTimeRange? _selectedDateRange;
  Set<String> _selectedCategories = {};
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  // Method to pick the date range
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _openCategorySelection() async {
    final Set<String>? result = await Navigator.push<Set<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCategoriesPage(
          selectedCategories: _selectedCategories,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedCategories = result;
      });
    }
  }


  // Apply filters and return selected filters
  void _applyFilters() {
    final minAmount = double.tryParse(_minAmountController.text);
    final maxAmount = double.tryParse(_maxAmountController.text);

    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Minimum amount can't be greater than maximum.")),
      );
      return;
    }

    Navigator.pop(context, {
      'start': _selectedDateRange?.start,
      'end': _selectedDateRange?.end,
      'categories': _selectedCategories.isNotEmpty
          ? _selectedCategories.toList()
          : null,

      'minAmount': minAmount,
      'maxAmount': maxAmount,
    });
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedCategories.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  // Display selected categories as chips
  Widget _buildSelectedCategories() {
    // If no categories are selected, show a message
    if (_selectedCategories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding for better spacing
        child: Text(
          "Select categories",  // Placeholder message
          style: TextStyle(
            color: Colors.grey, // Light grey color for the placeholder
            fontStyle: FontStyle.italic, // Italic style for better visual cue
          ),
        ),
      );
    }



    return Wrap(
      spacing: 6, // Horizontal spacing between chips
      runSpacing: 6, // Vertical spacing between chips
      children: _selectedCategories.map((category) {
        return Chip(
          label: Text(category),
          onDeleted: () {
            setState(() {
              _selectedCategories.remove(category);
            });
          },
          deleteIcon: Icon(Icons.remove_circle_outline),  // Optional: Custom delete icon
          deleteIconColor: Colors.red,  // Optional: Custom delete icon color
          backgroundColor: Colors.blue.withOpacity(0.1),  // Optional: Custom chip background color
        );
      }).toList(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Filter Expenses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Date Range Filter
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).cardColor,
              title: Text("Date Range"),
              subtitle: Text(
                _selectedDateRange == null
                    ? "Select date range"
                    : "${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDateRange,
            ),
            const SizedBox(height: 20),
            // Categories Filter
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).cardColor,
              title: Text(
                "Categories",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: _buildSelectedCategories(),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _openCategorySelection,
            ),
            const SizedBox(height: 20),
            // Minimum Amount Input
            TextFormField(
              controller: _minAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Minimum Amount",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Maximum Amount Input
            TextFormField(
              controller: _maxAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Maximum Amount",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Apply Filters Button
            ElevatedButton.icon(
              icon: Icon(Icons.filter_alt),
              label: Text("Apply Filters"),
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
