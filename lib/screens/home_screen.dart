import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 💾 SAVE
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = transactions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList("tx", data);
  }

  // 📥 LOAD
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("tx");

    if (data != null) {
      setState(() {
        transactions = data
            .map((e) => TransactionModel.fromJson(jsonDecode(e)))
            .toList();
      });
    }
  }

  // 📊 CALCULATIONS
  double get balance {
    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      t.isIncome ? income += t.amount : expense += t.amount;
    }
    return income - expense;
  }

  double get income =>
      transactions.where((t) => t.isIncome).fold(0, (a, b) => a + b.amount);

  double get expense =>
      transactions.where((t) => !t.isIncome).fold(0, (a, b) => a + b.amount);

  // ➕ ADD / EDIT SHEET
  void showTransactionSheet({TransactionModel? editTx}) {
    String title = editTx?.title ?? "";
    String amount = editTx?.amount.toString() ?? "";
    String note = editTx?.note ?? "";
    bool isIncome = editTx?.isIncome ?? true;
    DateTime selectedDate = editTx?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
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

                  const SizedBox(height: 10),

                  TextField(
                    decoration: const InputDecoration(labelText: "Title"),
                    onChanged: (v) => title = v,
                    controller: TextEditingController(text: title),
                  ),

                  TextField(
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => amount = v,
                    controller: TextEditingController(text: amount),
                  ),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Account / Note",
                    ),
                    onChanged: (v) => note = v,
                    controller: TextEditingController(text: note),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Date: ${selectedDate.toString().split(' ')[0]}"),
                      const Spacer(),
                      TextButton(
                        child: const Text("Pick Date"),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setStateModal(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  SwitchListTile(
                    title: const Text("Income"),
                    value: isIncome,
                    onChanged: (v) => setStateModal(() => isIncome = v),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (title.isEmpty || amount.isEmpty) return;

                        setState(() {
                          if (editTx == null) {
                            transactions.add(
                              TransactionModel(
                                id: DateTime.now().toString(),
                                sheetId: 'default-sheet',
                                title: title,
                                amount: double.tryParse(amount) ?? 0,
                                date: selectedDate,
                                note: note,
                                isIncome: isIncome,
                              ),
                            );
                          } else {
                            editTx.title = title;
                            editTx.amount = double.tryParse(amount) ?? 0;
                            editTx.note = note;
                            editTx.date = selectedDate;
                            editTx.isIncome = isIncome;
                          }
                        });

                        saveData();
                        Navigator.pop(context);
                      },
                      child: Text(editTx == null ? "Add" : "Update"),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ❌ DELETE
  void deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
    saveData();
  }

  // 💳 BALANCE CARD
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            "₹ ${balance.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 MINI CARDS
  Widget _buildMiniCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _miniCard("Income", income, Colors.green),
          const SizedBox(width: 10),
          _miniCard("Expense", expense, Colors.red),
        ],
      ),
    );
  }

  Widget _miniCard(String title, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(
              "₹${value.toStringAsFixed(0)}",
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 155, 172, 208),

      appBar: AppBar(
        title: const Text("Personal Wallet"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionSheet(),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          _buildBalanceCard(),
          _buildMiniCards(),
          const SizedBox(height: 10),

          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions yet"))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, i) {
                      final tx = transactions[i];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          onTap: () => showTransactionSheet(editTx: tx),

                          leading: Icon(
                            tx.isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),

                          title: Text(tx.title),
                          subtitle: Text(
                            "${tx.note} • ${tx.date.toString().split(' ')[0]}",
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "₹${tx.amount}",
                                style: TextStyle(
                                  color: tx.isIncome
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteTransaction(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
