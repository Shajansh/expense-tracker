class UserModel {
  String name;
  String email;
  String country;
  String currency;

  UserModel({
    required this.name,
    required this.email,
    required this.country,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "country": country,
    "currency": currency,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      country: json["country"] ?? "",
      currency: json["currency"] ?? "USD",
    );
  }
}
