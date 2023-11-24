import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_code_challenge/models/saved_location.dart';
import 'package:flutter_code_challenge/screens/saved_location_detail_screen.dart';
import 'package:flutter_code_challenge/utilities/constants.dart';
import 'package:flutter_code_challenge/utilities/globals.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network_keys/open_weather.dart';
import '../network_services/network_helper.dart';
import '../network_services/weather_values.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  WeatherModel weatherModel = WeatherModel();
  String cityName = '';
  late String userRef;
  String searchRef = '';
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<SavedLocation>> futureData;
  List<SavedLocation> filteredLocationList = [];

  Future<String?> getStoredRef() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('user_reference')!.isNotEmpty) {
      setState(() {
        userRef = prefs.getString('user_reference')!;
      });
    }
    return prefs.getString('user_reference');
  }

  Future<List<SavedLocation>> locationsFromFirebase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('users').doc(userRef).collection('cities').get();
    List<SavedLocation> locationList = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
      SavedLocation location = SavedLocation.fromJson(document.data());
      locationList.add(location);
    }
    if (searchRef == '') {
      return locationList;
    } else {
      return locationList.where((element) => element.cityName.trim().contains(searchRef)).toList();
    }
  }

  Future<void> updateLocationsFromFirebase() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('users').doc(userRef).collection('cities').get();
    List<SavedLocation> locationList = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in snapshot.docs) {
      SavedLocation location = SavedLocation.fromJson(document.data());
      locationList.add(location);
    }

    if (searchRef == '') {
      setState(() {
        filteredLocationList = locationList;
      });
    } else {
      setState(() {
        filteredLocationList = locationList.where((city) => city.cityName.trim().contains(searchRef)).toList();
      });
    }
  }

  Future<List<SavedLocation>> getFutureData() {
    return locationsFromFirebase();
  }

  Future<void> writeToDatabase() async {
    await firestore.collection('users').doc(userRef).collection('cities').doc(cityName).set({'cityName': cityName});
    setState(() {
      futureData = getFutureData();
    });
  }

  Future<void> deleteFromDatabase(String cityName) async {
    await firestore.collection('users').doc(userRef).collection('cities').doc(cityName).delete();
    setState(() {
      futureData = getFutureData();
    });
  }

  @override
  void initState() {
    super.initState();
    getStoredRef().then((value) {
      setState(() {
        userRef = value!;
        futureData = locationsFromFirebase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: locationsKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: false,
        //automaticallyImplyLeading: false,
        title: const Text('Saved Locations'),
        actions: [
          IconButton(
            icon: Transform.scale(
              scaleX: -1,
              child: searchRef != '' ? Icon(MdiIcons.close, size: 33) : Icon(MdiIcons.magnify, size: 33),
            ),
            onPressed: () {
              if (searchRef == '') {
                _search.clear();
                setState(() {
                  searchRef = '';
                });
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: const Text('Find your city'),
                          content: TextField(
                            controller: _search,
                            style: const TextStyle(fontSize: 22),
                            decoration: const InputDecoration(labelText: 'City Name'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  setState(() {
                                    searchRef = _search.text.trim();
                                    locationsFromFirebase();
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Search')),
                          ],
                        ));
              } else {
                setState(() {
                  searchRef = '';
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(gradient: kLinearGradientPurple),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 18.0),
              Expanded(
                child: FutureBuilder(
                  future: locationsFromFirebase(),
                  builder: (context, AsyncSnapshot<List<SavedLocation>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: SizedBox(
                              height: 60.0,
                              width: 60.0,
                              child: SpinKitChasingDots(
                                color: Colors.white,
                              )));
                    } else if (snapshot.hasError) {
                      locationsKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text('${snapshot.error}'),
                          showCloseIcon: true,
                        ),
                      );
                      return Container();
                    } else {
                      filteredLocationList = snapshot.data!;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredLocationList.length,
                          itemBuilder: (context, index) {
                            SavedLocation location = filteredLocationList[index];
                            return Dismissible(
                              key: Key(location.cityName),
                              onDismissed: (direction) async {
                                setState(() {
                                  deleteFromDatabase(location.cityName);
                                });
                              },
                              background: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: Colors.red),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 18.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: width,
                                height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
                                  child: cityTile(location, index),
                                ),
                              ),
                            ).animate(delay: const Duration(milliseconds: 400)).then().slide(curve: Curves.easeIn).fade(
                                  begin: .0,
                                  end: 1,
                                );
                          });
                    }
                  },
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    width: width * 0.86,
                    height: 70,
                    child: TextButton.icon(
                      onPressed: () {
                        _search.clear();
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: const Text('Find your city'),
                                  content: TextField(
                                    controller: _search,
                                    style: const TextStyle(fontSize: 22),
                                    decoration: const InputDecoration(labelText: 'City Name'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          searchRef = '';
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          searchRef = '';
                                        });
                                        cityName = _search.text.trim();
                                        writeToDatabase();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ));
                      },
                      icon: Icon(MdiIcons.plusCircleOutline, color: Colors.white, size: 32),
                      label: const Text('Add new', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> updateLocationWeather(String cityName) async {
    var url = '$owMapURL?q=$cityName&appid=$apiKey&units=metric';
    NetworkHelper networkHelper = NetworkHelper(url);
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  // Function to fetch data
  Future<Map<String, dynamic>> fetchData(SavedLocation location) async {
    var url = '$owMapURL?q=${location.cityName}&appid=$apiKey&units=metric';
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

  Widget cityTile(SavedLocation location, int index) {
    return FutureBuilder(
      future: fetchData(location),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(
            color: Colors.white,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          double temperature = snapshot.data!['main']['temp'].toDouble();
          int humidity = snapshot.data!['main']['humidity'].toInt();
          String condition = snapshot.data!['weather'][0]['description'].toString();
          double windSpeed = snapshot.data!['wind']['speed'].toDouble();
          String iconUrl = snapshot.data!['weather'][0]['icon'].toString();
          var locID = snapshot.data!['weather'][0]['id'];
          String searchExtension = weatherModel.setImgSearchValue(locID);

          return GestureDetector(
            onTap: () {
              if (mounted) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SavedLocationDetail(cityName: location.cityName, searchExt: searchExtension)));
              }
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: Colors.white.withOpacity(0.20)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(location.cityName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                        Text(condition, style: const TextStyle(color: Colors.white, fontSize: 18)),
                        const SizedBox(height: 14.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Humidity ${humidity.toString()}', style: const TextStyle(color: Colors.white)),
                            Text('Wind ${windSpeed.toStringAsFixed(1)} km/h',
                                style: const TextStyle(
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 78,
                          child: Image.network(
                            'http://openweathermap.org/img/w/$iconUrl.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(temperature.toStringAsFixed(0),
                                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w600)),
                            const Text(' \u2103',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, height: 2)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
