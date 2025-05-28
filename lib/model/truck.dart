class Truck {
  final int? id;
  final String plate;
  final String model;
  final String brand;
  final int year;
  final double capacity;
  final bool isActive;
  final DateTime createdAt;

  Truck({
    this.id,
    required this.plate,
    required this.model,
    required this.brand,
    required this.year,
    required this.capacity,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'model': model,
      'brand': brand,
      'year': year,
      'capacity': capacity,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Truck.fromMap(Map<String, dynamic> map) {
    return Truck(
      id: map['id']?.toInt(),
      plate: map['plate'] ?? '',
      model: map['model'] ?? '',
      brand: map['brand'] ?? '',
      year: map['year']?.toInt() ?? 0,
      capacity: (map['capacity'] ?? 0).toDouble(),
      isActive: (map['is_active'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Truck copyWith({
    int? id,
    String? plate,
    String? model,
    String? brand,
    int? year,
    double? capacity,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Truck(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      model: model ?? this.model,
      brand: brand ?? this.brand,
      year: year ?? this.year,
      capacity: capacity ?? this.capacity,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Truck(id: $id, plate: $plate, model: $model, brand: $brand, year: $year, capacity: $capacity, isActive: $isActive)';
  }
}
