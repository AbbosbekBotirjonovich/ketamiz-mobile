class UserModel {
  int id;
  String firstName;
  String lastName;
  String fatherName;
  String email;
  String phone;
  String password;
  String image;
  String role;
  int isVerified;
  dynamic verificationCode;
  String drivingVerificationStatus;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.email,
    required this.phone,
    required this.password,
    required this.image,
    required this.role,
    required this.isVerified,
    required this.verificationCode,
    required this.drivingVerificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: _asInt(json["id"]),
        firstName: json["first_name"]?.toString() ?? "",
        lastName: json["last_name"]?.toString() ?? "",
        fatherName: json["father_name"]?.toString() ?? "",
        email: json["email"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
        password: json["password"]?.toString() ?? "",
        image: json["image"]?.toString() ?? "default.jpg",
        role: json["role"]?.toString() ?? "client",
        isVerified: _asInt(json["is_verified"]),
        verificationCode: json["verification_code"] ?? "",
        drivingVerificationStatus:
            json["driving_verification_status"]?.toString() ?? "",
        createdAt: _parseDate(json["created_at"]),
        updatedAt: _parseDate(json["updated_at"]),
      );

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "father_name": fatherName,
    "phone": phone,
    "password": password,
    "image": image,
    "role": role,
    "is_verified": isVerified,
    "verification_code": verificationCode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
