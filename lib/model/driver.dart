class Driver {
  String id;
  String name;
  String licenseNumber;
  String phoneNumber;
  String email;

  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.phoneNumber,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'licenseNumber': licenseNumber,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      name: map['name'],
      licenseNumber: map['licenseNumber'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
    );
  }
}
