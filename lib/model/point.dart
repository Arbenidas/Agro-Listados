class Point {
  final int? id;
  final String name;
  final String address;
  final bool isActive;
  final DateTime createdAt;

  Point({
    this.id,
    required this.name,
    required this.address,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Point.fromMap(Map<String, dynamic> map) {
    try {
      return Point(
        id: map['id'] != null ? map['id'] as int : null,
        name: map['name']?.toString() ?? '',
        address: map['address']?.toString() ?? '',
        isActive: map['is_active'] == 1 || map['is_active'] == true,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Error creating Point from map: $e');
      print('Map data: $map');
      // Retornar un Point por defecto en caso de error
      return Point(
        id: map['id'] != null ? map['id'] as int : null,
        name: map['name']?.toString() ?? 'Punto Desconocido',
        address: map['address']?.toString() ?? 'Dirección no disponible',
        isActive: true,
        createdAt: DateTime.now(),
      );
    }
  }

  Point copyWith({
    int? id,
    String? name,
    String? address,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Point(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Point(id: $id, name: $name, address: $address, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        isActive.hashCode;
  }
}
