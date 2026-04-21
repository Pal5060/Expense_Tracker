class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isCredit;
  final String userId;
  final String currency;

  // Constructor
  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isCredit,
    required this.userId,
    this.currency = 'USD',
  })  : assert(title.isNotEmpty, 'Title cannot be empty'),
        assert(amount > 0, 'Amount should be greater than zero'),
        assert(category.isNotEmpty, 'Category cannot be empty');

  // Convert Expense object to a Map (for saving into database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isCredit': isCredit ? 1 : 0,
      'userId': userId,
      'currency': currency,
    };
  }

  // Create Expense object from a Map (for reading from database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] != null ? map['id'] as int : null,
      title: map['title'] as String,
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'] as double,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      isCredit: map['isCredit'] == 1,
      userId: map['userId'] as String,
      currency: map['currency'] != null ? map['currency'] as String : 'USD',
    );
  }

  // Create a copy of the object with some fields updated
  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isCredit,
    String? userId,
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isCredit: isCredit ?? this.isCredit,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
    );
  }

  // String representation for easier debugging
  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, category: $category, date: $date, isCredit: $isCredit, userId: $userId, currency: $currency)';
  }
}
