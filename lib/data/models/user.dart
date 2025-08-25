import 'package:equatable/equatable.dart';

/// Entidade que representa um usuário do sistema
class User extends Equatable {
  final String cpf;
  final String name;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final List<String> roles;

  const User({
    required this.cpf,
    required this.name,
    this.email,
    this.phone,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.roles = const ['user'],
  });

  /// Cria uma instância de User a partir de JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      cpf: json['cpf'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? ['user'],
    );
  }

  /// Converte User para JSON
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'roles': roles,
    };
  }

  /// Cria uma cópia do User com campos modificados
  User copyWith({
    String? cpf,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    List<String>? roles,
  }) {
    return User(
      cpf: cpf ?? this.cpf,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [
        cpf,
        name,
        email,
        phone,
        createdAt,
        lastLogin,
        isActive,
        roles,
      ];

  @override
  String toString() {
    return 'User(cpf: $cpf, name: $name, isActive: $isActive)';
  }
}
