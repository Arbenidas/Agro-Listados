class Driver {
  final int? id;
  final String name;
  final String driverId;
  final String phone;
  final String licenseType;
  final bool isActive;
  final DateTime createdAt;

  Driver({
    this.id,
    required this.name,
    required this.driverId,
    required this.phone,
    required this.licenseType,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'driver_id': driverId,
      'phone': phone,
      'license_type': licenseType,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      driverId: map['driver_id'] ?? '',
      phone: map['phone'] ?? '',
      licenseType: map['license_type'] ?? '',
      isActive: (map['is_active'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Driver copyWith({
    int? id,
    String? name,
    String? driverId,
    String? phone,
    String? licenseType,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      driverId: driverId ?? this.driverId,
      phone: phone ?? this.phone,
      licenseType: licenseType ?? this.licenseType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Driver(id: $id, name: $name, driverId: $driverId, phone: $phone, licenseType: $licenseType, isActive: $isActive)';
  }
}
