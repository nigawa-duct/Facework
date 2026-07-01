class Employee {
  final int? id;
  final String name;
  final String faceData;

  Employee({
    this.id,
    required this.name,
    required this.faceData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'faceData': faceData,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      faceData: map['faceData'],
    );
  }
}