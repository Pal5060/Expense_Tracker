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

class CategoryPickerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Category",style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.pop(context, cat),
            child: Container(
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, size: 28, color: cat.color),
                  const SizedBox(height: 8),
                  Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
