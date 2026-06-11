class CreditCardModel {
  CreditCardModel({
    this.id,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    this.isDefault = false,
    this.status = "",
    this.cardKey = "",
    this.phone = "",
    this.balance,
  });

  int? id;
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isDefault;
  String status;

  /// The card's verification key (the API's `card_id`), used to verify it.
  String cardKey;

  /// Phone number linked to the card (where the SMS code is sent).
  String phone;
  double? balance;

  factory CreditCardModel.fromJson(Map<String, dynamic> json) => CreditCardModel(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ""),
    cardNumber: json["card_number"] ?? json["pan"] ?? "",
    expiryDate: json["expiry"] ?? "",
    cardHolderName: json["card_holder"] ?? json["holder_name"] ?? "",
    cvvCode: "", // Usually not returned by API
    balance: json["balance"] != null ? double.tryParse(json["balance"].toString()) : null,
  );
}
