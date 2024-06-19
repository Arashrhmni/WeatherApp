import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../apikeys.dart';
import '../allsettings.dart';


class WeatherScreen extends StatefulWidget {
  
  final List<double> cityLatLong;
  
  const WeatherScreen({super.key, required this.cityLatLong});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  WeatherFactory wf = WeatherFactory(openWeather);
  Weather? weather;
  Map<String, dynamic>? weatherData;
  List<Weather>? forecast;

  @override
  void initState() {
    super.initState();
    wf.currentWeatherByLocation(widget.cityLatLong[0], widget.cityLatLong[1]).then((w) {
      setState(() {
        weather = w;
        weatherData = weather!.toJson();
        print(weatherData.toString());
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
    wf.fiveDayForecastByLocation(widget.cityLatLong[0],widget.cityLatLong[1]).then((f) {
      setState(() {
        forecast = f;
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    if(!(weather == null)) {

      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          backgroundColor: themeData[currentSettings['theme']]!['accent'],
          foregroundColor: themeData[currentSettings['theme']]!['text'],
          child: const Icon(Icons.search),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeData[currentSettings['theme']]!['text'],
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 4.0,
          shadowColor: themeData[currentSettings['theme']]!['shadow'],
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color: themeData[currentSettings['theme']]!['text'],
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          title: Text(
            weather!.areaName ?? "", 
            style: TextStyle(
              color: themeData[currentSettings['theme']]!['text']
            )
          ),
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Temperature: ${weather!.temperature!.celsius!.toStringAsFixed(0)}°C',
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']
                ),
              ),
              Text(
                'Humidity: ${weather!.humidity}%',
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']
                ),
              ),
              Text(
                'Wind: ${weather!.windSpeed} m/s',
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']
                ),
              ),
            ],
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Loading',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
              )
            ),
          ),
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(themeData[currentSettings['theme']]!['accent']!),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      );
    }

  }
}