import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_code_challenge/utilities/constants.dart';
import 'package:flutter_code_challenge/utilities/datetime_object.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../network_keys/open_weather.dart';
import '../network_services/weather_values.dart';
import '../ui_elements/home_bottom_card.dart';

class SavedLocationDetail extends StatefulWidget {
  const SavedLocationDetail({super.key, required this.cityName, required this.searchExt});
  final String cityName;
  final String searchExt;

  @override
  State<SavedLocationDetail> createState() => _SavedLocationDetailState();
}

class _SavedLocationDetailState extends State<SavedLocationDetail> {
  List<String> imageUrls = [];
  WeatherModel weatherModel = WeatherModel();
  Random random = Random();
  String searchCondition = '';
  late String imgCondition = '';
  int imageNumber = 3;

  // Function to fetch data
  Future<Map<String, dynamic>> fetchData() async {
    var url = '$owMapURL?q=${widget.cityName}&appid=$apiKey&units=metric';
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      var decodedData = jsonDecode(data);
      return decodedData;
    } else {
      debugPrint('Weather Network call failed: ${response.statusCode}');
      throw Exception('Failed to load data');
    }
  }

  Widget locationData({required double height, required double width}) {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String condition = snapshot.data!['weather'][0]['description'].toString();
            String iconUrl = snapshot.data!['weather'][0]['icon'].toString();
            double temperature = snapshot.data!['main']['temp'].toDouble();
            var humidity = snapshot.data!['main']['humidity'].toDouble();
            double windSpeed = snapshot.data!['wind']['speed'].toDouble();
            double feelsLike = snapshot.data!['main']['feels_like'].toDouble();
            var id = snapshot.data!['weather'][0]['id'];
            searchCondition = weatherModel.setImgSearchValue(id);
            imgCondition = weatherModel.fallbackImgVal(id);
            return locationDetailsLayout(height, iconUrl, condition, temperature, humidity, windSpeed, feelsLike);
          }
        });
  }

  Expanded locationDetailsLayout(
      double height, String iconUrl, String condition, double temperature, humidity, double windSpeed, double feelsLike) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: height * 0.04,
          ),
          Column(
            children: [
              const DateObject().animate(delay: const Duration(milliseconds: 700)).then().fade(begin: .0, end: .9),
              SizedBox(
                height: height * 0.37,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: height * 0.02,
                      child: SizedBox(
                        height: 96,
                        child: Image.network('http://openweathermap.org/img/w/$iconUrl.png', fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: height * 0.1,
                      child: Text(
                        condition,
                        style: kDateStyle,
                      ),
                    ),
                    Positioned(
                      top: height * 0.13,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(temperature.toStringAsFixed(0), style: kTempStyle),
                          Text('\u2103', style: kAppbarText.copyWith(height: 4.6, fontSize: 22)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              details(humidity, windSpeed, feelsLike)
                  .animate(delay: const Duration(milliseconds: 1200))
                  .then()
                  .slide(curve: Curves.easeInOut)
                  .fade(begin: .0, end: .9),
            ],
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Container(
                    height: 180,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: Colors.white.withOpacity(0.20)),
                    child: HomeBottomCard(cityName: widget.cityName))
                .animate(delay: const Duration(milliseconds: 1200))
                .then()
                .slide(
                  curve: Curves.easeIn,
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                )
                .fade(
                  begin: .0,
                  end: 1,
                ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Padding details(humidity, double windSpeed, double feelsLike) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.waterOutline, color: Colors.white, size: 40),
              const Text('HUMIDITY', style: kAppbarText),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(humidity.toString(), style: kAppbarText),
                  const Text(
                    '%',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.weatherWindy, color: Colors.white, size: 40),
              const Text('WIND', style: kAppbarText),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(windSpeed.toString(), style: kAppbarText),
                  const Text(
                    'km/h',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.thermometerLow, color: Colors.white, size: 40),
              const Text('FEELS LIKE', style: kAppbarText),
              Text('${feelsLike.toString()}\u00b0', style: kAppbarText)
            ],
          ),
        ],
      ),
    );
  }

  generateSearchValue() {
    int ranNum = random.nextInt(9);
    setState(() {
      imageNumber = ranNum + 1;
      debugPrint('image number: $imageNumber');
    });
  }

  // Function to set the background image
  Future<void> fetchBackgroundImg() async {
    const String unsplashAccessKey = 'mllLtD0lpoxf3XFwdQ3PiZ77XpHJk8cASONtFr1aPQQ';
    const String endpoint = 'search/photos';
    const String baseUrl = 'https://api.unsplash.com/';
    String valToSearch = '${widget.cityName} ${widget.searchExt}';
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint?query=$valToSearch&client_id=$unsplashAccessKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final List<String> urls = List<String>.from(results.map((result) => result['urls']['regular']));
        debugPrint('IMAGE URLS ${urls.length}');

        setState(() {
          imageUrls = urls;
        });
      } else {
        debugPrint('Response Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBackgroundImg();
    generateSearchValue();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(widget.cityName),
      ),
      body: Container(
        height: height,
        width: width,
        decoration: imageUrls.isEmpty
            ? BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/fallback_none.png'),
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                  fit: BoxFit.cover,
                ),
              )
            : imageUrls.isEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/fallback_$imgCondition.png'),
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      fit: BoxFit.cover,
                    ),
                  )
                : BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrls[imageNumber]),
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      fit: BoxFit.cover,
                    ),
                  ),
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            locationData(height: height, width: width),
          ]),
        ),
      ),
    );
  }
}
