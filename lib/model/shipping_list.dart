class ShippingList {
  final int? id;
  final int userId;
  final int pointId;
  final DateTime shippingDate;
  final String status; // 'pendiente', 'en_proceso', 'completado'
  final double total;
  final DateTime createdAt;

  ShippingList({
    this.id,
    required this.userId,
    required this.pointId,
    required this.shippingDate,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'point_id': pointId,
      'shipping_date': shippingDate.toIso8601String(),
      'status': status,
      'total': total,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShippingList.fromMap(Map<String, dynamic> map) {
    return ShippingList(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      pointId: map['point_id']?.toInt() ?? 0,
      shippingDate: DateTime.parse(map['shipping_date']),
      status: map['status'] ?? 'pendiente',
      total: (map['total'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  ShippingList copyWith({
    int? id,
    int? userId,
    int? pointId,
    DateTime? shippingDate,
    String? status,
    double? total,
    DateTime? createdAt,
  }) {
    return ShippingList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointId: pointId ?? this.pointId,
      shippingDate: shippingDate ?? this.shippingDate,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ShippingList(id: $id, userId: $userId, pointId: $pointId, shippingDate: $shippingDate, status: $status, total: $total, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShippingList &&
        other.id == id &&
        other.userId == userId &&
        other.pointId == pointId &&
        other.shippingDate == shippingDate &&
        other.status == status &&
        other.total == total &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        pointId.hashCode ^
        shippingDate.hashCode ^
        status.hashCode ^
        total.hashCode ^
        createdAt.hashCode;
  }
}
