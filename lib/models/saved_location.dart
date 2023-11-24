class SavedLocation {
  final String cityName;

  SavedLocation({required this.cityName});

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      cityName: json['cityName'],
    );
  }
}
