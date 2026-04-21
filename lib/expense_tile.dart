import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd • hh:mm a').format(expense.date);
    final amountPrefix = expense.isCredit ? '+' : '-';
    final amountColor = expense.isCredit ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          "${expense.category} • $formattedDate",
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Text(
          "$amountPrefix \$${expense.amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
