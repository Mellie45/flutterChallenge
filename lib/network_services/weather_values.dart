import 'package:flutter_code_challenge/network_keys/open_weather.dart';
import 'package:flutter_code_challenge/network_services/location.dart';
import 'package:flutter_code_challenge/network_services/network_helper.dart';

const apiKey = weatherKey;
const openWeatherMapURL = owMapURL;
const searchUrl = openWeatherForecast;

class WeatherModel {
  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    var url = '$owMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();

    return weatherData;
  }

  Future<dynamic> updateLocationWeather(String cityName) async {
    var url = '$owMapURL?q=$cityName&appid=$apiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();

    return weatherData;
  }

  String setImgSearchValue(int condition) {
    if (condition < 300) {
      return 'Thunderstorm';
    } else if (condition == 301) {
      return 'in the rain';
    } else if (condition < 400) {
      return 'sunshine';
    } else if (condition < 600) {
      return 'in the rain';
    } else if (condition < 700) {
      return 'in the snow';
    } else if (condition < 701) {
      return 'in the fog';
    } else if (condition < 771) {
      return 'When it\'s windy';
    } else if (condition < 800) {
      return 'When it\'s cloudy';
    } else if (condition == 301) {
      return 'in the rain';
    } else if (condition == 800) {
      return 'sunshine';
    } else if (condition <= 804) {
      return 'When it\'s cloudy';
    } else {
      return '';
    }
  }

  String fallbackImgVal(int condition) {
    if (condition < 300) {
      return 'storm';
    } else if (condition == 301) {
      return 'rain';
    } else if (condition < 400) {
      return 'sun';
    } else if (condition < 600) {
      return 'rain';
    } else if (condition < 700) {
      return 'snow';
    } else if (condition < 701) {
      return 'fog';
    } else if (condition < 771) {
      return 'wind';
    } else if (condition < 800) {
      return 'cloud';
    } else if (condition == 301) {
      return 'rain';
    } else if (condition == 800) {
      return 'sun';
    } else if (condition <= 804) {
      return 'cloud';
    } else {
      return 'none';
    }
  }
}
