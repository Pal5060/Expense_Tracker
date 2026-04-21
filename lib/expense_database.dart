import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  // Lazy initialization for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  // Initialize the database with the required file path
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increased version number for future updates
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Create the expenses table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isCredit INTEGER NOT NULL,
        userId TEXT NOT NULL,
        currency TEXT DEFAULT 'INR' -- Default currency set to INR
      )
    ''');
  }

  // Handle database upgrades (added logic to ensure proper column addition for upgrades)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      var columnCheck = await db.rawQuery('PRAGMA table_info(expenses)');
      bool columnExists = columnCheck.any((col) => col['name'] == 'currency');

      if (!columnExists) {
        await db.execute("ALTER TABLE expenses ADD COLUMN currency TEXT DEFAULT 'INR'");
      }
    }
  }

  // Insert a new expense into the database
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    try {
      String currency = await _getSavedCurrency(); // Fetch selected currency from SharedPreferences
      final updatedExpense = expense.copyWith(currency: currency); // Create a new expense object with updated currency

      print('Inserting expense: ${updatedExpense.toMap()}');
      return await db.insert(
        'expenses',
        updatedExpense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('❌ Error inserting expense: $e');
      rethrow;
    }
  }

  // Get all expenses for a specific user
  Future<List<Expense>> getExpensesForUser(String userId) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'expenses',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return result.map((json) => Expense.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error fetching user expenses: $e');
      return [];
    }
  }

  // Get all expenses from the database
  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    try {
      final result = await db.query('expenses', orderBy: 'date DESC');
      return result.map((json) => Expense.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error fetching all expenses: $e');
      return [];
    }
  }

  // Get expenses filtered by currency and user ID
  Future<List<Expense>> getExpensesByCurrency(String userId, String currency) async {
    final db = await instance.database;
    try {
      final result = await db.query(
        'expenses',
        where: 'userId = ? AND currency = ?',
        whereArgs: [userId, currency],
        orderBy: 'date DESC',
      );
      return result.map((json) => Expense.fromMap(json)).toList();
    } catch (e) {
      print('❌ Error fetching expenses by currency: $e');
      return [];
    }
  }

  // Delete an expense by its ID
  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    try {
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting expense: $e');
      rethrow;
    }
  }

  // Update an existing expense
  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    try {
      return await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      print('❌ Error updating expense: $e');
      rethrow;
    }
  }

  // Close the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Helper method to get the saved currency from SharedPreferences
  Future<String> _getSavedCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency') ?? 'USD'; // Default to INR if no currency is selected
  }
}
