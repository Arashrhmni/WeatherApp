import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:weather/weather.dart';
import '../apikeys.dart';
import '../allsettings.dart';
import 'dart:math' as math;

final Map weekdays = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

double getWindSpeedForWeather(Weather w) {
  if(currentSettings['wind_speed'] == 'meter-per-second') {
    return w.windSpeed!;
  } else if(currentSettings['wind_speed'] == 'kilometer-per-hour') {
    return w.windSpeed! * 3.6;
  } else {
    return w.windSpeed! * 2.23694;
  }
}

String windDegreesToReadable(double degrees) {
  if(degrees >= 342.5 || degrees < 17.5) {
    return 'From North to South';
  } else if(degrees >= 17.5 && degrees < 72.5) {
    return 'From North-East To South-West';
  } else if(degrees >= 72.5 && degrees < 107.5) {
    return 'From East To West';
  } else if(degrees >= 107.5 && degrees < 162.5) {
    return 'From South-East To North-West';
  } else if(degrees >= 162.5 && degrees < 197.5) {
    return 'From South To North';
  } else if(degrees >= 197.5 && degrees < 252.5) {
    return 'From South-West To North-East';
  } else if(degrees >= 252.5 && degrees < 287.5) {
    return 'From West To East';
  } else {
    return 'From North-West To South-East';
  }
}

String convertTemp(double temp) {
  if(currentSettings['temperature'] == 'celcius') {
    return '${temp.toStringAsFixed(0)} °C';
  } else if(currentSettings['temperature'] == 'fahrenheit') {
    return '${(((temp*9)/5) + 32).toStringAsFixed(0)} °F';
  } else {
    return '${(temp + 273.15).toStringAsFixed(0)} K';
  }

}

List<Container> get5DayForecastViewer(List<Weather> forecast) {
  DateTime date = forecast[0].date!;
  List<Container> forecastTiles = [];
  int startIndex = 0;
  List<List<Weather>> forecastDays = [];
  for (int i = 0; i < forecast.length; i++) {
    if (forecast[i].date!.day != date.day) {
      forecastDays.add(forecast.getRange(startIndex, i).toList());
      startIndex = i;
      date = forecast[i].date!;
    }
  }
  forecastDays.removeAt(0);
  List<String> temperatureForecast = [];
  for(int i = 0; i < forecastDays.length; i++) {
    temperatureForecast.add(convertTemp((forecastDays[i][0].tempMax!.celsius! + forecastDays[i][0].tempMin!.celsius!) / 2.0));
  }
  List<SingleChildScrollView> forecastDayTilesScroll = [];
  for (int i = 0; i < forecastDays.length; i++) {
    List<Container> forecastDayTiles = [];
    for (int j = 0; j < forecastDays[i].length; j++) {
      forecastDayTiles.add(
        Container(
          width: deviceWidth * 0.20,
          height: deviceHeight * 0.12,
          padding: EdgeInsets.only(
            top: 10.0 * heightFactor,
            bottom: 10.0 * heightFactor,
            left: 10.0 * widthFactor,
            right: 10.0 * widthFactor,
          ),
          margin: EdgeInsets.only(
            bottom: 5.0 * heightFactor, 
            left: 5.0 * widthFactor, 
            right: 5.0 * widthFactor
          ),
          decoration: BoxDecoration(
            color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: themeData[currentSettings['theme']]!['accent']!,
              width: 2.0 * widthFactor,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    getTemperatureForWeather(forecastDays[i][j])['current']!,
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontSize: 17.0 * heightFactor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Fredoka'
                    ),
                  ),
                ),
                Container(
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  width: deviceWidth * 0.15,
                ),
                Image.network(
                  'http://openweathermap.org/img/wn/${forecastDays[i][j].weatherIcon}@4x.png',
                  height: deviceHeight * 0.05,
                  width: deviceWidth * 0.15,
                  fit: BoxFit.scaleDown,
                ),
                Container(
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  width: deviceWidth * 0.15,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    makeReadableTIme(forecastDays[i][j].date!),
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontSize: 13.0 * heightFactor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Fredoka'
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      );
    }
    SingleChildScrollView forecastDayTileScroll = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: forecastDayTiles,
      ),
    );
    forecastDayTilesScroll.add(forecastDayTileScroll);
  }
  for (int i = 0; i < forecastDayTilesScroll.length; i++) {
    forecastTiles.add(
      Container(
        decoration: BoxDecoration(
          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: themeData[currentSettings['theme']]!['accent']!,
            width: 1.0 * widthFactor,
          ),
        ),
        margin: EdgeInsets.only(
          top: 5.0 * heightFactor,
          bottom: 5.0 * heightFactor,
        ),
        padding: EdgeInsets.only(
          left: 5.0 * widthFactor,
          right: 5.0 * widthFactor,
          bottom: 5.0 * heightFactor,
          top: 5.0 * heightFactor,
        ),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          tilePadding: EdgeInsets.only(
            top: 5.0 * heightFactor,
            bottom: 5.0 * heightFactor,
            left: 5.0 * widthFactor,
            right: 5.0 * widthFactor,
          ),
          childrenPadding: EdgeInsets.only(
            top: 5.0 * heightFactor,
            bottom: 5.0 * heightFactor,
            left: 5.0 * widthFactor,
            right: 5.0 * widthFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          leading: Text(
            'Avg : ${temperatureForecast[i]}',
            style: TextStyle(
              color: themeData[currentSettings['theme']]!['text'],
              fontSize: 17.0 * heightFactor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Fredoka'
            ),
          ),
          trailing: const SizedBox.shrink(),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              '${weekdays[forecastDays[i][0].date!.weekday]}    ${makeReadableDate(forecastDays[i][0].date!)}',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 15.0 * heightFactor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Fredoka'
              ),
            ),
          ),
          children: [
            forecastDayTilesScroll[i],
          ],
        ),
      ),
    );
  }
  return forecastTiles;
}

