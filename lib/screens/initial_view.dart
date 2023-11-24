import 'package:flutter/material.dart';
import 'package:flutter_code_challenge/network_keys/open_weather.dart';
import 'package:flutter_code_challenge/screens/home.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../network_services/weather_values.dart';

const apiKey = weatherKey;

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  String val = 'Locating...';
  @override
  void initState() {
    getLocationData();
    super.initState();
  }

  void getLocationData() async {
    var weatherData = await WeatherModel().getLocationWeather();
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (weatherData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Home(locationWeather: weatherData);
            },
          ),
        );
      } else {
        setState(() {
          val = 'Sorry. Something went wrong';
        });

        Center(
          child: Text(val),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/fallback_fog.png'),
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.36,
            ),
            SizedBox(
              height: 32.0,
              child: Text(
                val.toUpperCase(),
                style: const TextStyle(letterSpacing: 1.2, color: Colors.white),
              ),
            ),
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 44.0,
            )
          ],
        )),
      ),
    );
  }
}
