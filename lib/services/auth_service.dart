import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';

class AuthService {
  static const String _usersKey = "app_users";
  static const String _currentUserKey = "current_user";
  static const String _sessionKey = "session_token";

  // Hash password
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Register
  static Future<Map<String, dynamic>> register(
    AuthModel auth,
    String name,
    String country,
    String currency,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if user already exists
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      for (var userStr in usersJson) {
        final user = UserModel.fromJson(jsonDecode(userStr));
        if (user.email == auth.email) {
          return {'success': false, 'message': 'Email already registered'};
        }
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: auth.email,
        password: _hashPassword(auth.password),
        country: country,
        currency: currency,
        isLoggedIn: true,
      );

      // Save user to list
      usersJson.add(jsonEncode(newUser.toJson()));
      await prefs.setStringList(_usersKey, usersJson);

      // Set as current user
      await prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));
      await prefs.setString(_sessionKey, newUser.id);

      return {'success': true, 'user': newUser};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(AuthModel auth) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final usersJson = prefs.getStringList(_usersKey) ?? [];

      for (var userStr in usersJson) {
        final user = UserModel.fromJson(jsonDecode(userStr));
        if (user.email == auth.email &&
            user.password == _hashPassword(auth.password)) {
          // Update login status
          final loggedInUser = user.copyWith(isLoggedIn: true);

          // Update in list
          final updatedUsers = usersJson.map((u) {
            final userObj = UserModel.fromJson(jsonDecode(u));
            if (userObj.id == user.id) {
              return jsonEncode(loggedInUser.toJson());
            }
            return u;
          }).toList();

          await prefs.setStringList(_usersKey, updatedUsers);
          await prefs.setString(
            _currentUserKey,
            jsonEncode(loggedInUser.toJson()),
          );
          await prefs.setString(_sessionKey, loggedInUser.id);

          return {'success': true, 'user': loggedInUser};
        }
      }

      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.remove(_sessionKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current session user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson == null) return null;

      final user = UserModel.fromJson(jsonDecode(userJson));

      // Check if session is still valid
      final sessionToken = prefs.getString(_sessionKey);
      if (sessionToken != user.id) return null;

      return user;
    } catch (e) {
      return null;
    }
  }

  // Is user logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Update user password
  static Future<Map<String, dynamic>> updatePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];

      for (var i = 0; i < usersJson.length; i++) {
        final user = UserModel.fromJson(jsonDecode(usersJson[i]));
        if (user.email == email &&
            user.password == _hashPassword(oldPassword)) {
          final updatedUser = user.copyWith(
            password: _hashPassword(newPassword),
          );
          usersJson[i] = jsonEncode(updatedUser.toJson());

          await prefs.setStringList(_usersKey, usersJson);
          await prefs.setString(
            _currentUserKey,
            jsonEncode(updatedUser.toJson()),
          );

          return {'success': true, 'message': 'Password updated'};
        }
      }

      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
