class UserModel {
  final String name;
  final String userId;
  final String designation;
  final String officerType;
  final String mobile;
  final String boothNumber;
  final String boothName;

  UserModel({
    required this.name,
    required this.userId,
    required this.designation,
    required this.officerType,
    required this.mobile,
    required this.boothNumber,
    required this.boothName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      userId: json['userId'],
      designation: json['designation'],
      officerType: json['officerType'],
      mobile: json['mobile'],
      boothNumber: json['boothNumber'],
      boothName: json['boothName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'designation': designation,
      'officerType': officerType,
      'mobile': mobile,
      'boothNumber': boothNumber,
      'boothName': boothName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      userId: map['userId'],
      designation: map['designation'],
      officerType: map['officerType'],
      mobile: map['mobile'],
      boothNumber: map['boothNumber'],
      boothName: map['boothName'],
    );
  }
}
