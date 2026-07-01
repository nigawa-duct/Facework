class Attendance {
  final int? id;
  final int employeeId;
  final String type;
  final String dateTime;

  Attendance({
    this.id,
    required this.employeeId,
    required this.type,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'type': type,
      'dateTime': dateTime,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      employeeId: map['employeeId'],
      type: map['type'],
      dateTime: map['dateTime'],
    );
  }
}