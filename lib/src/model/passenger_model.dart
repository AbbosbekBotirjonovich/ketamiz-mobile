class PassengerModel {
  String fullName;
  String phoneNumber;

  /// Pickup point chosen by/for this passenger. Sent to the driver so they
  /// know where to collect each passenger. Stored as strings to match the
  /// booking payload format.
  String latitude;
  String longitude;

  PassengerModel({
    required this.fullName,
    this.phoneNumber = "",
    this.latitude = "",
    this.longitude = "",
  });

  bool get hasLocation => latitude.isNotEmpty && longitude.isNotEmpty;
}
