import 'dart:convert';

GetUserModel getUserModelFromJson(String str) => GetUserModel.fromJson(json.decode(str));
String getUserModelToJson(GetUserModel data) => json.encode(data.toJson());

class GetUserModel {
  String status;
  User user;

  GetUserModel({
    required this.status,
    required this.user,
  });

  factory GetUserModel.fromJson(Map<String, dynamic> json) => GetUserModel(
    status: json["status"]?.toString() ?? "",
    user: json["user"] is Map<String, dynamic>
        ? User.fromJson(json["user"])
        : User.empty(),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "user": user.toJson(),
  };
}

class User {
  int id;
  String firstName;
  String lastName;
  String fatherName;
  String email;
  String phone;
  String role;
  DateTime? birthDate;
  String drivingVerificationStatus;
  String drivingLicenceNumber;
  String drivingLicenceExpiry;
  DateTime? createdAt;
  String image;
  Balance balance;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.email,
    required this.phone,
    required this.role,
    required this.birthDate,
    required this.drivingVerificationStatus,
    required this.drivingLicenceNumber,
    required this.drivingLicenceExpiry,
    required this.createdAt,
    required this.image,
    required this.balance,
  });

  factory User.empty() => User(
        id: 0,
        firstName: "",
        lastName: "",
        fatherName: "",
        email: "",
        phone: "",
        role: "",
        birthDate: null,
        drivingVerificationStatus: "none",
        drivingLicenceNumber: "",
        drivingLicenceExpiry: "",
        createdAt: null,
        image: "",
        balance: Balance.empty(),
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: _asInt(json["id"]),
        firstName: json["first_name"]?.toString() ?? "",
        lastName: json["last_name"]?.toString() ?? "",
        fatherName: json["father_name"]?.toString() ?? "",
        email: json["email"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
        role: json["role"]?.toString() ?? "",
        birthDate: _tryParseDate(json["birth_date"]),
        drivingVerificationStatus:
            json["driving_verification_status"]?.toString() ?? "none",
        drivingLicenceNumber:
            json["driving_licence_number"]?.toString() ?? "",
        drivingLicenceExpiry:
            json["driving_licence_expiry"]?.toString() ?? "",
        createdAt: _tryParseDate(json["created_at"]),
        image: json["image"]?.toString() ?? "",
        balance: json["balance"] is Map<String, dynamic>
            ? Balance.fromJson(json["balance"])
            : Balance.empty(),
      );

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _tryParseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "father_name": fatherName,
    "email": email,
    "phone": phone,
    "role": role,
    "birth_date": birthDate?.toIso8601String(),
    "driving_verification_status": drivingVerificationStatus,
    "driving_licence_number": drivingLicenceNumber,
    "driving_licence_expiry": drivingLicenceExpiry,
    "created_at": createdAt?.toIso8601String(),
    "image": image,
    "balance": balance.toJson(),
  };
}

class Balance {
  String balance;
  String afterTax;
  String tax;
  String lockedBalance;
  String currency;

  Balance({
    required this.balance,
    required this.afterTax,
    required this.tax,
    required this.lockedBalance,
    required this.currency,
  });

  factory Balance.empty() => Balance(
      balance: "0",
      afterTax: "0",
      tax: "0",
      lockedBalance: "0",
      currency: "UZS");

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
        balance: json["balance"]?.toString() ?? "0",
        afterTax: json["after_tax"]?.toString() ?? "0",
        tax: json["tax"]?.toString() ?? "0",
        lockedBalance: json["locked_balance"]?.toString() ?? "0",
        currency: json["currency"]?.toString() ?? "UZS",
      );

  Map<String, dynamic> toJson() => {
    "balance": balance,
    "after_tax": afterTax,
    "tax": tax,
    "locked_balance": lockedBalance,
    "currency": currency,
  };
}
