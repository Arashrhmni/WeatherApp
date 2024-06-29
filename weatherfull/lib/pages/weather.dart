import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:weather/weather.dart';
import '../confidential_constants.dart';
import '../allsettings.dart';
import 'dart:math' as math;


// Function to get readable wind speed from weather data in the selected unit in the settings
double getWindSpeedForWeather(Weather w) {
  // If the wind speed is in meter-per-second, return the wind speed as it is
  if(currentSettings['wind_speed'] == 'meter-per-second') {
    return w.windSpeed!;
  } else if(currentSettings['wind_speed'] == 'kilometer-per-hour') {
    // If the wind speed is in kilometer-per-hour, convert it to kilometer-per-hour and return
    return w.windSpeed! * 3.6;
  } else {
    // If the wind speed is in miles-per-hour, convert it to miles-per-hour and return
    return w.windSpeed! * 2.23694;
  }
}

// Function to get readable wind direction from degrees
String windDegreesToReadable(double degrees) {
  // Basically just looked at the compass to formulate this function
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

// Function to form a list of containers for the forecast part
List<Container> get4DayForecastViewer(List<Weather> forecast) {
  // Get the date of the first forecast
  DateTime date = forecast[0].date!;
  // List of containers to store the forecast tiles
  List<Container> forecastTiles = [];

  // Get the forecast days
  int startIndex = 0; // Start index of the forecast day
  List<List<Weather>> forecastDays = []; // List of forecast days
  for (int i = 0; i < forecast.length; i++) {
    // If the date of the forecast is not the same as the date of the previous forecast, meaning a new day
    if (forecast[i].date!.day != date.day) {
      // Add the forecast day to the list of forecast days
      forecastDays.add(forecast.getRange(startIndex, i).toList());
      // Update the start index and date
      startIndex = i;
      date = forecast[i].date!;
    }
  }
  // Add the last of the forecast days to the list of forecast days
  forecastDays.add(forecast.getRange(startIndex, forecast.length).toList());
  // Remove the first day as it is the current day
  forecastDays.removeAt(0);
  // If the last day is not complete, add the last two days together
  var len = forecastDays.length;
  if (forecastDays[len-1].length < 8) {
    forecastDays[len-2] = forecastDays[len-2] + forecastDays[len-1];
    forecastDays.removeAt(len-1);
  }
  // List of temperatures for the forecast days
  List<String> temperatureForecast = [];
  for(int i = 0; i < forecastDays.length; i++) {
    // calculating the average temperature throughout the day
    double sum = 0.0;
    double count = 0.0;
    for (int j = 0; j < forecastDays[i].length; j++) {
      sum += (forecastDays[i][j].temperature!.celsius!);
      count += 1.0;
    }
    // Adding the average temperature to the list of temperatures
    temperatureForecast.add(convertTemp((sum) / count));
  }
  // List of forecast day tiles scrollable widgets
  List<SingleChildScrollView> forecastDayTilesScroll = [];
  for (int i = 0; i < forecastDays.length; i++) {
    // List of forecast day tiles
    List<Container> forecastDayTiles = [];
    // For each forecast day, add the forecast day tiles
    for (int j = 0; j < forecastDays[i].length; j++) {
      forecastDayTiles.add(
        // Forecast Day Tile
        Container(
          // width and height of the forecast day tile
          width: deviceWidth * 0.20,
          height: deviceHeight * 0.12,
          // padding and margin of the forecast day tile
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
          // decoration of the forecast day tile
          decoration: BoxDecoration(
            color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: themeData[currentSettings['theme']]!['accent']!,
              width: 2.0 * widthFactor,
            ),
          ),
          // child of the forecast day tile
          child: SingleChildScrollView(
            child: Column(
              // alignment of the children
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current Temperature
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    // Get the temperature for the weather
                    getTemperatureForWeather(forecastDays[i][j])['current']!,
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontSize: 17.0 * heightFactor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Fredoka'
                    ),
                  ),
                ),
                // divider
                Container(
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  width: deviceWidth * 0.15,
                ),
                // weather icon
                Image.network(
                  'http://openweathermap.org/img/wn/${forecastDays[i][j].weatherIcon}@4x.png',
                  height: deviceHeight * 0.05,
                  width: deviceWidth * 0.15,
                  fit: BoxFit.scaleDown,
                ),
                // divider
                Container(
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                  width: deviceWidth * 0.15,
                ),
                // the time of the forecast
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
    // Scrollable widget for the forecast day tiles
    SingleChildScrollView forecastDayTileScroll = SingleChildScrollView(
      // scroll direction of the scrollable widget is horizontal
      scrollDirection: Axis.horizontal,
      child: Row(
        children: forecastDayTiles, // children of the scrollable widget are the forecast day tiles
      ),
    );
    // Add the scrollable widget to the list of forecast day tiles scrollable widgets
    forecastDayTilesScroll.add(forecastDayTileScroll);
  }
  // For each forecast day, add the forecast day tiles scrollable widget to the forecast tiles
  for (int i = 0; i < forecastDayTilesScroll.length; i++) {
    forecastTiles.add(
      // Forecast Tile
      Container(
        // decoration of the forecast tile
        decoration: BoxDecoration(
          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: themeData[currentSettings['theme']]!['accent']!,
            width: 1.0 * widthFactor,
          ),
        ),
        // padding and margin of the forecast tile
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
        // child of the forecast tile
        child: ExpansionTile(
          // collapsed shape of the forecast tile
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // padding of the forecast tile
          tilePadding: EdgeInsets.only(
            top: 5.0 * heightFactor,
            bottom: 5.0 * heightFactor,
            left: 5.0 * widthFactor,
            right: 5.0 * widthFactor,
          ),
          // padding of the children of the forecast tile
          childrenPadding: EdgeInsets.only(
            top: 5.0 * heightFactor,
            bottom: 5.0 * heightFactor,
            left: 5.0 * widthFactor,
            right: 5.0 * widthFactor,
          ),
          // expanded shape of the forecast tile
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // leading of the forecast tile
          leading: Text(
            'Avg : ${temperatureForecast[i]}',
            style: TextStyle(
              color: themeData[currentSettings['theme']]!['text'],
              fontSize: 17.0 * heightFactor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Fredoka'
            ),
          ),
          // the end of the forecast tile, empty but still a widget
          trailing: const SizedBox.shrink(),
          // title of the forecast tile
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              // the weekday of the forecast and the date
              '${weekdays[forecastDays[i][0].date!.weekday]} - ${makeReadableDate(forecastDays[i][0].date!)}',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 15.0 * heightFactor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Fredoka'
              ),
            ),
          ),
          children: [
            forecastDayTilesScroll[i], // children of the forecast tile are the forecast day tiles scrollable widget
          ],
        ),
      ),
    );
  }
  // Return the forecast tiles
  return forecastTiles;
}

