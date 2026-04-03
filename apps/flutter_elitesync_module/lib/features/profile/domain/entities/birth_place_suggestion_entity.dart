class BirthPlaceSuggestionEntity {
  const BirthPlaceSuggestionEntity({
    required this.label,
    required this.address,
    required this.city,
    required this.district,
    required this.lat,
    required this.lng,
  });

  final String label;
  final String address;
  final String city;
  final String district;
  final double lat;
  final double lng;
}
