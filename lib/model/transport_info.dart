class TransportInfo {
  final int? id;
  final int listId;
  final String driverName;
  final String driverIdText; // Cambiar nombre para evitar conflicto
  final String truckPlate;
  final String truckModel;
  final String entryTime;
  final String? exitTime;
  final String? notes;
  final DateTime createdAt;
  final int? driverDbId; // ID del conductor en la base de datos
  final int? truckDbId; // ID del camión en la base de datos

  TransportInfo({
    this.id,
    required this.listId,
    required this.driverName,
    required this.driverIdText,
    required this.truckPlate,
    required this.truckModel,
    required this.entryTime,
    this.exitTime,
    this.notes,
    required this.createdAt,
    this.driverDbId,
    this.truckDbId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'driver_name': driverName,
      'driver_id_text': driverIdText,
      'truck_plate': truckPlate,
      'truck_model': truckModel,
      'entry_time': entryTime,
      'exit_time': exitTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'driver_id': driverDbId,
      'truck_id': truckDbId,
    };
  }

  factory TransportInfo.fromMap(Map<String, dynamic> map) {
    return TransportInfo(
      id: map['id']?.toInt(),
      listId: map['list_id']?.toInt() ?? 0,
      driverName: map['driver_name'] ?? '',
      driverIdText: map['driver_id_text'] ?? '',
      truckPlate: map['truck_plate'] ?? '',
      truckModel: map['truck_model'] ?? '',
      entryTime: map['entry_time'] ?? '',
      exitTime: map['exit_time'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      driverDbId: map['driver_id']?.toInt(),
      truckDbId: map['truck_id']?.toInt(),
    );
  }

  TransportInfo copyWith({
    int? id,
    int? listId,
    String? driverName,
    String? driverIdText,
    String? truckPlate,
    String? truckModel,
    String? entryTime,
    String? exitTime,
    String? notes,
    DateTime? createdAt,
    int? driverDbId,
    int? truckDbId,
  }) {
    return TransportInfo(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      driverName: driverName ?? this.driverName,
      driverIdText: driverIdText ?? this.driverIdText,
      truckPlate: truckPlate ?? this.truckPlate,
      truckModel: truckModel ?? this.truckModel,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      driverDbId: driverDbId ?? this.driverDbId,
      truckDbId: truckDbId ?? this.truckDbId,
    );
  }

  @override
  String toString() {
    return 'TransportInfo(id: $id, listId: $listId, driverName: $driverName, driverIdText: $driverIdText, truckPlate: $truckPlate, truckModel: $truckModel, entryTime: $entryTime, exitTime: $exitTime, notes: $notes, createdAt: $createdAt, driverDbId: $driverDbId, truckDbId: $truckDbId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransportInfo &&
        other.id == id &&
        other.listId == listId &&
        other.driverName == driverName &&
        other.driverIdText == driverIdText &&
        other.truckPlate == truckPlate &&
        other.truckModel == truckModel &&
        other.entryTime == entryTime &&
        other.exitTime == exitTime &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        listId.hashCode ^
        driverName.hashCode ^
        driverIdText.hashCode ^
        truckPlate.hashCode ^
        truckModel.hashCode ^
        entryTime.hashCode ^
        exitTime.hashCode ^
        notes.hashCode ^
        createdAt.hashCode;
  }
}
