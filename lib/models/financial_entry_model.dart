import 'package:cloud_firestore/cloud_firestore.dart';

/// Categories for different types of expenses.
enum ExpenseCategory {
  food,
  transport,
  groceries,
  rent,
  gifts,
  medicine,
  entertainment,
  savings,
  fitness,
  others,
}

/// Categories for different types of income.
enum IncomeCategory {
  salary,
  sponsorships,
  dividend_incomes,
  social_media,
  others,
}

/// Converts an [ExpenseCategory] to its string representation.
///
/// Example:
/// ```dart
/// expenseCategoryToString(ExpenseCategory.food); // returns 'food'
/// ```
String expenseCategoryToString(ExpenseCategory category) => category.toString().split('.').last;

/// Converts a string to its corresponding [ExpenseCategory].
///
/// Throws a [StateError] if the string does not match any category.
ExpenseCategory expenseCategoryFromString(String value) => ExpenseCategory.values.firstWhere((e) => expenseCategoryToString(e) == value);

/// Converts an [IncomeCategory] to its string representation.
///
/// Example:
/// ```dart
/// incomeCategoryToString(IncomeCategory.salary); // returns 'salary'
/// ```
String incomeCategoryToString(IncomeCategory category) => category.toString().split('.').last;

/// Converts a string to its corresponding [IncomeCategory].
///
/// Throws a [StateError] if the string does not match any category.
IncomeCategory incomeCategoryFromString(String value) => IncomeCategory.values.firstWhere((e) => incomeCategoryToString(e) == value);

/// Represents a financial entry, either income or expense, for a user.
///
/// Contains all relevant information for a single financial record, including
/// type (income/expense), category, amount, date, and optional notes.
class FinancialEntry {
  /// Unique identifier for the entry (usually the Firestore document ID).
  final String id;
  /// Type of entry: 'income' or 'expense'.
  final String type;
  /// Category of the entry (stored as string, e.g., 'food', 'salary').
  final String category;
  /// Amount of the entry (positive value).
  final double amount;
  /// Date of the entry.
  final DateTime date;
  /// Optional notes for the entry.
  final String? notes;

  /// Creates a [FinancialEntry] instance.
  ///
  /// [id] is required and should be unique per entry.
  /// [type] should be either 'income' or 'expense'.
  /// [category] is a string representation of the category.
  /// [amount] is the monetary value of the entry.
  /// [date] is the date and time of the entry.
  /// [notes] is optional and can be used for additional details.
  FinancialEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
  });

  /// Converts the [FinancialEntry] to a map for Firestore storage.
  ///
  /// The returned map can be directly used with Firestore APIs.
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'notes': notes,
    };
  }

  /// Creates a [FinancialEntry] from a Firestore map.
  ///
  /// [id] is the document ID from Firestore.
  /// [map] is the data map from Firestore.
  ///
  /// Throws if required fields are missing or of the wrong type.
  factory FinancialEntry.fromMap(String id, Map<String, dynamic> map) {
    return FinancialEntry(
      id: id,
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }
}