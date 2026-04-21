import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencySelectorPage extends StatelessWidget {
  final List<_Currency> currencies = [
    _Currency(code: 'USD', icon: Icons.attach_money, color: Colors.green),        // US Dollar
    _Currency(code: 'INR', icon: Icons.currency_rupee, color: Colors.deepPurple), // Indian Rupee
    _Currency(code: 'EUR', icon: Icons.euro, color: Colors.blue),                 // Euro
    _Currency(code: 'GBP', icon: Icons.currency_pound, color: Colors.indigo),     // British Pound
    _Currency(code: 'JPY', icon: Icons.currency_yen, color: Colors.redAccent),    // Japanese Yen
    _Currency(code: 'CAD', icon: Icons.currency_exchange, color: Colors.teal),    // Canadian Dollar
    _Currency(code: 'AUD', icon: Icons.currency_exchange, color: Colors.lightBlue), // Australian Dollar
    _Currency(code: 'CNY', icon: Icons.currency_yen, color: Colors.orange),       // Chinese Yuan
    _Currency(code: 'KRW', icon: Icons.currency_yen, color: Colors.cyan),         // South Korean Won
    _Currency(code: 'BRL', icon: Icons.attach_money, color: Colors.pinkAccent),   // Brazilian Real
    _Currency(code: 'ZAR', icon: Icons.attach_money, color: Colors.grey),         // South African Rand
    _Currency(code: 'RUB', icon: Icons.currency_ruble, color: Colors.deepOrange), // Russian Ruble
    _Currency(code: 'TRY', icon: Icons.currency_lira, color: Colors.red),         // Turkish Lira
    _Currency(code: 'MXN', icon: Icons.attach_money, color: Colors.brown),        // Mexican Peso
    _Currency(code: 'SGD', icon: Icons.attach_money, color: Colors.deepPurpleAccent), // Singapore Dollar
    _Currency(code: 'HKD', icon: Icons.attach_money, color: Colors.amber),        // Hong Kong Dollar
    _Currency(code: 'AED', icon: Icons.attach_money, color: Colors.lime),         // UAE Dirham
    _Currency(code: 'CHF', icon: Icons.attach_money, color: Colors.blueGrey),     // Swiss Franc
  ];


  Future<void> _saveCurrency(String currency, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency); // Save the selected currency
    Navigator.pop(context, currency); // Return selected currency
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Currency", style: TextStyle(fontWeight: FontWeight.bold)),
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
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          return GestureDetector(
            onTap: () => _saveCurrency(currency.code, context), // Save selected currency
            child: Container(
              decoration: BoxDecoration(
                color: currency.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(currency.icon, size: 28, color: currency.color),
                  const SizedBox(height: 8),
                  Text(
                    currency.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: currency.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Currency {
  final String code;
  final IconData icon;
  final Color color;

  _Currency({required this.code, required this.icon, required this.color});
}