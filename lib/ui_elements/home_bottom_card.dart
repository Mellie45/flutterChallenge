import 'dart:async';
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import '../network_keys/open_weather.dart';
import '../utilities/constants.dart';

class HomeBottomCard extends StatefulWidget {
  final String cityName;
  const HomeBottomCard({super.key, required this.cityName});

  @override
  State<HomeBottomCard> createState() => _HomeBottomCardState();
}

class _HomeBottomCardState extends State<HomeBottomCard> {
  var now = DateTime.now();
  List dailyForecastData = [];

  Future<List<ForecastDataTest>> getMappedForecast() async {
    const apiKey = weatherKey;
    String city = widget.cityName;
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast/?q=$city&appid=$apiKey&cnt=4&units=metric');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> mappedWeatherData = json.decode(response.body)['list'];
      List<ForecastDataTest> forecasts = await Future.wait(mappedWeatherData.map((weatherDatum) => getMappedForecastData(weatherDatum)));

      return forecasts;
    } else {
      throw Exception('Fetch forecast data failed');
    }
  }

  Future<ForecastDataTest> getMappedForecastData(Map<String, dynamic> weatherData) async {
    return ForecastDataTest.fromJson(weatherData);
  }

  setForecastDate(int day) {
    DateTime dateTime = DateTime.now();
    var date = dateTime.add(Duration(days: day));
    String formatDate = DateFormat('EE dd').format(date);
    return Text(formatDate, style: kForecastPanel.copyWith(fontSize: 18));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ForecastDataTest>>(
      future: getMappedForecast(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ForecastDataTest> forecasts = snapshot.data!;
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                return Card(
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        setForecastDate(index + 1),
                        Positioned(
                          top: 14,
                          child: Image.network('https://openweathermap.org/img/wn/${snapshot.data![index].iconUrl}@2x.png',
                              height: 64.0, color: Colors.white),
                        ),
                        Positioned(
                          top: 64,
                          child: Text('${snapshot.data![index].temperature.toStringAsFixed(1)}\u00b0',
                              style: kForecastPanel.copyWith(fontSize: 18)),
                        ),
                        Positioned(
                          bottom: 1,
                          child: Text('${snapshot.data![index].windSpeed.toString()}\nkm/h', style: kForecastPanel),
                        ),
                      ],
                    ),
                  ),
                );
              });
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
