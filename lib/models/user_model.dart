class UserModel {
  String id;
  String name;
  String email;
  String? password; // Hashed password
  String country;
  String currency;
  bool isLoggedIn;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.country,
    required this.currency,
    this.isLoggedIn = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
    "country": country,
    "currency": currency,
    "isLoggedIn": isLoggedIn,
    "createdAt": createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      password: json["password"],
      country: json["country"] ?? "",
      currency: json["currency"] ?? "USD",
      isLoggedIn: json["isLoggedIn"] ?? false,
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? country,
    String? currency,
    bool? isLoggedIn,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
