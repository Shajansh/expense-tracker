import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/summary_card.dart';
import '../theme/app_colors.dart';

const uuid = Uuid();

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void openTransactionSheet({TransactionModel? editTx}) {
    final titleController = TextEditingController(text: editTx?.title ?? "");
    final amountController = TextEditingController(
      text: editTx?.amount.toString() ?? "",
    );
    final noteController = TextEditingController(text: editTx?.note ?? "");

    bool isIncome = editTx?.isIncome ?? false;
    DateTime date = editTx?.date ?? DateTime.now();
    TransactionCategory category =
        editTx?.category ?? TransactionCategory.other;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      editTx == null ? "Add Transaction" : "Edit Transaction",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        hintText: "Enter transaction title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: "Amount",
                        hintText: "Enter amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: "Note (Optional)",
                        hintText: "Optional note",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModal(() => isIncome = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isIncome
                                    ? AppColors.error.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isIncome
                                      ? AppColors.error
                                      : Colors.grey,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: !isIncome
                                          ? AppColors.error
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Expense",
                                      style: TextStyle(
                                        color: !isIncome
                                            ? AppColors.error
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModal(() => isIncome = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? AppColors.success.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isIncome
                                      ? AppColors.success
                                      : Colors.grey,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: isIncome
                                          ? AppColors.success
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Income",
                                      style: TextStyle(
                                        color: isIncome
                                            ? AppColors.success
                                            : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Category",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: TransactionCategory.values.length,
                        itemBuilder: (context, index) {
                          final cat = TransactionCategory.values[index];
                          final info = CategoryHelper.getCategoryInfo(cat);
                          final isSelected = category == cat;

                          return GestureDetector(
                            onTap: () => setModal(() => category = cat),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? info.color
                                          : info.color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: info.color,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      info.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : info.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      info.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setModal(() => date = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              date.toString().split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              amountController.text.isEmpty) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill all required fields",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Capture context references before async operations
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            final amount = double.parse(amountController.text);
                            final transactionProvider = context
                                .read<TransactionProvider>();

                            if (editTx == null) {
                              final newTx = TransactionModel(
                                id: const Uuid().v4(),
                                sheetId: 'default-sheet',
                                title: titleController.text,
                                amount: amount,
                                date: date,
                                note: noteController.text,
                                isIncome: isIncome,
                                category: category,
                              );
                              await transactionProvider.addTransaction(newTx);
                            } else {
                              final updatedTx = TransactionModel(
                                id: editTx.id,
                                sheetId: editTx.sheetId,
                                title: titleController.text,
                                amount: amount,
                                date: date,
                                note: noteController.text,
                                isIncome: isIncome,
                                category: category,
                              );
                              await transactionProvider.updateTransaction(
                                editTx.id,
                                updatedTx,
                              );
                            }

                            if (mounted) {
                              nav.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    editTx == null
                                        ? "Transaction added"
                                        : "Transaction updated",
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          editTx == null ? "Add Transaction" : "Update",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer2<TransactionProvider, UserProvider>(
        builder: (context, transactionProvider, userProvider, _) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final balance = transactionProvider.balance;
          final income = transactionProvider.income;
          final expense = transactionProvider.expense;
          final filtered = transactionProvider.filteredTransactions;
          final currencySymbol = userProvider.getCurrencySymbol();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Balance",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$currencySymbol${balance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: "Income",
                          amount: income,
                          icon: Icons.arrow_downward,
                          color: AppColors.success,
                          currencySymbol: currencySymbol,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: "Expense",
                          amount: expense,
                          icon: Icons.arrow_upward,
                          color: AppColors.error,
                          currencySymbol: currencySymbol,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['all', 'income', 'expense'].map((type) {
                              final isSelected =
                                  transactionProvider.filterType == type;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: FilterChip(
                                  label: Text(type.toUpperCase()),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    transactionProvider.setFilterType(type);
                                  },
                                  backgroundColor: isDarkMode
                                      ? AppColors.cardBg
                                      : Colors.white,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                              ? AppColors.textPrimary
                                              : AppColors.lightText),
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDarkMode
                                              ? AppColors.borderColor
                                              : AppColors.lightBorder),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    "Transactions (${filtered.length})",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 80,
                                  color: isDarkMode
                                      ? AppColors.textHint
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No transactions yet",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add your first transaction to get started",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final tx = filtered[index];
                            final categoryInfo = CategoryHelper.getCategoryInfo(
                              tx.category,
                            );
                            return TransactionCard(
                              title: tx.title,
                              amount: tx.amount,
                              category: tx.category.toString().split('.')[1],
                              icon: categoryInfo.icon,
                              iconColor: categoryInfo.color,
                              date: tx.date.toIso8601String().split('T')[0],
                              isIncome: tx.isIncome,
                              onTap: () {
                                openTransactionSheet(editTx: tx);
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Transaction?"),
                                    content: const Text(
                                      "This action cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          transactionProvider.deleteTransaction(
                                            tx.id,
                                          );
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Transaction deleted",
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openTransactionSheet(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
