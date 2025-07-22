class UploadEntry {
  final int? id;
  final DateTime date;
  final String slotLabel;
  final DateTime slotStart;
  final DateTime slotEnd;
  final String status; // 'done', 'missed', 'pending'
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final bool isSynced;

  UploadEntry({
    this.id,
    required this.date,
    required this.slotLabel,
    required this.slotStart,
    required this.slotEnd,
    required this.status,
    this.imagePath,
    this.latitude,
    this.longitude,
    this.isSynced = false,
  });

  UploadEntry copyWith({
    int? id,
    DateTime? date,
    String? slotLabel,
    DateTime? slotStart,
    DateTime? slotEnd,
    String? status,
    String? imagePath,
    double? latitude,
    double? longitude,
    bool? isSynced,
  }) {
    return UploadEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      slotLabel: slotLabel ?? this.slotLabel,
      slotStart: slotStart ?? this.slotStart,
      slotEnd: slotEnd ?? this.slotEnd,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'date': date.toIso8601String().substring(0, 10), // Store only date part
      'slotLabel': slotLabel,
      'slotStart': slotStart.toIso8601String(),
      'slotEnd': slotEnd.toIso8601String(),
      'status': status,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'isSynced': isSynced ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory UploadEntry.fromMap(Map<String, dynamic> map) {
    return UploadEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      slotLabel: map['slotLabel'],
      slotStart: DateTime.parse(map['slotStart']),
      slotEnd: DateTime.parse(map['slotEnd']),
      status: map['status'],
      imagePath: map['imagePath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isSynced: map['isSynced'] == 1,
    );
  }
}
