import 'dart:convert';

class ForecastDataTest {
  final double temperature;
  final double windSpeed;
  final String iconUrl;
  final String? cityName;

  ForecastDataTest({
    required this.temperature,
    required this.iconUrl,
    required this.windSpeed,
    this.cityName,
  });

  factory ForecastDataTest.fromJson(Map<String, dynamic> json) {
    return ForecastDataTest(
      temperature: json['main']['temp'].toDouble(),
      iconUrl: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}

void main() {
  String jsonString = '''{
    // ... (your JSON data)
  }''';

  Map<String, dynamic> jsonData = json.decode(jsonString);

  List<dynamic> weatherList = jsonData['list'];

  List<ForecastDataTest> forecastDataList = [];

  for (var weatherData in weatherList) {
    ForecastDataTest forecastData = ForecastDataTest.fromJson(weatherData);
    forecastDataList.add(forecastData);
  }
}
