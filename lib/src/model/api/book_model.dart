import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

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

class BookModel {
  int bookingId;
  int seatsBooked;
  String totalPrice;
  String status;
  DateTime createdAt;
  BookedTrip trip;
  List<Passenger> passengers;
  BookDriver driver;
  BookVehicle vehicle;

  BookModel({
    required this.bookingId,
    required this.seatsBooked,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.trip,
    required this.passengers,
    required this.driver,
    required this.vehicle,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        bookingId: _asInt(json["booking_id"]),
        seatsBooked: _asInt(json["seats_booked"]),
        totalPrice: json["total_price"]?.toString() ?? "",
        status: json["status"]?.toString() ?? "",
        createdAt: _parseDate(json["created_at"]),
        trip: json["trip"] is Map<String, dynamic>
            ? BookedTrip.fromJson(json["trip"])
            : BookedTrip.empty(),
        passengers: json["passengers"] is List
            ? (json["passengers"] as List)
                .whereType<Map>()
                .map((x) => Passenger.fromJson(Map<String, dynamic>.from(x)))
                .toList()
            : <Passenger>[],
        driver: json["driver"] is Map<String, dynamic>
            ? BookDriver.fromJson(json["driver"])
            : BookDriver.empty(),
        vehicle: json["vehicle"] is Map<String, dynamic>
            ? BookVehicle.fromJson(json["vehicle"])
            : BookVehicle.empty(),
      );

  Map<String, dynamic> toJson() => {
        "booking_id": bookingId,
        "seats_booked": seatsBooked,
        "total_price": totalPrice,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "trip": trip.toJson(),
        "passengers": List<dynamic>.from(passengers.map((x) => x.toJson())),
        "driver": driver.toJson(),
        "vehicle": vehicle.toJson(),
      };
}

class BookDriver {
  int id;
  String firstName;
  String lastName;
  String email;
  String role;
  String phone;

  BookDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phone,
  });

  factory BookDriver.empty() => BookDriver(
      id: 0, firstName: "", lastName: "", email: "", role: "", phone: "");

  factory BookDriver.fromJson(Map<String, dynamic> json) => BookDriver(
        id: _asInt(json["id"]),
        firstName: json["first_name"]?.toString() ?? "",
        lastName: json["last_name"]?.toString() ?? "",
        email: json["email"]?.toString() ?? "",
        role: json["role"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "role": role,
        "phone": phone,
      };
}

class Passenger {
  int id;
  String name;
  String phone;

