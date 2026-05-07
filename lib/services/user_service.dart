import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class UserService {
  static const String key = "user_profile";

  // SAVE USER
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(user.toJson()));
  }

  // LOAD USER
  static Future<UserModel> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) {
      return UserModel(
        name: "Your Name",
        email: "email@example.com",
        country: "Sri Lanka",
        currency: "LKR",
      );
    }

    return UserModel.fromJson(jsonDecode(data));
  }
}
