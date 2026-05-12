import 'dart:convert';

List<MyVehiclesModel> myVehiclesModelFromJson(String str) =>
    List<MyVehiclesModel>.from(
        json.decode(str).map((x) => MyVehiclesModel.fromJson(x)));

String myVehiclesModelToJson(List<MyVehiclesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

DateTime _parseDate(dynamic v) {
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v) ?? DateTime.now();
  }
  return DateTime.now();
}

class MyVehiclesModel {
  int id;
  String model;
  String carNumber;
  String techPassportNumber;
  int seats;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic vehicleImages;
  VehicleColor color;
  You you;

  MyVehiclesModel({
    required this.id,
    required this.model,
    required this.carNumber,
    required this.techPassportNumber,
    required this.seats,
    required this.createdAt,
    required this.updatedAt,
    required this.vehicleImages,
    required this.color,
    required this.you,
  });

  factory MyVehiclesModel.fromJson(Map<String, dynamic> json) =>
      MyVehiclesModel(
        id: _asInt(json["id"]),
        model: json["model"]?.toString() ?? "",
        carNumber: json["car_number"]?.toString() ?? "",
        techPassportNumber: json["tech_passport_number"]?.toString() ?? "",
        seats: _asInt(json["seats"]),
        createdAt: _parseDate(json["created_at"]),
        updatedAt: _parseDate(json["updated_at"]),
        vehicleImages: json["vehicle_images"],
        color: json["color"] is Map<String, dynamic>
            ? VehicleColor.fromJson(json["color"])
            : VehicleColor.empty(),
        you: json["you"] is Map<String, dynamic>
            ? You.fromJson(json["you"])
            : You.empty(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "car_number": carNumber,
        "tech_passport_number": techPassportNumber,
        "seats": seats,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "vehicle_images": vehicleImages,
        "color": color.toJson(),
        "you": you.toJson(),
      };
}

class VehicleColor {
  String titleUz;
  String titleRu;
  String titleEn;
  String code;

  VehicleColor({
    required this.titleUz,
    required this.titleRu,
    required this.titleEn,
    required this.code,
  });

  factory VehicleColor.empty() =>
      VehicleColor(titleUz: "", titleRu: "", titleEn: "", code: "");

  factory VehicleColor.fromJson(Map<String, dynamic> json) => VehicleColor(
        titleUz: json["title_uz"]?.toString() ?? "",
        titleRu: json["title_ru"]?.toString() ?? "",
        titleEn: json["title_en"]?.toString() ?? "",
        code: json["code"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title_uz": titleUz,
        "title_ru": titleRu,
        "title_en": titleEn,
        "code": code,
      };
}

class You {
  int id;
  String firstName;
  String lastName;
  String phone;

  You({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory You.empty() => You(id: 0, firstName: "", lastName: "", phone: "");

  factory You.fromJson(Map<String, dynamic> json) => You(
        id: _asInt(json["id"]),
        firstName: json["first_name"]?.toString() ?? "",
        lastName: json["last_name"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
      };
}
