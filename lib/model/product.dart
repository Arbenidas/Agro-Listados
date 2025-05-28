class Product {
  final int? id;
  final String name;
  final String unit;
  final bool isActive;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.unit,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      isActive: (map['is_active'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, unit: $unit, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.unit == unit &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        unit.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode;
  }
}
