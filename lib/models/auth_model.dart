class AuthModel {
  final String email;
  final String password;

  AuthModel({required this.email, required this.password});

  bool isValid() {
    return email.isNotEmpty && email.contains('@') && password.length >= 6;
  }
}
