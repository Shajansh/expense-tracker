import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool isWeekly = true;

  Map<String, double> getWeeklyData(List<TransactionModel> transactions) {
    final data = {
      "Mon": 0.0,
      "Tue": 0.0,
      "Wed": 0.0,
      "Thu": 0.0,
      "Fri": 0.0,
      "Sat": 0.0,
      "Sun": 0.0,
    };

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var tx in transactions) {
      if (!tx.isIncome &&
          tx.date.isAfter(startOfWeek) &&
          tx.date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        final day = data.keys.elementAt(tx.date.weekday - 1);
        data[day] = data[day]! + tx.amount;
      }
    }
    return data;
  }

  Map<String, double> getMonthlyData(List<TransactionModel> transactions) {
    final data = {
      "Jan": 0.0,
      "Feb": 0.0,
      "Mar": 0.0,
      "Apr": 0.0,
      "May": 0.0,
      "Jun": 0.0,
      "Jul": 0.0,
      "Aug": 0.0,
      "Sep": 0.0,
      "Oct": 0.0,
      "Nov": 0.0,
      "Dec": 0.0,
    };

    for (var tx in transactions) {
      if (!tx.isIncome) {
        final month = data.keys.elementAt(tx.date.month - 1);
        data[month] = data[month]! + tx.amount;
      }
    }
    return data;
  }

  Map<TransactionCategory, double> getCategoryBreakdown(
    List<TransactionModel> transactions,
  ) {
    final data = <TransactionCategory, double>{};
    for (var tx in transactions) {
      if (!tx.isIncome) {
        data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
      }
    }
    return data;
  }

  double getTotalExpense(List<TransactionModel> transactions) =>
      transactions.where((t) => !t.isIncome).fold(0, (a, b) => a + b.amount);

  double getTotalIncome(List<TransactionModel> transactions) =>
      transactions.where((t) => t.isIncome).fold(0, (a, b) => a + b.amount);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics"), elevation: 0),
      body: Consumer2<TransactionProvider, UserProvider>(
        builder: (context, transactionProvider, userProvider, _) {
          final transactions = transactionProvider.transactions;
          final currencySymbol = userProvider.getCurrencySymbol();

          return transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 80,
                        color: isDarkMode
                            ? AppColors.textHint
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No data available",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add transactions to see analytics",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                "Income",
                                getTotalIncome(transactions),
                                AppColors.success,
                                currencySymbol,
                                isDarkMode,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                "Expense",
                                getTotalExpense(transactions),
                                AppColors.error,
                                currencySymbol,
                                isDarkMode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Category Breakdown
                        Text(
                          "Spending by Category",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.cardBg : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _buildCategoryBreakdown(
                            getCategoryBreakdown(transactions),
                            currencySymbol,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Trend Toggle
                        Text(
                          "Spending Trend",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilterChip(
                                selected: isWeekly,
                                onSelected: (value) =>
                                    setState(() => isWeekly = true),
                                label: const Text("Weekly"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilterChip(
                                selected: !isWeekly,
                                onSelected: (value) =>
                                    setState(() => isWeekly = false),
                                label: const Text("Monthly"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTrendChart(
                          isWeekly
                              ? getWeeklyData(transactions)
                              : getMonthlyData(transactions),
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _summaryCard(
    String title,
    double amount,
    Color color,
    String currency,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    Map<TransactionCategory, double> data,
    String currency,
  ) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No expenses by category",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final sortedData = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedData.map((entry) {
        final categoryInfo = CategoryHelper.getCategoryInfo(entry.key);
        final percentage =
            (entry.value / data.values.fold(0.0, (a, b) => a + b) * 100);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryInfo.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(categoryInfo.label)),
                  Text(
                    '$currency ${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(categoryInfo.color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart(Map<String, double> data, bool isDarkMode) {
    final maxValue = data.values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.entries.map((entry) {
                final percentage = maxValue > 0 ? entry.value / maxValue : 0;

                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                        child: FractionallySizedBox(
                          heightFactor: percentage.toDouble(),
                          alignment: Alignment.bottomCenter,
                          child: Container(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
