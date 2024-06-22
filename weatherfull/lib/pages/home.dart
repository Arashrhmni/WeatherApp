import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:weatherfull/apikeys.dart';
import 'package:weatherfull/pages/weather.dart';
import '../allsettings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;

List<List<dynamic>> favourites = [];
Widget? favouriteList;

Future<List<String>> getWeatherData(List<double> latlong) async {
  WeatherFactory wf = WeatherFactory(openWeather);
  Weather w = await wf.currentWeatherByLocation(latlong[0], latlong[1]);
  return [
    getTemperatureForWeather(w)['current']??'', 
    w.weatherIcon??'50d'
  ];
}

Future<List<String>> getWeatherDataForCurrentLocation() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  String uri = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleAPIKey';
  var response = await http.get(Uri.parse(uri));
  String cityName = '';
  if (response.statusCode != 200) {
    return [
      '', 
      'No connection to the internet', 
      '50d', 
      position.latitude.toString(), 
      position.longitude.toString()
    ];
  } else {
    var data = response.body;
    var jsonData = jsonDecode(data);
    cityName = jsonData['plus_code']['compound_code'].split(' ').sublist(1).join(' ');
  }

  WeatherFactory wf = WeatherFactory(openWeather);
  Weather w = await wf.currentWeatherByLocation(position.latitude, position.longitude);
  return [
    getTemperatureForWeather(w)['current']??'', 
    cityName, w.weatherIcon??'50d', 
    position.latitude.toString(), 
    position.longitude.toString()
  ];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget favouriteContainer() {
    List<dynamic> favourites = Hive.box('favourites').get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();
    // Now build the list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favourites.length,
      itemBuilder: (context, index) {
        return FutureBuilder<List<String>>(
          future: getWeatherData(favourites[index].sublist(1).cast<double>()),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if (snapshot.connectionState == ConnectionState.done) {
              favourites[index][3] = data![0];
              favourites[index][4] = data[1];
              Hive.box('favourites').put('favourites', favourites);
              return ListTile(
                leading: Text(
                  data[0],
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text'],
                    fontSize: 20.0 * heightFactor,
                  ),
                ),
                title: Text(
                  favourites[index][0],
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text'],
                    fontWeight: FontWeight.bold
                  ),
                ),
                trailing: Image.network(
                  'http://openweathermap.org/img/wn/${data[1]}@2x.png', 
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                onTap: () async {
                  var result = await Navigator.pushNamed(
                    context,
                    '/weather',
                    arguments: {
                      'cityLatLong': [favourites[index][1], favourites[index][2]],
                      'cityName': favourites[index][0],
                    }
                  );
                  if (result == 'reload') {
                    setState(() {});
                  }
                },
              );
            } else {
              Widget icon = favourites[index].length == 5 ? Image.network(
                  colorBlendMode: BlendMode.overlay,
                  'http://openweathermap.org/img/wn/${favourites[index][4]}@2x.png', 
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }
                ) : 
                const Text('');
              String temp = favourites[index].length == 5 ? favourites[index][3] : '';
              return ListTile(
                leading: Text(
                  temp,
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                    fontSize: 20.0 * heightFactor,
                  ),
                ),
                title: Text(
                  favourites[index][0],
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                    fontWeight: FontWeight.bold
                  ),
                ),
                trailing: icon,
                onTap: () async {},
              );
            }
          },
        );
      }
    );
  }

  

  @override
  void initState() {
    super.initState();
    favouriteList = favouriteContainer();
  }

  @override
  Widget build(BuildContext context) {
  

    previousRoute = '/homepage';

    var favList = Hive.box('favourites');
    favourites = favList.get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();

    List<String> currentLocationData = [];

    DateTime now = DateTime.now();

    
    Widget widg = FutureBuilder<List<String>>(
      future: getWeatherDataForCurrentLocation(),
      builder: (context, snapshot) {
        Map<String, dynamic> lastLocation = Hive.box('lastLocation').get('lastLocation', defaultValue: <String, dynamic>{}).cast<String, dynamic>();
        if (snapshot.connectionState == ConnectionState.done) {
          currentLocationData = snapshot.data!;
          Hive.box('lastLocation').put('lastLocation', {
            'cityName': currentLocationData[1],
            'temperature': currentLocationData[0],
            'icon': currentLocationData[2],
            'latlong': [currentLocationData[3], currentLocationData[4]],
          });
          return Container(
            margin: EdgeInsets.only(
              top: heightFactor * 10.0, 
              bottom: heightFactor * 10.0, 
              left: widthFactor * 10.0, 
              right: widthFactor * 10.0
            ),
            padding: EdgeInsets.only(
              top: heightFactor * 10.0, 
              bottom: heightFactor * 10.0, 
              left: widthFactor * 10.0, 
              right: widthFactor * 10.0
            ),
            decoration: BoxDecoration(
              color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
              border: Border.all(
                color: themeData[currentSettings['theme']]!['accent']!,
                width: 2.0 * widthFactor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor, 
                    bottom: 5.0 * heightFactor
                  ),
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['accent'],
                ),
                ListTile(
                  leading: Text(
                    currentLocationData[0],
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontSize: 20.0 * heightFactor,
                    ),
                  ),
                  title: Text(
                    currentLocationData[1],
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  trailing: Image.network(
                    'http://openweathermap.org/img/wn/${currentLocationData[2]}@2x.png',
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  onTap: () async {
                    var result = await Navigator.pushNamed(
                      context,
                      '/weather',
                      arguments: {
                        'cityLatLong': [double.parse(currentLocationData[3]), double.parse(currentLocationData[4])],
                        'cityName': currentLocationData[1],
                      }
                    );
                    if (result == 'reload') {
                      setState(() {});
                    }
                  },
                )
              ],
            ),
          );
        } else {
          Widget? listTile = const CircularProgressIndicator();
          if (lastLocation.isNotEmpty) {
            listTile = ListTile(
              leading: Text(
                lastLocation['temperature'],
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  fontSize: 20.0 * heightFactor,
                ),
              ),
              title: Text(
                lastLocation['cityName'],
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  fontWeight: FontWeight.bold
                ),
              ),
              trailing: Image.network(
                'http://openweathermap.org/img/wn/${lastLocation['icon']}@2x.png',
                colorBlendMode: BlendMode.overlay,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              onTap: () {},
            );
          }
          return Container(
            margin: EdgeInsets.only(
              top: 10.0 * heightFactor, 
              bottom: 10.0 * heightFactor, 
              left: 10.0 * widthFactor, 
              right: 10.0 * widthFactor
            ),
            padding: EdgeInsets.only(
              top: 10.0 * heightFactor, 
              bottom: 10.0 * heightFactor, 
              left: 10.0 * widthFactor, 
              right: 10.0 * widthFactor
            ),
            decoration: BoxDecoration(
              color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
              border: Border.all(
                color: themeData[currentSettings['theme']]!['accent']!,
                width: 2.0 * widthFactor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor, 
                    bottom: 5.0 * heightFactor, 
                  ),
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['accent'],
                ),
                listTile
              ],
            ),
          );
        }
      },
    );

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ?? false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          backgroundColor: themeData[currentSettings['theme']]!['accent'],
          foregroundColor: themeData[currentSettings['theme']]!['text'],
          child: const Icon(Icons.search),
        ),
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          shadowColor: themeData[currentSettings['theme']]!['shadow'],
          elevation: 4.0,
          leading: Container(
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/contact');
              },
              icon: Icon(
                Icons.contact_page_rounded, 
                color: themeData[currentSettings['theme']]!['text'], 
                size: 30.0 * heightFactor,
              )
            ),
          ),
          title: Center(
            child: Text(
              'WeatherFull',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.only(
                right: 15.0 * widthFactor
              ),
              icon: Icon(
                Icons.settings_sharp,
                size: 30.0 * heightFactor,
              ),
              color: themeData[currentSettings['theme']]!['flat_icons'],
              onPressed: () async {
                var result = await Navigator.pushNamed(context, '/settings');
                if (result == 'themeChanged') {
                  setState(() {});
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              top: 10.0 * heightFactor, 
              bottom: 10.0 * heightFactor, 
              left: 10.0 * widthFactor, 
              right: 10.0 * widthFactor
            ),
            padding: EdgeInsets.only(
              top: 10.0 * heightFactor, 
              bottom: 10.0 * heightFactor, 
              left: 10.0 * widthFactor, 
              right: 10.0 * widthFactor
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 10.0 * widthFactor, 
                        top: 10.0 * heightFactor, 
                        bottom: 10.0 * heightFactor, 
                        right: 5.0 * widthFactor
                      ),
                      width: deviceWidth * 0.45,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(150, 255, 255, 255)),
                          elevation: WidgetStateProperty.all(4.0),
                          shadowColor: WidgetStateProperty.all<Color>(themeData[currentSettings['theme']]!['shadow']!),
                          shape: WidgetStateProperty.all<CircleBorder>(const CircleBorder()),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        child: Image.asset('assets/images/logo.png')
                      ),
                    ),
                    Container(
                      width: deviceWidth * 0.4,
                      margin: EdgeInsets.only(
                        top: 10.0 * heightFactor, 
                        bottom: 10.0 * heightFactor, 
                        right: 10.0 * widthFactor, 
                        left: 5.0 * widthFactor
                      ),
                      child: Column(
                        children: [
                          Text(
                            makeReadableTIme(now), 
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!,
                              fontSize: 32.0 * heightFactor,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          Container(
                            height: 2.0 * heightFactor,
                            margin: EdgeInsets.only(
                              left: 5.0 * widthFactor, 
                              right: 5.0 * widthFactor
                            ),
                            color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.2),
                          ),
                          Text(
                            weekdays[now.weekday],
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!,
                              fontSize: 24.0 * heightFactor,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          Text(
                            makeReadableDate(now), 
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!,
                              fontSize: 18.0 * heightFactor,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      )
                    )
                  ],
                ),
                widg,
                Container(
                  margin: EdgeInsets.only(
                    top: 10.0 * heightFactor, 
                    bottom: 10.0 * heightFactor, 
                    left: 10 * widthFactor, 
                    right: 10 * widthFactor
                  ),
                  padding: EdgeInsets.only(
                    top: 10.0 * heightFactor, 
                    bottom: 10.0 * heightFactor, 
                    left: 10.0 * widthFactor, 
                    right: 10.0 * widthFactor
                  ),
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Favorites',
                        style: TextStyle(
                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor, 
                          bottom: 5.0 * heightFactor
                        ),
                        height: 1.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['accent'],
                      ),
                      favouriteContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      ),
    );
  }
}