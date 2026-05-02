import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense_sheet.dart';

class SheetService {
  static const String _sheetsKey = "expense_sheets";

  // Get all sheets
  static Future<List<ExpenseSheet>> getSheets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_sheetsKey) ?? [];
      return data.map((e) => ExpenseSheet.fromJson(jsonDecode(e))).toList();
    } catch (e) {
      return [];
    }
  }

  // Save sheets
  static Future<void> saveSheets(List<ExpenseSheet> sheets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = sheets.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_sheetsKey, data);
    } catch (e) {
      debugPrint('Error saving sheets: $e');
    }
  }

  // Add sheet
  static Future<ExpenseSheet> addSheet(ExpenseSheet sheet) async {
    final sheets = await getSheets();
    sheets.add(sheet);
    await saveSheets(sheets);
    return sheet;
  }

  // Update sheet
  static Future<void> updateSheet(ExpenseSheet sheet) async {
    final sheets = await getSheets();
    final index = sheets.indexWhere((s) => s.id == sheet.id);
    if (index != -1) {
      sheets[index] = sheet;
      await saveSheets(sheets);
    }
  }

  // Delete sheet
  static Future<void> deleteSheet(String sheetId) async {
    final sheets = await getSheets();
    sheets.removeWhere((s) => s.id == sheetId);
    await saveSheets(sheets);
  }

  // Get sheet by id
  static Future<ExpenseSheet?> getSheetById(String sheetId) async {
    final sheets = await getSheets();
    try {
      return sheets.firstWhere((s) => s.id == sheetId);
    } catch (e) {
      return null;
    }
  }
}

void debugPrint(String message) {
  print(message);
}
