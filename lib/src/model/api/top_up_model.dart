import 'dart:convert';

TopUpModel topUpModelFromJson(String str) => TopUpModel.fromJson(json.decode(str));

String topUpModelToJson(TopUpModel data) => json.encode(data.toJson());

class TopUpModel {
  String status;
  String message;
  TransactionModel? transaction; // make nullable

  TopUpModel({
    required this.status,
    required this.message,
    this.transaction,
  });

  factory TopUpModel.fromJson(Map<String, dynamic> json) => TopUpModel(
    status: json["status"] ?? "failed",
    message: json["message"] ?? "",
    transaction: json["transaction"] != null
        ? TransactionModel.fromJson(json["transaction"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "transaction": transaction?.toJson(),
  };
}

class TransactionModel {
  int id;
  String type;
  String amount;
  String balanceBefore;
  String balanceAfter;
  String? reason;
  String? status;
  int? seatsBooked;
  String? totalPrice;
  DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.reason,
    this.status,
    this.seatsBooked,
    this.totalPrice,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final booking = json["booking"] is Map ? json["booking"] as Map : null;
    return TransactionModel(
      id: json["id"] ?? 0,
      type: json["type"] ?? "",
      amount: json["amount"] ?? "",
      balanceBefore: json["balance_before"] ?? "",
      balanceAfter: json["balance_after"] ?? "",
      reason: json["reason"]?.toString(),
      status: json["status"]?.toString(),
      seatsBooked: (booking?["seats_booked"] as num?)?.toInt(),
      totalPrice: booking?["total_price"]?.toString(),
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "amount": amount,
    "balance_before": balanceBefore,
    "balance_after": balanceAfter,
    "reason": reason,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
  };
}