// The weather screen stateful widget
class WeatherScreen extends StatefulWidget {
  
  final List<double> cityLatLong;
  final String cityName;
  
  const WeatherScreen({super.key, required this.cityLatLong, required this.cityName});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  // Weather factory object
  WeatherFactory wf = WeatherFactory(openWeather);
  // Weather object
  Weather? weather;
  // Weather data
  Map<String, dynamic>? weatherData;
  // Forecast data
  List<Weather>? forecast;
  // Date and timezone offset
  DateTime? date;
  int? timezoneOffset;
  
  // Favourites box
  var favourites = Hive.box('favourites');
  // Favourites list
  var favouriteList = Hive.box('favourites').get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();
  bool? isFavourite; // is the city a favourite
  IconData? favoriteIcon; // icon for the favourite button

  // Function to get the local time from the UTC time
  DateTime getLocalTime(DateTime d) {
    DateTime newDate = DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch - (d.timeZoneOffset.inSeconds * 1000));
    newDate = DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch + timezoneOffset!);
    return newDate;
  }

  // Init state
  @override
  void initState() {
    try {
      super.initState(); // try to initialize the state of the parent widget
    } catch(e) {
      // ignore the exception if any
    } finally {
      // check if the city is a favourite
      for(var i in favouriteList) {
        if(i[0] == widget.cityName) {
          setState(() {
            isFavourite = true; // set the city as a favourite
            favoriteIcon = Icons.favorite; // set the icon as a favourite icon
          });
          break;
        }
      }
      // if the city is not a favourite
      if(isFavourite == null) {
        setState(() {
          isFavourite = false; // set the city as not a favourite
          favoriteIcon = Icons.favorite_border; // set the icon as a not favourite icon
        });
      }
      // get the weather data
      wf.currentWeatherByLocation(widget.cityLatLong[0], widget.cityLatLong[1]).then((w) {
        setState(() {
          weather = w; // set the weather object
          weatherData = weather!.toJson(); // set the weather data as json
          date = weather!.date; // set the date as the date of the weather
          timezoneOffset = weatherData!['timezone'] * 1000; // set the timezone offset
          date = getLocalTime(date!); // get the local time and reset date
        });
      });
      // get the forecast data
      wf.fiveDayForecastByLocation(widget.cityLatLong[0],widget.cityLatLong[1]).then((f) {
        setState(() {
          forecast = f; // set the forecast data
        });
      });
    }
  }

  // Build method for the widget
  @override
  Widget build(BuildContext context) {

    // previous route is the weather route
    previousRoute = '/weather';

    // if the weather and forecast data is not null
    if(!(weather == null || forecast == null)) {
      // use will pop scope to handle the back button
      // ignore: deprecated_member_use
      return WillPopScope(
        // on will pop get back and reload the previous route
        onWillPop: () async {
          Navigator.pop(context, 'reload');
          return true;
        },
        // child of the will pop scope
        child: Scaffold(
          // floating action button for the favourite button
          floatingActionButton: FloatingActionButton(
            // on pressed function for the floating action button
            onPressed: () {
              // if the city is not a favourite
              if(isFavourite!) {
                isFavourite = false; // set the city as not a favourite
                // remove the city from the favourites list
                for(var i in favouriteList) {
                  if(i[0] == widget.cityName) {
                    favouriteList.remove(i);
                    break;
                  }
                }
                favourites.put('favourites', favouriteList); // update the favourites list
              } else {
                // if the city is not a favourite
                isFavourite = true; // set the city as a favourite
                favouriteList.add([widget.cityName, widget.cityLatLong[0], widget.cityLatLong[1], getTemperatureForWeather(weather!)['current'], weather!.weatherIcon]); // add the city to the favourites list
                favourites.put('favourites', favouriteList); // update the favourites list
              }
              setState(() {
                favoriteIcon = isFavourite! ? Icons.favorite : Icons.favorite_border; // set the icon as a favourite icon if the city is a favourite, else set it as a not favourite icon
              });
              setState(() => {}); // refresh the page
            },
            backgroundColor: themeData[currentSettings['theme']]!['accent'], // set the background color of the floating action button
            foregroundColor: themeData[currentSettings['theme']]!['text'], // set the foreground color of the floating action button
            child: Icon(favoriteIcon), // set the icon of the floating action button
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // set the location of the floating action button
          appBar: AppBar(
            // icon button for the back button
            leading: IconButton(
              padding: EdgeInsets.only(
                left: 15.0 * widthFactor // padding of the icon button
              ),
              icon: Icon(
                Icons.arrow_back, // icon of the icon button
                color: themeData[currentSettings['theme']]!['text'],
                size: 30.0 * heightFactor,
              ),
              onPressed: () {
                // on pressed, pop the context and reload the previous route
                Navigator.pop(context, 'reload');
              },
            ),
            elevation: 4.0, // elevation of the app bar
            shadowColor: themeData[currentSettings['theme']]!['shadow'], // shadow color of the app bar
            actions: [
              // icon button for the settings button
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
                  // on pressed, push the settings route and get the result
                  var result = await Navigator.pushNamed(context, '/settings');
                  if(result == 'themeChanged') {
                    // refresh the page if the theme is changed
                    setState(() {});
                  }
                },
              ),
            ],
            // title of the app bar
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
            backgroundColor: themeData[currentSettings['theme']]!['appBar'], // background color of the app bar
          ),

          // body of the scaffold which is a single child scroll view so the page can be scrolled
          body: SingleChildScrollView(
            child: Column(
              // alignment of the children
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Place Name and Date Time
                Row(
                  children: [
                    // Place Name
                    Expanded(
                      child: Container(
                        // width and height of the container
                        width: deviceWidth * 0.50,
                        height: deviceHeight * 0.1,
                        // padding and margin of the container
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
                        // decoration of the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              // alignment of the children
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // City Name
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    widget.cityName.split(', ')[0], // get the city name
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
                                    makeBetter2ndAddress(widget.cityName.split(', ').getRange(1, widget.cityName.split(', ').length).join(', ')), // get the rest of the address
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
                    ),
                    // Date and Time
                    Expanded(
                      child: Container(
                        // width and height of the container
                        width: deviceWidth * 0.40,
                        height: deviceHeight * 0.1,
                        // padding and margin of the container
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
                        // decoration of the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              // alignment of the children
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Weekday
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    weekdays[date!.weekday].toUpperCase() ?? "", // get the weekday
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text'],
                                      fontSize: 16.0 * heightFactor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Fredoka'
                                    ),
                                  ),
                                ),
                                // divider
                                Container(
                                  height: 1.0 * heightFactor,
                                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                  width: deviceWidth * 0.30,
                                ),
                                // Date and Time
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Date
                                      Text(
                                        makeReadableDate(date!), // get the readable date
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 14.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      // divider
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: 5.0 * widthFactor,
                                          right: 5.0 * widthFactor
                                        ),
                                        width: 1.0 * widthFactor,
                                        color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                        height: 20.0 * heightFactor,
                                      ),
                                      // Time
                                      Text(
                                        makeReadableTIme(date!), // get the readable time
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
                    ),
                  ],
                ),
                // Temparature Data and Weather Icon and Description
                Row(
                  children: [
                    // Temperature Data
                    Container(
                      // width and height of the container
                      width: deviceWidth * 0.47,
                      height: deviceHeight * 0.17,
                      // padding and margin of the container
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
                      // decoration of the container
                      decoration: BoxDecoration(
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: themeData[currentSettings['theme']]!['accent']!,
                          width: 2.0 * widthFactor,
                        ),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            // alignment of the children
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Current Temperature
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  getTemperatureForWeather(weather!)['current']!, // get the current temperature for the weather
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 48.0 * heightFactor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Fredoka'
                                  ),
                                ),
                              ),
                              // divider
                              Container(
                                height: 1.0 * heightFactor,
                                color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                width: deviceWidth * 0.25,
                              ),
                              // Min, Max and Feels Like Temperatures
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  // alignment of the children
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Min, Max and Feels Like Temperatures Labels
                                    SingleChildScrollView(
                                      child: Column(
                                        // alignment of the children
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Minimum', // minimum temperature label
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 16.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                          Text(
                                            'Maximum', // maximum temperature label
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 16.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                          Text(
                                            'Feels Like', // feels like temperature label
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
                                    // Spacing between the labels and the values
                                    Container(
                                      width: 10.0 * widthFactor,
                                    ),
                                    // Min, Max and Feels Like Temperatures Values
                                    SingleChildScrollView(
                                      child: Column(
                                        // alignment of the children
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${getTemperatureForWeather(weather!)['min']}', // minimum temperature value
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 15.0 * heightFactor,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                          Text(
                                            '${getTemperatureForWeather(weather!)['max']}', // maximum temperature value
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 15.0 * heightFactor,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                          Text(
                                            '${getTemperatureForWeather(weather!)['feels_like']}', // feels like temperature value
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Weather Icon and Description
                    Expanded(
                      child: Container(
                        // margin and padding of the container
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
                        // height of the container
                        height: deviceHeight * 0.17,
                        // decoration of the container
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
                            children: [
                              // Weather Icon
                              Image.network(
                                'http://openweathermap.org/img/wn/${weather!.weatherIcon}@2x.png',
                                height: deviceHeight * 0.10,
                                width: deviceWidth * 0.3,
                                fit: BoxFit.scaleDown,
                              ),
                              // divider
                              Container(
                                height: 1.0 * heightFactor,
                                color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                width: deviceWidth * 0.5,
                              ),
                              // Weather Description
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
                      ),
                    )
                  ],
                ),
                // Wind Data
                Container(
                  // width and height of the container
                  width: deviceWidth - (20.0 * widthFactor),
                  height: deviceHeight * 0.17,
                  // padding and margin of the container
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
                  // decoration of the container
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          // alignment of the children
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Wind data
                                SizedBox(
                                  width: deviceWidth * 0.66,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // alignment of the children
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        // Wind Title
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
                                        // divider
                                        Container(
                                          height: 1.0 * heightFactor,
                                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                          width: deviceWidth * 0.66,
                                        ),
                                        // Wind Speed and Direction
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              // Wind Speed and Direction Labels
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Speed', // wind speed label
                                                    style: TextStyle(
                                                      color: themeData[currentSettings['theme']]!['text'],
                                                      fontSize: 16.0 * heightFactor,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Fredoka'
                                                    ),
                                                  ),
                                                  Text(
                                                    'Direction', // wind direction label
                                                    style: TextStyle(
                                                      color: themeData[currentSettings['theme']]!['text'],
                                                      fontSize: 16.0 * heightFactor,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Fredoka'
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Spacing between the labels and the values
                                              Container(
                                                width: 30.0 * widthFactor,
                                              ),
                                              // Wind Speed and Direction Values
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${getWindSpeedForWeather(weather!).toStringAsFixed(2)} ${windspeeds[currentSettings['wind_speed']]}', // wind speed value
                                                    style: TextStyle(
                                                      color: themeData[currentSettings['theme']]!['text'],
                                                      fontSize: 15.0 * heightFactor,
                                                      fontFamily: 'Fredoka'
                                                    ),
                                                  ),
                                                  Text(
                                                    '${weather!.windDegree!.toStringAsFixed(0)}° From South', // wind direction value
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
                                        ),
                                        // divider
                                        Container(
                                          height: 1.0 * heightFactor,
                                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                          width: deviceWidth * 0.66,
                                        ),
                                        // Wind Direction Reading
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            windDegreesToReadable(weather!.windDegree!), // wind direction reading
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
                                // Wind Direction Icon
                                Column(
                                  children: [
                                    // Marking North direction
                                    Text(
                                      'N',
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 10.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Marking West direction
                                        Text(
                                          'W',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 10.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka'
                                          ),
                                        ),
                                        // Wind Direction Icon
                                        // Circle Avatar used to make the icon circular
                                        CircleAvatar(
                                          backgroundColor: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.1),
                                          radius: 0.1 * deviceWidth,
                                          // Container used to add border
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(45.0),
                                              border: Border.all(
                                                color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.4),
                                                width: 1.0 * widthFactor,
                                              ),
                                            ),
                                            // Transform.rotate used to rotate the icon to the wind direction
                                            child: Transform.rotate(
                                              angle: ((weather!.windDegree!) * math.pi / 180.0) + math.pi, // angle of the rotation of the icon
                                              child: ShaderMask(
                                                // Shader mask used to add gradient to the icon
                                                shaderCallback: (Rect bounds) {
                                                  // LinearGradient returned to create the gradient
                                                  return LinearGradient(
                                                    // Start and end points of the gradient
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    // Colors of the gradient
                                                    colors: [
                                                      themeData
                                                        [currentSettings['theme']]!
                                                        ['main_body_background']!
                                                        .withBlue(250)
                                                        .withGreen(255)
                                                        .withOpacity(0.7),
                                                      themeData[currentSettings['theme']]!['accent']!
                                                    ],
                                                    // Stops of the gradient
                                                    stops: const [0.0, 0.8],
                                                  ).createShader(bounds);
                                                },
                                                // Weather Icon
                                                child: Icon(
                                                  Icons.navigation, 
                                                  size: 90.0 * heightFactor,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ),
                                          ),
                                        ),
                                        // Marking East direction
                                        Text(
                                          'E',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 10.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka'
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Marking South direction
                                    Text(
                                      'S',
                                      style: TextStyle(
                                        color: themeData[currentSettings['theme']]!['text'],
                                        fontSize: 10.0 * heightFactor,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Fredoka'
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Sunrise, Sunset and Daylight Time, and Humidity, Pressure and Visibility Data
                Row(
                  children: [
                    // Sunrise, Sunset and Daylight Time
                    Container(
                      // decoration of the container
                      decoration: BoxDecoration(
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: themeData[currentSettings['theme']]!['accent']!,
                          width: 2.0 * widthFactor,
                        ),
                      ),
                      // margin and padding of the container
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
                      // width and height of the container
                      height: deviceHeight * 0.15,
                      width: deviceWidth * 0.52,
                      child: SingleChildScrollView(
                        child: Column(
                          // alignment of the children
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Sunrise and Sunset Labels
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sunrise', // sunrise label
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 18.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        'Sunset', // sunset label
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 18.0 * heightFactor,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Spacing between the labels and the values
                                  Container(
                                    width: 15.0 * widthFactor,
                                  ),
                                  // Sunrise and Sunset Values
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        makeReadableTIme(getLocalTime(weather!.sunrise!)), // sunrise value
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                      Text(
                                        makeReadableTIme(getLocalTime(weather!.sunset!)), // sunset value
                                        style: TextStyle(
                                          color: themeData[currentSettings['theme']]!['text'],
                                          fontSize: 15.0 * heightFactor,
                                          fontFamily: 'Fredoka'
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Spacing between the values and the icons
                                  Container(
                                    width: 15.0 * widthFactor,
                                  ),
                                  // Sunrise and Sunset Icons
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.wb_sunny, // sunrise icon
                                        color: const Color.fromARGB(255, 228, 228, 0),
                                        size: 24.0 * heightFactor,
                                      ),
                                      // Make the moon icon rotate a bit to make it look like the stereotypical moon
                                      Transform.rotate(
                                        angle: math.pi * 1.75, // angle found through trial and error
                                        child: Icon(
                                          Icons.nightlight_round, // moon icon indicating sunset
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          size: 24.0 * heightFactor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // divider
                            Container(
                              margin: EdgeInsets.only(
                                top: 10 * heightFactor,
                                bottom: 10 * heightFactor
                              ),
                              height: 1.0 * heightFactor,
                              color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                              width: deviceWidth * 0.50,
                            ),
                            // Total Daylight Time
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Daylight Time', // daylight time label
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 16.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka'
                                          ),
                                        ),
                                        Text(
                                          '${(weather!.sunset!.difference(weather!.sunrise!)).inHours} Hours ${(weather!.sunset!.difference(weather!.sunrise!)).inMinutes.remainder(60)} Minutes', // Total daylight time value
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontFamily: 'Fredoka'
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Spacing between the values and the icons
                                  Container(
                                    width: 15.0 * widthFactor,
                                  ),
                                  // Daylight Time Icon (Sun)
                                  Icon(
                                    Icons.wb_sunny,
                                    color: const Color.fromARGB(255, 228, 228, 0),
                                    size: 20.0 * heightFactor,
                                  ),
                                  // Arrow Icon
                                  Icon(
                                    Icons.arrow_right_alt,
                                    color: themeData[currentSettings['theme']]!['text'],
                                    size: 20.0 * heightFactor,
                                  ),
                                  // Daylight Time Icon (Moon)
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
                    ),
                    // Humidity, Pressure and Visibility Data
                    Expanded(
                      child: Container(
                        // decoration of the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0 * widthFactor,
                          ),
                        ),
                        // margin and padding of the container
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
                        // height of the container
                        height: deviceHeight * 0.15,
                        child: Column(
                          children: [
                            // Humidity Data
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Humidity Label
                                  Text(
                                    'Humidity', // humidity label
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text'],
                                      fontSize: 18.0 * heightFactor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Fredoka'
                                    ),
                                  ),
                                  // spacing between label and value
                                  Container(
                                    width: 10.0 * widthFactor,
                                  ),
                                  // Humidity Value
                                  Text(
                                    '${weather!.humidity} %', // humidity value
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text'],
                                      fontSize: 15.0 * heightFactor,
                                      fontFamily: 'Fredoka'
                                    ),
                                  ),
                                  // spacing between value and icon
                                  Container(
                                    width: 5.0 * widthFactor,
                                  ),
                                  // Humidity Icon
                                  Icon(
                                    Icons.water_drop_rounded, // humidity icon
                                    color: const Color.fromARGB(255, 0, 0, 197),
                                    size: 30.0 * heightFactor,
                                  ),
                                ],
                              ),
                            ),
                            // divider
                            Container(
                              margin: EdgeInsets.only(
                                top: 5 * heightFactor,
                              ),
                              height: 1.0 * heightFactor,
                              color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                              width: deviceWidth * 0.50,
                            ),
                            // Pressure and Visibility Data
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  // alignment of the children
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Pressure Data
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Pressure Label
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              'Pressure', // pressure label
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 18.0 * heightFactor,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ),
                                          // Pressure Value
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              convertPressure(weather!.pressure!), // pressure value
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 15.0 * heightFactor,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ),
                                          // Pressure Icon
                                          Icon(
                                            Icons.speed_rounded, // pressure icon
                                            color: const Color.fromARGB(255, 177, 0, 0),
                                            size: 30.0 * heightFactor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // divider
                                    Container(
                                      width: 1.0 * widthFactor,
                                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                      height: 100.0 * heightFactor,
                                      margin: EdgeInsets.only(
                                        left: 10.0 * widthFactor,
                                        right: 10.0 * widthFactor
                                      ),
                                    ),
                                    // Visibility Data
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Visibility Label
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              'Visibility', // visibility label
                                              style: TextStyle(
                                                color: themeData
                                                [currentSettings['theme']]!['text'],
                                                fontSize: 18.0 * heightFactor,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ),
                                          // Visibility Value
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              convertVisibility(weatherData!['visibility']), // visibility value
                                              style: TextStyle(
                                                color: themeData[currentSettings['theme']]!['text'],
                                                fontSize: 15.0 * heightFactor,
                                                fontFamily: 'Fredoka'
                                              ),
                                            ),
                                          ),
                                          // Visibility Icon
                                          Icon(
                                            Icons.visibility, // visibility icon
                                            color: const Color.fromARGB(255, 0, 138, 0),
                                            size: 30.0 * heightFactor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]
                        )
                      ),
                    )
                  ],
                ),
                // Forecast for the next 24 hours
                Container(
                  // width and height of the container
                  width: deviceWidth - (20.0 * widthFactor),
                  height: deviceHeight * 0.20,
                  // container decoration
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  // margin and padding of the container
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Forecast Title
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            'Next 24 Hours Forecast for Every 3 Hours', // forecast title
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text'],
                              fontSize: 16.0 * heightFactor,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Fredoka'
                            ),
                          ),
                        ),
                        // divider
                        Container(
                          height: 2.0 * heightFactor,
                          width: deviceWidth - (20.0 * widthFactor),
                          margin: EdgeInsets.only(
                            top: 5.0 * heightFactor,
                            bottom: 5.0 * heightFactor,
                          )
                        ),
                        // Forecast Data
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Forecast Data for every 3 hours added on loop
                              for(var i in forecast!.getRange(0, 8))
                                Container(
                                  // width and height of the container
                                  width: deviceWidth * 0.20,
                                  height: deviceHeight * 0.14,
                                  margin: EdgeInsets.only(
                                    left: 5.0 * widthFactor,
                                    right: 5.0 * widthFactor,
                                  ),
                                  // decoration of the container
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
                                      // alignment of the children
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Temperature Data
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '${getTemperatureForWeather(i)['current']}', // temperature value
                                            style: TextStyle(
                                              color: themeData[currentSettings['theme']]!['text'],
                                              fontSize: 20.0 * heightFactor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka'
                                            ),
                                          ),
                                        ),
                                        // divider
                                        Container(
                                          height: 1.0 * heightFactor,
                                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                          width: deviceWidth * 0.20,
                                        ),
                                        // Weather Icon
                                        SizedBox(
                                          height: 80.0 * heightFactor,
                                          child: Image.network(
                                            'http://openweathermap.org/img/wn/${i.weatherIcon}@4x.png',
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                        // divider
                                        Container(
                                          height: 1.0 * heightFactor,
                                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                          width: deviceWidth * 0.20,
                                        ),
                                        // Time of the Forecast
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Center(
                                            child: Text(
                                              makeReadableTIme(getLocalTime(i.date!)), // time of the forecast
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
                ),
                // Forecast for 5 days ahead
                Container(
                  // margin and padding of the container
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
                  // width of the container
                  width: deviceWidth - (20.0 * widthFactor),
                  // decoration of the container
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                  ),
                  // Forecast Title
                  child: ExpansionTile(
                    // expansion tile properties (when collapsed)
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // expansion tile properties (when expanded)
                    expandedAlignment: Alignment.center,
                    // shape of the expansion tile
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    trailing: const SizedBox.shrink(),
                    // title of the expansion tile
                    title: Text(
                      'Next 4 Days Forecast', // forecast title
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontSize: 16.0 * widthFactor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      )
                    ),
                    initiallyExpanded: true, // initially expanded
                    // leading icon of the expansion tile
                    leading: Icon(
                      Icons.calendar_today, // calendar icon indicating forecast
                      color: themeData[currentSettings['theme']]!['text'],
                    ),
                    // children of the expansion tile
                    children: <Widget>[
                      // Forecast Data for the next 4 days with padding
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                        ),
                        // Forecast Data for the next 4 days
                        child: Column(
                          children: get4DayForecastViewer(forecast!), // get the forecast for the next 4 days
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // background color of the body
        ),
      );
    } else {
      // Loading Screen
      // ignore: deprecated_member_use
      return WillPopScope(
        // will pop scope used to handle the back button press
        onWillPop: () async {
          Navigator.pop(context, 'reload');
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // do not show the back button
            title: Center(
              child: Text(
                'Loading', // loading text
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text'],
                  fontSize: 30.0 * heightFactor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Fredoka'
                )
              ),
            ),
            shadowColor: themeData[currentSettings['theme']]!['shadow'], // shadow color of the app bar
            elevation: 4.0, // elevation of the app bar
            backgroundColor: themeData[currentSettings['theme']]!['appBar'], // background color of the app bar
          ),
          // body of the loading screen with a circular progress indicator
          body: const Center(
            child: CircularProgressIndicator(),
          ),
          backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // background color of the body
        ),
      );
    }
  }
}