/// User profile model - loaded via bootstrap
class UserProfile {
  final String personId; // Canonical ID (pid from JWT)
  final String displayName;
  final String? email;
  final String? employerName;
  final String employeeCode;
  final String department;
  final List<String> roles;
  final bool isActive;
  final DateTime? lastLogin;

  const UserProfile({
    required this.personId,
    required this.displayName,
    required this.employeeCode,
    required this.department,
    required this.roles,
    required this.isActive,
    this.email,
    this.employerName,
    this.lastLogin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      personId: json['personId'],
      displayName: json['displayName'] ?? 'User',
      email: json['email'],
      employerName: json['employerName'],
      employeeCode: json['employeeCode'] ?? '',
      department: json['department'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  bool get isPlatformOwner => roles.contains('PLATFORM_OWNER');
  bool get isTenantOwner => roles.contains('TENANT_OWNER');
  bool get isEmployerAdmin => roles.contains('EMPLOYER_ADMIN');
  bool get isEmployerUser => roles.contains('EMPLOYER_USER');
  bool get isUser => roles.contains('USER');
}