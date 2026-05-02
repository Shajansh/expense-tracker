import 'package:uuid/uuid.dart';

class ExpenseSheet {
  final String id;
  final String name;
  final DateTime createdDate;
  final String description;

  ExpenseSheet({
    String? id,
    required this.name,
    DateTime? createdDate,
    this.description = '',
  }) : id = id ?? const Uuid().v4(),
       createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdDate': createdDate.toIso8601String(),
    'description': description,
  };

  factory ExpenseSheet.fromJson(Map<String, dynamic> json) {
    return ExpenseSheet(
      id: json['id'],
      name: json['name'],
      createdDate: DateTime.parse(json['createdDate']),
      description: json['description'] ?? '',
    );
  }

  ExpenseSheet copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
    String? description,
  }) {
    return ExpenseSheet(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
    );
  }
}
