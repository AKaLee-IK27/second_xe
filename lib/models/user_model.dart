enum UserRole {
  admin('admin'),
  user('user'),
  moderator('moderator');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

class UserModel {
  final String id;
  final String? authId;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isVerified;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.authId,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.isVerified = false,
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authId: json['auth_id'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'auth_id': authId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'role': role.value,
    };
  }

  // Convert to JSON for database update
  Map<String, dynamic> toUpdateJson() {
    return {
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'role': role.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Copy with method for creating modified instances
  UserModel copyWith({
    String? id,
    String? authId,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    bool? isVerified,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Display name getter
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return email.split('@').first;
  }

  // Check if user has admin privileges
  bool get isAdmin => role == UserRole.admin;

  // Check if user has moderator privileges
  bool get isModerator => role == UserRole.moderator || isAdmin;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: ${role.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
