import 'package:expense_tracker/models/category.dart';

class TransactionModel {
  String id;
  String sheetId;
  String title;
  double amount;
  DateTime date;
  String note;
  bool isIncome;
  TransactionCategory category;

  TransactionModel({
    required this.id,
    required this.sheetId,
    required this.title,
    required this.amount,
    required this.date,
    required this.note,
    required this.isIncome,
    this.category = TransactionCategory.other,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "sheetId": sheetId,
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
      sheetId: json["sheetId"] ?? "",
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

  TransactionModel copyWith({
    String? id,
    String? sheetId,
    String? title,
    double? amount,
    DateTime? date,
    String? note,
    bool? isIncome,
    TransactionCategory? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      sheetId: sheetId ?? this.sheetId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
    );
  }
}
