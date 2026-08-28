class ShelterModel {
  final String id;
  final double latitude;
  final double longitude;
  final String? streetName;
  final String? streetNumber;
  final int? capacity;

  const ShelterModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.streetName,
    this.streetNumber,
    this.capacity,
  });
}