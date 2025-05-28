class User {
  final int? id;
  final String email;
  final String password;
  final String name;
  final String role;
  final DateTime createdAt;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.password == password &&
        other.name == name &&
        other.role == role &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        password.hashCode ^
        name.hashCode ^
        role.hashCode ^
        createdAt.hashCode;
  }
}