Map<String, String> getTemperatureForWeather(Weather w) {
  String currentTemp, minTemp, maxTemp, feelsLikeTemp;
  if(currentSettings['temperature'] == 'celcius') {
    currentTemp = '${(w.temperature!.celsius!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    minTemp = '${(w.tempMin!.celsius!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    maxTemp = '${(w.tempMax!.celsius!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    feelsLikeTemp = '${(w.tempFeelsLike!.celsius!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
  } else if(currentSettings['temperature'] == 'fahrenheit') {
    currentTemp = '${(w.temperature!.fahrenheit!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    minTemp = '${(w.tempMin!.fahrenheit!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    maxTemp = '${(w.tempMax!.fahrenheit!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    feelsLikeTemp = '${(w.tempFeelsLike!.fahrenheit!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
  } else {
    currentTemp = '${(w.temperature!.kelvin!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    minTemp = '${(w.tempMin!.kelvin!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    maxTemp = '${(w.tempMax!.kelvin!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
    feelsLikeTemp = '${(w.tempFeelsLike!.kelvin!).toStringAsFixed(0)} ${temperatures[currentSettings['temperature']]}';
  }
  return {
    'current' : currentTemp,
    'min' : minTemp,
    'max' : maxTemp,
    'feels_like' : feelsLikeTemp,
  };
}

String makeBetter2ndAddress(String address) {
  List<String> parts = address.split(', ');
  String finalString = '';
  for (int i = 0; i < parts.length; i++) {
    List<String> words = parts[i].split(' ');
    String part = '';
    if (words.length > 1) {
      for (int j = 0; j < words.length; j++) {
        part += words[j][0].capitalize();
      }
    } else {
      part += parts[i];
    }
    if (i == 0) {
      finalString += part;
    } else {
      finalString += ', $part';
    }
  }
  return finalString;
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    } else {
      String result = '';
      bool makeUpper = true;
      for (int i = 0; i < length; i++) {
        result += makeUpper ? this[i].toUpperCase() : this[i].toLowerCase();
        makeUpper = this[i] == ' ';
      }
      return result;
    }
  }
}

class WeatherScreen extends StatefulWidget {
  
  final List<double> cityLatLong;
  final String cityName;
  
  const WeatherScreen({super.key, required this.cityLatLong, required this.cityName});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  WeatherFactory wf = WeatherFactory(openWeather);
  Weather? weather;
  Map<String, dynamic>? weatherData;
  List<Weather>? forecast;
  DateTime? date;
  int? timezoneOffset;
  

  var favourites = Hive.box('favourites');
  var favouriteList = Hive.box('favourites').get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();
  bool? isFavourite;
  IconData? icon;

  DateTime getLocalTime(DateTime d) {
    DateTime newDate = DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch - (d.timeZoneOffset.inSeconds * 1000));
    newDate = DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch + timezoneOffset!);
    return newDate;
  }

  @override
  void initState() {
    try {
    super.initState();
    } catch(e) {
      // ignore
    } finally {
      for(var i in favouriteList) {
        if(i[0] == widget.cityName) {
          setState(() {
            isFavourite = true;
            icon = Icons.favorite;
          });
          break;
        }
      }
      if(isFavourite == null) {
        setState(() {
          isFavourite = false;
          icon = Icons.favorite_border;
        });
      }
      wf.currentWeatherByLocation(widget.cityLatLong[0], widget.cityLatLong[1]).then((w) {
        setState(() {
          weather = w;
          weatherData = weather!.toJson();
          date = weather!.date;
          timezoneOffset = weatherData!['timezone'] * 1000;
          date = getLocalTime(date!);
        });
      });
      wf.fiveDayForecastByLocation(widget.cityLatLong[0],widget.cityLatLong[1]).then((f) {
        setState(() {
          forecast = f;
        });
      });
    }
  }



  @override
  Widget build(BuildContext context) {

    previousRoute = '/weather';

    if(!(weather == null || forecast == null)) {
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, 'reload');
          return true;
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if(isFavourite!) {
                isFavourite = false;
                for(var i in favouriteList) {
                  if(i[0] == widget.cityName) {
                    favouriteList.remove(i);
                    break;
                  }
                }
                favourites.put('favourites', favouriteList);
              } else {
                isFavourite = true;
                favouriteList.add([widget.cityName, widget.cityLatLong[0], widget.cityLatLong[1], getTemperatureForWeather(weather!)['current'], weather!.weatherIcon]);
                favourites.put('favourites', favouriteList);
              }
              setState(() {
                icon = isFavourite! ? Icons.favorite : Icons.favorite_border;
              });
              setState(() => {});
            },
            backgroundColor: themeData[currentSettings['theme']]!['accent'],
            foregroundColor: themeData[currentSettings['theme']]!['text'],
            child: Icon(icon),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          appBar: AppBar(
            leading: IconButton(
              padding: EdgeInsets.only(
                left: 15.0 * widthFactor
              ),
              icon: Icon(
                Icons.arrow_back,
                color: themeData[currentSettings['theme']]!['text'],
                size: 30.0 * heightFactor,
              ),
              onPressed: () {
                Navigator.pop(context, 'reload');
              },
            ),
            elevation: 4.0,
            shadowColor: themeData[currentSettings['theme']]!['shadow'],
            actions: [
              IconButton(
                padding: EdgeInsets.only(
                  right: 15.0 * widthFactor
                ),
                icon: Icon(
                  Icons.settings,
                  color: themeData[currentSettings['theme']]!['text'],
                  size: 30.0 * heightFactor,
                ),
                onPressed: () async {
                  var result = await Navigator.pushNamed(context, '/settings');
                  if(result == 'themeChanged') {
                    setState(() {});
                  }
                },
              ),
            ],
            title: Center(
              child: Text(
                'Weather', 
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text'],
                  fontSize: 30.0 * heightFactor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fredoka'
                )
              ),
            ),
            backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          ),
        
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Place Name and Date Time
                Row(
                  children: [
                    // Place Name
                    Expanded(
                      child: Container(
                        width: deviceWidth * 0.50,
                        height: deviceHeight * 0.1,
                        padding: EdgeInsets.only(
                          top: 5.0 * heightFactor,
                          bottom: 5.0 * heightFactor,
                          left: 5.0 * widthFactor,
                          right: 5.0 * widthFactor,
                        ),
                        margin: EdgeInsets.only(
                          top: 10.0 * heightFactor, 
                          bottom: 5.0 * heightFactor, 
                          left: 10.0 * widthFactor, 
                          right: 5.0 * widthFactor
                        ),
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // City Name
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  widget.cityName.split(', ')[0],
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 24.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Fredoka'
                                  ),
                                ),
                              ),
                              // Rest of the "address" and country name
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  makeBetter2ndAddress(widget.cityName.split(', ').getRange(1, widget.cityName.split(', ').length).join(', ')),
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 16.0 * heightFactor,
                                    fontFamily: 'Fredoka'
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: deviceWidth * 0.40,
                        height: deviceHeight * 0.1,
                        padding: EdgeInsets.only(
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                        ),
                        margin: EdgeInsets.only(
                          left: 5.0 * widthFactor,
                          top: 10.0 * heightFactor, 
                          bottom: 5.0 * heightFactor, 
                          right: 10.0 * widthFactor
                        ),
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  weekdays[date!.weekday].toUpperCase() ?? "",
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 16.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Fredoka'
                                  ),
                                ),
                              ),
                              Container(
                                height: 1.0 * heightFactor,
                                color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                width: deviceWidth * 0.30,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      makeReadableDate(date!),
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 14.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 5.0 * widthFactor,
                                        right: 5.0 * widthFactor
                                      ),
                                      width: 1.0 * widthFactor,
                                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                      height: 20.0 * heightFactor,
                                    ),
                                    Text(
                                      makeReadableTIme(date!),
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 14.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Temparature Data
                Row(
                  children: [
                    Container(
                      width: deviceWidth * 0.47,
                      height: deviceHeight * 0.17,
                      padding: EdgeInsets.only(
                        top: 10.0 * heightFactor,
                        bottom: 10.0 * heightFactor,
                        left: 10.0 * widthFactor,
                        right: 10.0 * widthFactor,
                      ),
                      margin: EdgeInsets.only(
                        top: 5.0 * heightFactor, 
                        bottom: 5.0 * heightFactor, 
                        left: 10.0 * widthFactor, 
                        right: 5.0 * widthFactor
                      ),
                      decoration: BoxDecoration(
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: themeData[currentSettings['theme']]!['accent']!,
                          width: 2.0 * widthFactor,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                getTemperatureForWeather(weather!)['current']!,
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontSize: 48.0 * heightFactor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Fredoka'
                                ),
                              ),
                            ),
                            Container(
                              height: 1.0 * heightFactor,
                              color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                              width: deviceWidth * 0.25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Minimum',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 16.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        'Maximum',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 16.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        'Feels Like',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 16.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 10.0 * widthFactor,
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${getTemperatureForWeather(weather!)['min']}',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        '${getTemperatureForWeather(weather!)['max']}',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        '${getTemperatureForWeather(weather!)['feels_like']}',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Weather Icon and Description
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor, 
                          bottom: 5.0 * heightFactor, 
                          right: 10.0 * widthFactor, 
                          left: 5.0 * widthFactor
                        ),
                        padding: EdgeInsets.only(
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                        ),
                        height: deviceHeight * 0.17,
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Used the network image requirement ;)
                            Image.network(
                              'http://openweathermap.org/img/wn/${weather!.weatherIcon}@2x.png',
                              height: deviceHeight * 0.10,
                              width: deviceWidth * 0.3,
                              fit: BoxFit.scaleDown,
                            ),
                            Container(
                              height: 1.0 * heightFactor,
                              color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                              width: deviceWidth * 0.5,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                '${weather!.weatherDescription}'.capitalize(),
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontSize: 20.0 * heightFactor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Fredoka'
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                // Wind Data
                Container(
                  width: deviceWidth - (20.0 * widthFactor),
                  height: deviceHeight * 0.13,
                  padding: EdgeInsets.only(
                    top: 10.0 * heightFactor,
                    bottom: 10.0 * heightFactor,
                    left: 10.0 * widthFactor,
                    right: 10.0 * widthFactor,
                  ),
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor, 
                    bottom: 5.0 * heightFactor, 
                    left: 10.0 * widthFactor, 
                    right: 10.0 * widthFactor
                  ),
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: deviceWidth * 0.66,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Wind',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 20.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 1.0 * heightFactor,
                                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                      width: deviceWidth * 0.66,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Speed',
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 16.0 * heightFactor,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                            Text(
                                              'Direction',
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 16.0 * heightFactor,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 30.0 * widthFactor,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${getWindSpeedForWeather(weather!).toStringAsFixed(2)} ${windspeeds[currentSettings['wind_speed']]}',
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 15.0 * heightFactor,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                            Text(
                                              '${weather!.windDegree!.toStringAsFixed(0)}°',
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 15.0 * heightFactor,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1.0 * heightFactor,
                                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                      width: deviceWidth * 0.66,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        windDegreesToReadable(weather!.windDegree!),
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 16.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(45.0),
                                border: Border.all(
                                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                  width: 1.0 * widthFactor,
                                ),
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: ((weather!.windDegree!) * math.pi / 180.0) + math.pi, 
                                  child: Icon(
                                    Icons.navigation, 
                                    size: 90.0 * heightFactor, 
                                    color: const Color.fromARGB(255, 139, 73, 11),
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: themeData[currentSettings['theme']]!['accent']!,
                          width: 2.0 * widthFactor,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        top: 5.0 * heightFactor,
                        bottom: 5.0 * heightFactor,
                        left: 10.0 * widthFactor,
                        right: 5.0 * widthFactor,
                      ),
                      padding: EdgeInsets.only(
                        top: 10.0 * heightFactor,
                        bottom: 10.0 * heightFactor,
                        left: 10.0 * widthFactor,
                        right: 10.0 * widthFactor,
                      ),
                      height: deviceHeight * 0.15,
                      width: deviceWidth * 0.52,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sunrise',
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 18.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                    Text(
                                      'Sunset',
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 18.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 15.0 * widthFactor,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      makeReadableTIme(getLocalTime(weather!.sunrise!)),
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 15.0 * heightFactor,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                    Text(
                                      makeReadableTIme(getLocalTime(weather!.sunset!)),
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 15.0 * heightFactor,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 15.0 * widthFactor,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.wb_sunny,
                                      color: const Color.fromARGB(255, 228, 228, 0),
                                      size: 24.0 * heightFactor,
                                    ),
                                    Transform.rotate(
                                      angle: math.pi * 1.75,
                                      child: Icon(
                                        Icons.nightlight_round,
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        size: 24.0 * heightFactor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 10.0 * heightFactor,
                          ),
                          Container(
                            height: 1.0 * heightFactor,
                            color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                            width: deviceWidth * 0.50,
                          ),
                          Container(
                            height: 10.0 * heightFactor,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Daylight Time',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 16.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        '${(weather!.sunset!.difference(weather!.sunrise!)).inHours} Hours ${(weather!.sunset!.difference(weather!.sunrise!)).inMinutes.remainder(60)} Minutes',
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 15.0 * widthFactor,
                                ),
                                Icon(
                                  Icons.wb_sunny,
                                  color: const Color.fromARGB(255, 228, 228, 0),
                                  size: 20.0 * heightFactor,
                                ),
                                Icon(
                                  Icons.arrow_right_alt,
                                  color: themeData[currentSettings['theme']]!['text'],
                                  size: 20.0 * heightFactor,
                                ),
                                Transform.rotate(
                                  angle: math.pi * 1.75,
                                  child: Icon(
                                    Icons.nightlight_round,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    size: 20.0 * heightFactor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor,
                          bottom: 5.0 * heightFactor,
                          right: 10.0 * widthFactor,
                          left: 5.0 * widthFactor,
                        ),
                        padding: EdgeInsets.only(
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                        ),
                        height: deviceHeight * 0.15,
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text(
                                    'Humidity',
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text'],
                                      fontSize: 18.0 * heightFactor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Fredoka'
                                    ),
                                  ),
                                  Container(
                                    width: 10.0 * widthFactor,
                                  ),
                                  Text(
                                    '${weather!.humidity} %',
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text'],
                                      fontSize: 15.0 * heightFactor,
                                      fontFamily: 'Fredoka'
                                    ),
                                  ),
                                  Container(
                                    width: 5.0 * widthFactor,
                                  ),
                                  Icon(
                                    Icons.water_drop_rounded,
                                    color: const Color.fromARGB(255, 0, 0, 197),
                                    size: 30.0 * heightFactor,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 5.0 * heightFactor,
                            ),
                            Container(
                              height: 1.0 * heightFactor,
                              color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                              width: deviceWidth * 0.50,
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            'Pressure',
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 18.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            convertPressure(weather!.pressure!),
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 15.0 * heightFactor,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.speed_rounded,
                                          color: const Color.fromARGB(255, 177, 0, 0),
                                          size: 30.0 * heightFactor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1.0 * widthFactor,
                                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                    height: 100.0 * heightFactor,
                                    margin: EdgeInsets.only(
                                      left: 10.0 * widthFactor,
                                      right: 10.0 * widthFactor
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            'Visibility',
                                            style: TextStyle(
                                              color: themeData
                                              [currentSettings['theme']]!['text'],
                                              fontSize: 18.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            convertVisibility(weatherData!['visibility']),
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 15.0 * heightFactor,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.visibility,
                                          color: const Color.fromARGB(255, 0, 138, 0),
                                          size: 30.0 * heightFactor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        )
                      ),
                    )
                  ],
                ),
                // Forecast
                Container(
                  width: deviceWidth - (20.0 * widthFactor),
                  height: deviceHeight * 0.20,
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor,
                    bottom: 5.0 * heightFactor,
                    left: 10.0 * widthFactor,
                    right: 10.0 * widthFactor,
                  ),
                  padding: EdgeInsets.only(
                    top: 10.0 * heightFactor,
                    bottom: 10.0 * heightFactor,
                    left: 5.0 * widthFactor,
                    right: 5.0 * widthFactor,
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          'Next 24 Hours Forecast for Every 3 Hours',
                          style: TextStyle(
                            color: themeData[currentSettings['theme']]!['text'],
                            fontSize: 16.0 * heightFactor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Fredoka'
                          ),
                        ),
                      ),
                      Container(
                        height: 2.0 * heightFactor,
                        width: deviceWidth - (20.0 * widthFactor),
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor,
                          bottom: 5.0 * heightFactor,
                        )
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for(var i in forecast!.getRange(0, 8))
                              Container(
                                width: deviceWidth * 0.20,
                                height: deviceHeight * 0.14,
                                margin: EdgeInsets.only(
                                  left: 5.0 * widthFactor,
                                  right: 5.0 * widthFactor,
                                ),
                                decoration: BoxDecoration(
                                  color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: themeData[currentSettings['theme']]!['accent']!,
                                    width: 2.0 * widthFactor,
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          '${getTemperatureForWeather(i)['current']}',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 20.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka'
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 1.0 * heightFactor,
                                        color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                        width: deviceWidth * 0.20,
                                      ),
                                      SizedBox(
                                        height: 80.0 * heightFactor,
                                        child: Image.network(
                                          'http://openweathermap.org/img/wn/${i.weatherIcon}@4x.png',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      Container(
                                        height: 1.0 * heightFactor,
                                        color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                        width: deviceWidth * 0.20,
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Text(
                                            makeReadableTIme(getLocalTime(i.date!)),
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 14.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Forecast for 5 days ahead
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor,
                    bottom: 10.0 * heightFactor,
                    left: 10.0 * widthFactor,
                    right: 10.0 * widthFactor,
                  ),
                  padding: EdgeInsets.only(
                    top: 10.0 * heightFactor,
                    bottom: 10.0 * heightFactor,
                    left: 5.0 * widthFactor,
                    right: 5.0 * widthFactor,
                  ),
                  width: deviceWidth - (20.0 * widthFactor),
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  child: ExpansionTile(
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    expandedAlignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    trailing: const SizedBox.shrink(),
                    title: Text(
                      'Next 4 Days Forecast', 
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontSize: 16.0 * widthFactor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      )
                    ),
                    initiallyExpanded: true,
                    leading: Icon(
                      Icons.calendar_today,
                      color: themeData[currentSettings['theme']]!['text'],
                    ), // Customize leading icon as needed
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                        ),
                        child: Column(
                          children: get5DayForecastViewer(forecast!), // Assuming this returns a list of Widgets
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
        ),
      );
    } else {
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Text(
                'Loading',
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text'],
                  fontSize: 30.0 * heightFactor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fredoka'
                )
              ),
            ),
            shadowColor: themeData[currentSettings['theme']]!['shadow'],
            elevation: 4.0,
            backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          ),
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeData[currentSettings['theme']]!['accent']!),
            ),
          ),
          backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
        ),
      );
    }

  }
}