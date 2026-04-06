enum UserRole {
  user,
  masjid_admin,
  super_admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'masjid_admin':
        return UserRole.masjid_admin;
      case 'super_admin':
        return UserRole.super_admin;
      default:
        return UserRole.user;
    }
  }
}

class User {
  final int id;
  final String email;
  final String? fullName;
  final UserRole role;
  final String? maslak;
  final String? profilePic;

  User({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.maslak,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'],
      role: UserRole.fromString(json['role'] ?? 'user'),
      maslak: json['maslak'],
      profilePic: json['profile_pic'],
    );
  }
}