  Passenger({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: _asInt(json["id"]),
        name: json["name"]?.toString() ?? "",
        phone: json["phone"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
      };
}

class BookedTrip {
  int id;
  String startRegion;
  String startDistrict;
  String startQuarter;
  String endRegion;
  String endDistrict;
  String endQuarter;
  int startRegionId;
  int endRegionId;
  int startDistrictId;
  int endDistrictId;
  int startQuarterId;
  int endQuarterId;
  DateTime startTime;
  DateTime endTime;
  String pricePerSeat;
  int availableSeats;
  String status;
  String fromLatitude;
  String fromLongitude;
  String toLatitude;
  String toLongitude;

  BookedTrip({
    required this.id,
    this.startRegion = "",
    this.startDistrict = "",
    this.startQuarter = "",
    this.endRegion = "",
    this.endDistrict = "",
    this.endQuarter = "",
    required this.startRegionId,
    required this.endRegionId,
    required this.startDistrictId,
    required this.endDistrictId,
    required this.startQuarterId,
    required this.endQuarterId,
    required this.startTime,
    required this.endTime,
    required this.pricePerSeat,
    required this.availableSeats,
    required this.status,
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
  });

  factory BookedTrip.empty() => BookedTrip(
        id: 0,
        startRegionId: 0,
        endRegionId: 0,
        startDistrictId: 0,
        endDistrictId: 0,
        startQuarterId: 0,
        endQuarterId: 0,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        pricePerSeat: "",
        availableSeats: 0,
        status: "",
        fromLatitude: "",
        fromLongitude: "",
        toLatitude: "",
        toLongitude: "",
      );

  factory BookedTrip.fromJson(Map<String, dynamic> json) => BookedTrip(
        id: _asInt(json["id"]),
        startRegion: json["start_region"]?.toString() ?? "",
        startDistrict: json["start_district"]?.toString() ?? "",
        startQuarter: json["start_quarter"]?.toString() ?? "",
        endRegion: json["end_region"]?.toString() ?? "",
        endDistrict: json["end_district"]?.toString() ?? "",
        endQuarter: json["end_quarter"]?.toString() ?? "",
        startRegionId: _asInt(json["start_region_id"]),
        endRegionId: _asInt(json["end_region_id"]),
        startDistrictId: _asInt(json["start_district_id"]),
        endDistrictId: _asInt(json["end_district_id"]),
        startQuarterId: _asInt(json["start_quarter_id"]),
        endQuarterId: _asInt(json["end_quarter_id"]),
        startTime: _parseDate(json["start_time"]),
        endTime: _parseDate(json["end_time"]),
        pricePerSeat: json["price_per_seat"]?.toString() ?? "",
        availableSeats: _asInt(json["available_seats"]),
        status: json["status"]?.toString() ?? "",
        fromLatitude: json["from_latitude"]?.toString() ?? "",
        fromLongitude: json["from_longitude"]?.toString() ?? "",
        toLatitude: json["to_latitude"]?.toString() ?? "",
        toLongitude: json["to_longitude"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "start_region_id": startRegionId,
        "end_region_id": endRegionId,
        "start_district_id": startDistrictId,
        "end_district_id": endDistrictId,
        "start_quarter_id": startQuarterId,
        "end_quarter_id": endQuarterId,
        "start_time": startTime.toIso8601String(),
        "end_time": endTime.toIso8601String(),
        "price_per_seat": pricePerSeat,
        "available_seats": availableSeats,
        "status": status,
        "from_latitude": fromLatitude,
        "from_longitude": fromLongitude,
        "to_latitude": toLatitude,
        "to_longitude": toLongitude,
      };
}

class BookVehicle {
  int id;
  String model;
  String carNumber;
  int totalSeats;
  BookCarColor color;

  BookVehicle({
    required this.id,
    required this.model,
    required this.carNumber,
    required this.totalSeats,
    required this.color,
  });

  factory BookVehicle.empty() => BookVehicle(
        id: 0,
        model: "",
        carNumber: "",
        totalSeats: 0,
        color: BookCarColor.empty(),
      );

  factory BookVehicle.fromJson(Map<String, dynamic> json) => BookVehicle(
        id: _asInt(json["id"]),
        model: json["model"]?.toString() ?? "",
        carNumber: json["car_number"]?.toString() ?? "",
        totalSeats: _asInt(json["total_seats"]),
        color: json["color"] is Map<String, dynamic>
            ? BookCarColor.fromJson(json["color"])
            : BookCarColor.empty(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "car_number": carNumber,
        "total_seats": totalSeats,
        "color": color.toJson(),
      };
}

class BookCarColor {
  String titleUz;
  String titleRu;
  String titleEn;
  String colorCode;

  BookCarColor({
    required this.titleUz,
    required this.titleRu,
    required this.titleEn,
    required this.colorCode,
  });

  factory BookCarColor.empty() =>
      BookCarColor(titleUz: "", titleRu: "", titleEn: "", colorCode: "");

  factory BookCarColor.fromJson(Map<String, dynamic> json) => BookCarColor(
        titleUz: json["title_uz"]?.toString() ?? "",
        titleRu: json["title_ru"]?.toString() ?? "",
        titleEn: json["title_en"]?.toString() ?? "",
        colorCode: json["color_code"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title_uz": titleUz,
        "title_ru": titleRu,
        "title_en": titleEn,
        "color_code": colorCode,
      };
}
