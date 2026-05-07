import 'package:expense_tracker/models/category.dart';

class TransactionModel {
  String id;
  String title;
  double amount;
  DateTime date;
  String note;
  bool isIncome;
  TransactionCategory category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.note,
    required this.isIncome,
    this.category = TransactionCategory.other,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "amount": amount,
    "date": date.toIso8601String(),
    "note": note,
    "isIncome": isIncome,
    "category": category.toString().split('.').last,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json["id"],
      title: json["title"],
      amount: json["amount"],
      date: DateTime.parse(json["date"]),
      note: json["note"] ?? "",
      isIncome: json["isIncome"],
      category: json["category"] != null
          ? CategoryHelper.getCategoryFromString(json["category"])
          : TransactionCategory.other,
    );
  }
}
