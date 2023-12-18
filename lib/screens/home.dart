import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_code_challenge/network_services/weather_values.dart';
import 'package:flutter_code_challenge/screens/about_this_app.dart';
import 'package:flutter_code_challenge/screens/saved_locations.dart';
import 'package:flutter_code_challenge/ui_elements/home_bottom_card.dart';
import 'package:flutter_code_challenge/utilities/constants.dart';
import 'package:flutter_code_challenge/utilities/datetime_object.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

final Uri _url = Uri.parse('http://www.baaadkitty.uk');

class Home extends StatefulWidget {
  final dynamic locationWeather;
  const Home({super.key, this.locationWeather});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int temperature;
  late int feelsLike;
  late String cityName;
  late String searchCondition;
  late String imgCondition;
  late dynamic humidity;
  late double windSpeed;
  late String weatherDescription;
  late String iconUrl;
  late String userRef;
  WeatherModel weatherModel = WeatherModel();
  Random random = Random();
  int imageNumber = 3;

  List<String> imageUrls = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var uuid = const Uuid();

  Future<void> fetchBackgroundImg() async {
    const String unsplashAccessKey = 'mllLtD0lpoxf3XFwdQ3PiZ77XpHJk8cASONtFr1aPQQ';
    const String endpoint = 'search/photos';
    const String baseUrl = 'https://api.unsplash.com/';
    String search = '$cityName $searchCondition';

    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint?query=$search&client_id=$unsplashAccessKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        final List<String> urls = List<String>.from(results.map((result) => result['urls']['regular']));
        setState(() {
          imageUrls = urls;
          debugPrint(imageUrls.length.toString());
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
    weatherDetails(widget.locationWeather);
    fetchBackgroundImg();
    loadOrGenerateUserReference();
    generateSearchValue();
  }

  Future<void> launchBaaadKittyUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url. Please check your connection');
    } else {}
  }

  void weatherDetails(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        feelsLike = 0;
        cityName = '';
        humidity = 0;
        weatherDescription = '';
        windSpeed = 0.0;
        iconUrl = '';
        return;
      }
      var temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      var feels = weatherData['main']['feels_like'];
      feelsLike = feels.toInt();
      cityName = weatherData['name'];
      humidity = weatherData['main']['humidity'];
      windSpeed = weatherData['wind']['speed'];
      weatherDescription = weatherData['weather'][0]['description'];
      var condition = weatherData['weather'][0]['id'];
      iconUrl = weatherData['weather'][0]['icon'];
      searchCondition = weatherModel.setImgSearchValue(condition);
      imgCondition = weatherModel.fallbackImgVal(condition);
    });
  }

  Future<void> loadOrGenerateUserReference() async {
    String newReference = '';
    String? storedReference = await getStoredReference();

    if (storedReference != null) {
      setState(() {
        userRef = storedReference;
      });
    } else {
      newReference = generateUniqueReference();

      await storeReferenceLocally(newReference);

      setState(() {
        userRef = newReference;
      });
    }
    addUserToFirestore(newReference);
  }

  String generateUniqueReference() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Future<void> storeReferenceLocally(String reference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_reference', reference);
  }

  Future<String?> getStoredReference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_reference');
  }

  Future<void> addUserToFirestore(String reference) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      if (reference.isNotEmpty) {
        String userID = reference;
        await users.doc(userID).set({
          'reference': reference,
        });
      }
      debugPrint('User added to Firestore successfully!');
    } catch (e) {
      debugPrint('Error adding user to Firestore: $e');
    }
  }

  generateSearchValue() {
    int ranNum = random.nextInt(9);
    setState(() {
      imageNumber = ranNum + 1;
      debugPrint('image number: $imageNumber');
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Icon(MdiIcons.mapMarker, color: Colors.white, size: 28),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: false,
        title: Text(cityName),
      ),
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).primaryColor,
        child: ListView(
          children: [
            ListTile(
              trailing: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onTap: () => Navigator.pop(context),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                accountName: Text('Mel Colton'),
                accountEmail: Text('Developer'),
                currentAccountPicture: CircleAvatar(
                  foregroundImage: AssetImage('assets/headshot.png'),
                ),
              ),
            ),
            ListTile(
                leading: Icon(MdiIcons.cloudArrowRightOutline, color: Colors.white, size: 28),
                title: const Text(
                  'Saved Locations',
                  style: kDrawerText,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedLocationsScreen()));
                }),
            const Divider(thickness: 1.0, color: Colors.white, indent: 8.0),
            ListTile(
              leading: Icon(MdiIcons.informationOutline, color: Colors.white, size: 28),
              title: const Text(
                'About this app',
                style: kDrawerText,
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutThisApp()));
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.accountCardOutline, color: Colors.white, size: 28),
              title: const Text(
                'About Baaad Kitty',
                style: kDrawerText,
              ),
              onTap: () => launchBaaadKittyUrl(),
            ),
          ],
        ),
      ),
      body: Container(
        height: height,
        width: width,
        decoration: imageUrls.isEmpty
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 22.0),
              Animate(effects: const [
                FadeEffect(duration: Duration(milliseconds: 800)),
              ], child: const DateObject()),
              SizedBox(
                height: height * 0.3,
                width: width,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: height * 0.02,
                      child: SizedBox(
                        height: 96,
                        child: Image.network(
                          'http://openweathermap.org/img/w/$iconUrl.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: height * 0.1,
                      child: Text(weatherDescription, style: kDateStyle),
                    ),
                    Positioned(
                      top: height * 0.13,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(temperature.toString(), style: kTempStyle),
                          Text('\u2103', style: kAppbarText.copyWith(height: 6)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: conditions()
                      .animate(delay: const Duration(milliseconds: 1200))
                      .then()
                      .slide(curve: Curves.easeInOut)
                      .fade(begin: .0, end: .9)),
              Container(
                      height: 180,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: Colors.white.withOpacity(0.20)),
                      child: HomeBottomCard(
                        cityName: cityName,
                      ))
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
              const SizedBox(height: 22.0),
            ],
          ),
        ),
      ),
    );
  }

  Padding conditions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.waterPercent, color: Colors.white, size: 40),
              const Text('HUMIDITY', style: kAppbarText),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(humidity.toString(), style: kAppbarText),
                  const Text('%', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, height: 1.4, color: Colors.white)),
                ],
              ),
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
                    ' km/h',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0, height: 1.4, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(MdiIcons.thermometerLow, color: Colors.white, size: 40),
              const Text('FEELS LIKE', style: kAppbarText),
              Text('${feelsLike.toString()}\u00b0', style: kAppbarText),
            ],
          ),
        ],
      ),
    );
  }
}
