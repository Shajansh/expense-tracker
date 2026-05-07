import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction.dart';
import '../models/category.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String _filterType = 'all'; // all, income, expense
  TransactionCategory? _selectedCategoryFilter;

  List<TransactionModel> get transactions => _transactions;
  String get filterType => _filterType;
  TransactionCategory? get selectedCategoryFilter => _selectedCategoryFilter;

  double get balance => _transactions.fold(
    0,
    (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount,
  );

  double get income =>
      _transactions.where((t) => t.isIncome).fold(0, (a, b) => a + b.amount);

  double get expense =>
      _transactions.where((t) => !t.isIncome).fold(0, (a, b) => a + b.amount);

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
        if (_filterType == 'income' && !t.isIncome) return false;
        if (_filterType == 'expense' && t.isIncome) return false;
        if (_selectedCategoryFilter != null &&
            t.category != _selectedCategoryFilter) {
          return false;
        }
        return true;
      }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  // Initialize
  Future<void> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList("transactions") ?? [];

      _transactions = data
          .map((e) => TransactionModel.fromJson(jsonDecode(e)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  // Save transactions
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _transactions.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList("transactions", data);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  // Update transaction
  Future<void> updateTransaction(
    String id,
    TransactionModel transaction,
  ) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  // Filter
  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setSelectedCategory(TransactionCategory? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _transactions.where((t) {
      return t.date.isAfter(startDate) && t.date.isBefore(endDate);
    }).toList();
  }

  // Get transaction by ID
  TransactionModel? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all transactions
  Future<void> clearAllTransactions() async {
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }
}
