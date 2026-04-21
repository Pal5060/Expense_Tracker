import 'package:flutter/material.dart';
import 'expense_category.dart';

final categories = [
  // Essentials
  ExpenseCategory(name: "Food", icon: Icons.restaurant, color: Colors.orange),
  ExpenseCategory(name: "Transport", icon: Icons.directions_car, color: Colors.blue),
  ExpenseCategory(name: "Shopping", icon: Icons.shopping_bag, color: Colors.purple),
  ExpenseCategory(name: "Bills", icon: Icons.receipt, color: Colors.teal),
  ExpenseCategory(name: "Health", icon: Icons.health_and_safety, color: Colors.green),
  ExpenseCategory(name: "Education", icon: Icons.school, color: Colors.brown),
  ExpenseCategory(name: "Home", icon: Icons.home, color: Colors.lime),

  // Lifestyle
  ExpenseCategory(name: "Entertainment", icon: Icons.movie, color: Colors.red),
  ExpenseCategory(name: "Dining Out", icon: Icons.local_dining, color: Colors.deepOrange),
  ExpenseCategory(name: "Subscriptions", icon: Icons.subscriptions, color: Colors.pinkAccent),
  ExpenseCategory(name: "Pets", icon: Icons.pets, color: Colors.cyan),
  ExpenseCategory(name: "Beauty", icon: Icons.spa, color: Colors.pink),
  ExpenseCategory(name: "Fitness", icon: Icons.fitness_center, color: Colors.deepPurple),

  // Financial
  ExpenseCategory(name: "Bank", icon: Icons.account_balance, color: Colors.lightBlue),
  ExpenseCategory(name: "Investment", icon: Icons.trending_up, color: Colors.amber),
  ExpenseCategory(name: "Loan", icon: Icons.money_off, color: Colors.deepOrange),
  ExpenseCategory(name: "Savings", icon: Icons.savings, color: Colors.blueGrey),
  ExpenseCategory(name: "Insurance", icon: Icons.verified_user, color: Colors.indigo),

  // Family & Personal
  ExpenseCategory(name: "Kids", icon: Icons.child_friendly, color: Colors.lightGreen),
  ExpenseCategory(name: "Gift", icon: Icons.card_giftcard, color: Colors.pink),
  ExpenseCategory(name: "Travel", icon: Icons.flight, color: Colors.indigo),
  ExpenseCategory(name: "Clothing", icon: Icons.checkroom, color: Colors.purpleAccent),
  ExpenseCategory(name: "Events", icon: Icons.event, color: Colors.cyanAccent),

  // Work & Business
  ExpenseCategory(name: "Office", icon: Icons.work, color: Colors.grey),
  ExpenseCategory(name: "Freelance", icon: Icons.laptop_mac, color: Colors.orangeAccent),
  ExpenseCategory(name: "Business", icon: Icons.business_center, color: Colors.deepPurpleAccent),

  // Giving & Social
  ExpenseCategory(name: "Charity", icon: Icons.volunteer_activism, color: Colors.redAccent),
  ExpenseCategory(name: "Donations", icon: Icons.handshake, color: Colors.greenAccent),
  ExpenseCategory(name: "Party", icon: Icons.celebration, color: Colors.amberAccent),

  // Miscellaneous
  ExpenseCategory(name: "Other", icon: Icons.more_horiz, color: Colors.grey),
  ExpenseCategory(name: "Uncategorized", icon: Icons.help_outline, color: Colors.cyan),
];

class SelectCategoriesPage extends StatefulWidget {
  final Set<String> selectedCategories;

  const SelectCategoriesPage({Key? key, required this.selectedCategories}) : super(key: key);

  @override
  _SelectCategoriesPageState createState() => _SelectCategoriesPageState();
}

class _SelectCategoriesPageState extends State<SelectCategoriesPage> {
  late Set<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Set.from(widget.selectedCategories);
  }

  void _toggleCategory(String name) {
    setState(() {
      if (_tempSelected.contains(name)) {
        _tempSelected.remove(name);
      } else {
        _tempSelected.add(name);
      }
    });
  }

  Widget _buildCategoryBox(ExpenseCategory cat) {
    final selected = _tempSelected.contains(cat.name);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware selection highlight
    final selectionColor = isDarkTheme ? Colors.tealAccent : Colors.deepPurple;

    final borderColor = selected
        ? selectionColor
        : (isDarkTheme ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2));

    final backgroundColor = selected
        ? selectionColor.withOpacity(0.15)
        : Colors.transparent;

    final iconBackgroundColor = selected
        ? selectionColor.withOpacity(0.3)
        : cat.color.withOpacity(0.15);

    final iconColor = selected ? selectionColor : cat.color;

    final textColor = selected
        ? selectionColor
        : (isDarkTheme ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: () => _toggleCategory(cat.name),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBackgroundColor,
              ),
              child: Icon(
                cat.icon,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Categories"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _tempSelected),
            tooltip: "Apply",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return _buildCategoryBox(cat); // Reuse the category box builder
          },
        ),
      ),
    );
  }
}
