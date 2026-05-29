import 'dart:convert';

import 'package:ketamiz/src/model/api/user_model.dart';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String status;
  String message;
  UserModel user;
  Authorisation authorisation;

  LoginModel({
    required this.status,
    required this.message,
    required this.user,
    required this.authorisation,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"]??"error",
    message: json["message"]??"",
    user: json["user"] != null ? UserModel.fromJson(json["user"]) : UserModel(
      id: 0, firstName: "", lastName: "", fatherName: "", email: "", phone: "",
      password: "", image: "", role: "", isVerified: 0, verificationCode: "",
      drivingVerificationStatus: "", createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
    authorisation: json["authorisation"] != null 
        ? Authorisation.fromJson(json["authorisation"]) 
        : Authorisation(token: "", type: ""),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "user": user.toJson(),
    "authorisation": authorisation.toJson(),
  };
}

class Authorisation {
  String token;
  String type;

  Authorisation({
    required this.token,
    required this.type,
  });

  factory Authorisation.fromJson(Map<String, dynamic> json) => Authorisation(
    token: json["token"]??"",
    type: json["type"]??"",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "type": type,
  };
}
