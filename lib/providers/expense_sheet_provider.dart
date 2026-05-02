import 'package:flutter/foundation.dart';
import '../models/expense_sheet.dart';
import '../services/sheet_service.dart';

class ExpenseSheetProvider extends ChangeNotifier {
  List<ExpenseSheet> _sheets = [];
  String? _currentSheetId;
  bool _isLoading = false;
  String? _error;

  List<ExpenseSheet> get sheets => _sheets;
  ExpenseSheet? get currentSheet => _currentSheetId != null
      ? _sheets.firstWhere(
          (s) => s.id == _currentSheetId,
          orElse: () => _sheets.isNotEmpty
              ? _sheets.first
              : ExpenseSheet(name: 'Default'),
        )
      : (_sheets.isNotEmpty ? _sheets.first : null);
  String? get currentSheetId => _currentSheetId ?? sheets.firstOrNull?.id;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpenseSheetProvider() {
    loadSheets();
  }

  Future<void> loadSheets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _sheets = await SheetService.getSheets();

      // If no sheets exist, create default sheet
      if (_sheets.isEmpty) {
        final defaultSheet = ExpenseSheet(name: 'Personal');
        await SheetService.addSheet(defaultSheet);
        _sheets.add(defaultSheet);
      }

      // Set current sheet
      _currentSheetId ??= _sheets.first.id;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSheet(String name, {String description = ''}) async {
    try {
      _error = null;
      final sheet = ExpenseSheet(name: name, description: description);
      await SheetService.addSheet(sheet);
      _sheets.add(sheet);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSheet(
    String sheetId,
    String newName, {
    String? description,
  }) async {
    try {
      _error = null;
      final index = _sheets.indexWhere((s) => s.id == sheetId);
      if (index != -1) {
        final updated = _sheets[index].copyWith(
          name: newName,
          description: description ?? _sheets[index].description,
        );
        _sheets[index] = updated;
        await SheetService.updateSheet(updated);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSheet(String sheetId) async {
    try {
      _error = null;

      // Don't delete if it's the last sheet
      if (_sheets.length <= 1) {
        _error = 'Cannot delete the last expense sheet';
        notifyListeners();
        return;
      }

      _sheets.removeWhere((s) => s.id == sheetId);
      await SheetService.deleteSheet(sheetId);

      // If deleted sheet was current, switch to first
      if (_currentSheetId == sheetId) {
        _currentSheetId = _sheets.isNotEmpty ? _sheets.first.id : null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void setCurrentSheet(String sheetId) {
    if (_sheets.any((s) => s.id == sheetId)) {
      _currentSheetId = sheetId;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
