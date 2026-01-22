class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final String? document;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthDate,
    this.document,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      document: json['document'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  factory User.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return User.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'document': document,
      'roles': roles,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool isEmployee() {
    return hasRole('EMPLOYEE');
  }

  bool isManager() {
    return hasRole('MANAGER');
  }

  bool isAdmin() {
    return hasRole('ADMIN');
  }
}