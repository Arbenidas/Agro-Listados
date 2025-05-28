class UserPoint {
  final int? id;
  final int userId;
  final int pointId;
  final DateTime assignedAt;

  UserPoint({
    this.id,
    required this.userId,
    required this.pointId,
    required this.assignedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'point_id': pointId,
      'assigned_at': assignedAt.toIso8601String(),
    };
  }

  factory UserPoint.fromMap(Map<String, dynamic> map) {
    return UserPoint(
      id: map['id']?.toInt(),
      userId: map['user_id']?.toInt() ?? 0,
      pointId: map['point_id']?.toInt() ?? 0,
      assignedAt: DateTime.parse(map['assigned_at']),
    );
  }

  UserPoint copyWith({
    int? id,
    int? userId,
    int? pointId,
    DateTime? assignedAt,
  }) {
    return UserPoint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointId: pointId ?? this.pointId,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  @override
  String toString() {
    return 'UserPoint(id: $id, userId: $userId, pointId: $pointId, assignedAt: $assignedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPoint &&
        other.id == id &&
        other.userId == userId &&
        other.pointId == pointId &&
        other.assignedAt == assignedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        pointId.hashCode ^
        assignedAt.hashCode;
  }
}
