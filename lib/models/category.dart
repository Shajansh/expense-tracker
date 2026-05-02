import 'package:flutter/material.dart';

enum TransactionCategory {
  food,
  transport,
  shopping,
  entertainment,
  health,
  utilities,
  salary,
  investment,
  gift,
  education,
  personal,
  other,
}

class CategoryInfo {
  final TransactionCategory category;
  final String label;
  final IconData icon;
  final Color color;

  CategoryInfo({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class CategoryHelper {
  static CategoryInfo getCategoryInfo(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return CategoryInfo(
          category: TransactionCategory.food,
          label: 'Food & Dining',
          icon: Icons.restaurant,
          color: const Color(0xFFFF6B6B),
        );
      case TransactionCategory.transport:
        return CategoryInfo(
          category: TransactionCategory.transport,
          label: 'Transport',
          icon: Icons.directions_car,
          color: const Color(0xFF4ECDC4),
        );
      case TransactionCategory.shopping:
        return CategoryInfo(
          category: TransactionCategory.shopping,
          label: 'Shopping',
          icon: Icons.shopping_bag,
          color: const Color(0xFFFFA07A),
        );
      case TransactionCategory.entertainment:
        return CategoryInfo(
          category: TransactionCategory.entertainment,
          label: 'Entertainment',
          icon: Icons.movie,
          color: const Color(0xFF95E1D3),
        );
      case TransactionCategory.health:
        return CategoryInfo(
          category: TransactionCategory.health,
          label: 'Health & Medical',
          icon: Icons.health_and_safety,
          color: const Color(0xFFF38181),
        );
      case TransactionCategory.utilities:
        return CategoryInfo(
          category: TransactionCategory.utilities,
          label: 'Utilities',
          icon: Icons.electric_meter,
          color: const Color(0xFF55B4D4),
        );
      case TransactionCategory.salary:
        return CategoryInfo(
          category: TransactionCategory.salary,
          label: 'Salary',
          icon: Icons.attach_money,
          color: const Color(0xFF10B981),
        );
      case TransactionCategory.investment:
        return CategoryInfo(
          category: TransactionCategory.investment,
          label: 'Investment',
          icon: Icons.trending_up,
          color: const Color(0xFF6366F1),
        );
      case TransactionCategory.gift:
        return CategoryInfo(
          category: TransactionCategory.gift,
          label: 'Gift',
          icon: Icons.card_giftcard,
          color: const Color(0xFFF59E0B),
        );
      case TransactionCategory.education:
        return CategoryInfo(
          category: TransactionCategory.education,
          label: 'Education',
          icon: Icons.school,
          color: const Color(0xFF8B5CF6),
        );
      case TransactionCategory.personal:
        return CategoryInfo(
          category: TransactionCategory.personal,
          label: 'Personal Care',
          icon: Icons.person,
          color: const Color(0xFFEC4899),
        );
      case TransactionCategory.other:
        return CategoryInfo(
          category: TransactionCategory.other,
          label: 'Other',
          icon: Icons.category,
          color: const Color(0xFF6B7280),
        );
    }
  }

  static TransactionCategory getCategoryFromString(String value) {
    try {
      return TransactionCategory.values.firstWhere(
        (e) => e.toString() == 'TransactionCategory.$value',
      );
    } catch (e) {
      return TransactionCategory.other;
    }
  }
}
