import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late double amount;

  late DateTime date;

  String? merchant;

  @enumerated
  late ExpenseCategory category;

  String? imagePath;
}

enum ExpenseCategory {
  food,
  study,
  travel,
  gear,
  entertainment,
  other
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.study:
        return 'Education';
      case ExpenseCategory.travel:
        return 'Transportation';
      case ExpenseCategory.gear:
        return 'Electronics & Gear';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.other:
        return 'General / Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.study:
        return Icons.school_outlined;
      case ExpenseCategory.travel:
        return Icons.directions_car_outlined;
      case ExpenseCategory.gear:
        return Icons.devices_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.other:
        return Icons.category_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFF59E0B); // Warm Amber
      case ExpenseCategory.study:
        return const Color(0xFF3B82F6); // Royal Blue
      case ExpenseCategory.travel:
        return const Color(0xFF10B981); // Emerald Green
      case ExpenseCategory.gear:
        return const Color(0xFF8B5CF6); // Violet
      case ExpenseCategory.entertainment:
        return const Color(0xFFEC4899); // Rose Pink
      case ExpenseCategory.other:
        return const Color(0xFF64748B); // Slate
    }
  }
}
