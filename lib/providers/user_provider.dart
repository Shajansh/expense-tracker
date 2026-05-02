import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/ip_currency_helper.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await UserService.getUser();

      // Auto-detect currency on first launch
      if (_user != null &&
          (_user!.currency.isEmpty || _user!.currency == "USD")) {
        String detected = await IpCurrencyHelper.detectCurrency();
        _user!.currency = detected;
        await UserService.saveUser(_user!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _user = updatedUser;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCurrency(String currency) async {
    if (_user == null) return;
    try {
      _user!.currency = currency;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    if (_user == null) return;
    try {
      _user!.name = name;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEmail(String email) async {
    if (_user == null) return;
    try {
      _user!.email = email;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCountry(String country) async {
    if (_user == null) return;
    try {
      _user!.country = country;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? country,
    String? currency,
  }) async {
    if (_user == null) return;
    try {
      if (name != null) _user!.name = name;
      if (email != null) _user!.email = email;
      if (country != null) _user!.country = country;
      if (currency != null) _user!.currency = currency;
      await UserService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String getCurrencySymbol() {
    if (_user == null) return '\$';
    switch (_user!.currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'LKR':
        return 'Rs';
      default:
        return '\$';
    }
  }
}
