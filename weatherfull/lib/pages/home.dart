import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:weatherfull/confidential_constants.dart';
import '../allsettings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:http/http.dart' as http;

// Variables that will be used throughout the file
List<List<dynamic>> favourites = [];
Widget? favouriteList;

// Function to get just the temperature and icon from the weather object
Future<List<String>> getWeatherData(List<double> latlong) async {
  // create a weather "factory"
  WeatherFactory wf = WeatherFactory(openWeather);
  // get the current weather for the location
  Weather w = await wf.currentWeatherByLocation(latlong[0], latlong[1]);
  // return the temperature and icon
  return [
    getTemperatureForWeather(w)['current']??'', 
    w.weatherIcon??'50d'
  ];
}

// Function to get the temperature and icon for the current location
Future<List<String>> getWeatherDataForCurrentLocation() async {
  // get the current location
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  // make the url for the geocoding api which will help us make the city name
  String uri = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleAPIKey';
  // get the response from the api
  var response = await http.get(Uri.parse(uri));

  // create a variable to store the city name
  String cityName = '';

  // if the response is not 200, then there is no connection to the internet
  if (response.statusCode != 200) {
    // return default values for the temperature, city name, icon, latitude and longitude
    return [
      '', 
      'No connection to the internet', 
      '50d', 
      position.latitude.toString(), 
      position.longitude.toString()
    ];
  } else {
    // else, there is internet connection so we can extract data from the response
    var data = response.body;
    var jsonData = jsonDecode(data);
    // form the city name, this was chosen by looking at the response from the api
    cityName = jsonData['plus_code']['compound_code'].split(' ').sublist(1).join(' ');
  }

  // create a weather "factory"
  WeatherFactory wf = WeatherFactory(openWeather);
  // get the current weather for the location
  Weather w = await wf.currentWeatherByLocation(position.latitude, position.longitude);

  // return the temperature, city name, icon, latitude and longitude
  return [
    getTemperatureForWeather(w)['current']??'', 
    cityName, 
    w.weatherIcon??'50d', 
    position.latitude.toString(), 
    position.longitude.toString()
  ];
}

// HomeScreen Statefull Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Function to get a list view of all the favourites that are stored in the persistent storage
  Widget favouriteContainer() {
    // get the favourites from the persistent storage, if there exists none, then use an empty list
    List<dynamic> favourites = Hive.box('favourites').get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();
    // Now build the list
    return ListView.builder(
      shrinkWrap: true, // make the list view shrink so it only takes the space it needs
      physics: const NeverScrollableScrollPhysics(), // make the list view not scrollable
      itemCount: favourites.length, // the number of items in the list view
      // building the list now
      itemBuilder: (context, index) {
        // each list item is a list tile that will be build as we get a connection to the internet
        return FutureBuilder<List<String>>(
          // get the weather data for the city, (in future)
          future: getWeatherData(favourites[index].sublist(1).cast<double>()),
          // build the list tile, (in future)
          builder: (context, snapshot) {
            // if the connection is done, then we can get the data
            if (snapshot.connectionState == ConnectionState.done) {
              // get the data
              var data = snapshot.data;
              // if the data is not null, then we can update the temperature and icon in the persistent storage, for the current favourite item
              try {
                favourites[index][3] = data![0];
                favourites[index][4] = data[1];
              } catch(e) {
                // ignore this exception for smooth app experience
              } finally {
                // put the current favourites data in the persistent storage
                Hive.box('favourites').put('favourites', favourites);
                // return a list tile with the temperature, city name and icon
                // ignore: control_flow_in_finally
                return ListTile(
                  // The leading value is the temperature, which shows up at the beginning of the list tile
                  leading: Text(
                    data![0], // the temperature
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'], // the text color from the current theme
                      fontSize: 20.0 * heightFactor, // the font size that is set according to the device height
                      fontFamily: 'Fredoka' // the font family that is used
                    ),
                  ),
                  // The title is the city name, which shows up in the middle of the list tile, single child scroll view used
                  // So that the city name can be scrolled if it is too long, or if someone uses too big font size for their device
                  title: SingleChildScrollView(
                    // the scroll direction is horizontal, obviously
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      favourites[index][0], // the city name
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'], // the text color from the current theme
                        fontWeight: FontWeight.w500, // the font weight is set to 500, which is medium
                        fontFamily: 'Fredoka' // the font family that is used
                      ),
                    ),
                  ),
                  // The trailing is the icon, which shows up at the end of the list tile
                  trailing: Image.network(
                    'http://openweathermap.org/img/wn/${data[1]}@2x.png', // the icon url
                    // loading builder is used to show a circular progress indicator while the image is loading
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // if the image is loaded, then return the image
                      } else {
                        return const CircularProgressIndicator(); // else return a circular progress indicator
                      }
                    },
                  ),
                  // when the list tile is tapped, then the user is taken to the weather page for that city
                  onTap: () async {
                    // push the weather page to the navigator stack, then get a result when the page is popped
                    var result = await Navigator.pushNamed(
                      context,
                      '/weather',
                      arguments: {
                        'cityLatLong': [favourites[index][1], favourites[index][2]],
                        'cityName': favourites[index][0],
                      }
                    );
                    // use the result to reload the page, this way if the user changed something, then the page will be reloaded
                    if (result == 'reload') {
                      setState(() {});
                    }
                  },
                );
              }
            } else {
              // if the connection is not done, then we use previously obtained data to show the list tile
              // if there is no icon or temperature in the previously stored data, then we show nothing
              Widget icon = favourites[index].length == 5 ? Image.network(
                  colorBlendMode: BlendMode.overlay, // the color blend mode is overlay, so that the icon is a bit transparent which will tell the user that the data is still loading
                  'http://openweathermap.org/img/wn/${favourites[index][4]}@2x.png', // the icon url
                  // loading builder is used to show a circular progress indicator while the image is loading
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // if the image is loaded, then return the image
                    } else {
                      return const CircularProgressIndicator(); // else return a circular progress indicator
                    }
                  }
                ) : 
                const Text(''); // if there is no icon, then show nothing
              String temp = favourites[index].length == 5 ? favourites[index][3] : ''; // if there is no temperature, then show nothing
              // return a list tile with the temperature, city name and icon
              return ListTile(
                leading: Text(
                  temp, // the temperature
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.4), // the text color from the current theme
                    fontSize: 20.0 * heightFactor, // the font size that is set according to the device height
                    fontFamily: 'Fredoka' // the font family that is used
                  ),
                ),
                title: SingleChildScrollView(
                  // again a single child scroll view is used to scroll the city name if it is too long
                  scrollDirection: Axis.horizontal, // the scroll direction is horizontal
                  child: Text(
                    favourites[index][0], // the city name
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.4), // the text color from the current theme
                      fontWeight: FontWeight.w500, // the font weight is set to 500, which is medium
                      fontFamily: 'Fredoka' // the font family that is used
                    ),
                  ),
                ),
                trailing: icon, // the icon
                onTap: () {}, // do nothing when the list tile is tapped, as this is not loaded yet
              );
            }
          },
        );
      }
    );
  }

  // this function is called when the state object is created
  @override
  void initState() {
    super.initState();
    favouriteList = favouriteContainer(); // get the favourite list
  }

  @override
  Widget build(BuildContext context) {
  
    // this is the previous route, which is used when we are in the settings menu, and we want to go back to the previous route
    previousRoute = '/homepage';

    // get the favourites from the persistent storage
    var favList = Hive.box('favourites');

    // get the favourites from the persistent storage, if there exists none, then use an empty list
    favourites = favList.get('favourites', defaultValue: <List<dynamic>>[]).cast<List<dynamic>>();

    // get the current location data
    List<String> currentLocationData = [];

    DateTime now = DateTime.now();

    // create a future builder to get the weather data for the current location, same principle as the favoruite list
    Widget widg = FutureBuilder<List<String>>(
      future: getWeatherDataForCurrentLocation(), // get the weather data for the current location (in future)
      builder: (context, snapshot) {
        // get the last location data from the persistent storage
        Map<String, dynamic> lastLocation = Hive.box('lastLocation').get('lastLocation', defaultValue: <String, dynamic>{}).cast<String, dynamic>();
        // if the connection is done, then we can get the data
        if (snapshot.connectionState == ConnectionState.done) {
          // get the data
          currentLocationData = snapshot.data!;
          // put the current location data in the persistent storage as the last location
          Hive.box('lastLocation').put('lastLocation', {
            'cityName': currentLocationData[1], // the city name
            'temperature': currentLocationData[0], // the temperature
            'icon': currentLocationData[2], // the icon
            'latlong': [currentLocationData[3], currentLocationData[4]], // the latitude and longitude
          });
          // return a container with the current location data
          return Container(
            // the container margin and padding
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

            // the container decoration
            decoration: BoxDecoration(
              color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5), // the color of the container, taken from the accent color of the current theme
              border: Border.all(
                color: themeData[currentSettings['theme']]!['accent']!, // the color of the border of the container, taken from the accent color of the current theme
                width: 2.0 * widthFactor, // the width of the border, set according to the device width
              ),
              // the border radius of the container, set to 10.0, to get a squircle shape
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),

            // the container child, which is a column
            child: Column(
              // the column alignment is set to start, meaning the children will be aligned to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // the text widget, which shows the text "Current Location" marking the heading of the container
                Text(
                  'Current Location',
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Fredoka'
                  ),
                ),
                // A divider between the heading and the list tile
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor, 
                    bottom: 5.0 * heightFactor
                  ),
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['accent'],
                ),
                // The list tile, which shows the temperature, city name and icon
                ListTile(
                  leading: Text(
                    currentLocationData[0], // the temperature
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'], // the text color from the current theme
                      fontSize: 20.0 * heightFactor, // the font size that is set according to the device height
                      fontFamily: 'Fredoka' // the font family that is used
                    ),
                  ),
                  // the city name
                  title: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      currentLocationData[1], // the city name
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                  // the icon
                  trailing: Image.network(
                    'http://openweathermap.org/img/wn/${currentLocationData[2]}@2x.png', // the icon url
                    // loading builder is used to show a circular progress indicator while the image is loading
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // if the image is loaded, then return the image
                      } else {
                        return const CircularProgressIndicator(); // else return a circular progress indicator
                      }
                    },
                  ),
                  // when the list tile is tapped, then the user is taken to the weather page for the current location
                  onTap: () async {
                    // push the weather page to the navigator stack, then get a result when the page is popped
                    var result = await Navigator.pushNamed(
                      context,
                      '/weather',
                      arguments: {
                        'cityLatLong': [double.parse(currentLocationData[3]), double.parse(currentLocationData[4])],
                        'cityName': currentLocationData[1],
                      }
                    );
                    // use the result to reload the page, this way if the user changed something, then the page will be reloaded
                    if (result == 'reload') {
                      setState(() {});
                    }
                  },
                )
              ],
            ),
          );
        } else {
          // if the connection is not done, then we use previously obtained data to show the list tile
          Widget? listTile = const CircularProgressIndicator(); // show a circular progress indicator while the data is loading and if there is no previous data
          // if there is previous data, then create the list tile with the temperature, city name and icon
          if (lastLocation.isNotEmpty) {
            listTile = ListTile(
              leading: Text(
                lastLocation['temperature'], // the temperature
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5), // the text color from the current theme
                  fontSize: 20.0 * heightFactor, // the font size that is set according to the device height
                  fontFamily: 'Fredoka'
                ),
              ),
              // the city name
              title: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  lastLocation['cityName'], // the city name
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                    fontWeight: FontWeight.w500, // the font weight is set to 500, which is medium
                    fontFamily: 'Fredoka'
                  ),
                ),
              ),
              // the icon
              trailing: Image.network(
                'http://openweathermap.org/img/wn/${lastLocation['icon']}@2x.png',  // the icon url
                colorBlendMode: BlendMode.overlay, // the color blend mode is overlay, so that the icon is a bit transparent which will tell the user that the data is still loading
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              onTap: () {}, // do nothing when the list tile is tapped, as this is not loaded yet
            );
          }
          // return a container with the list tile
          return Container(
            // the container margin and padding
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

            // the container decoration
            decoration: BoxDecoration(
              color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
              border: Border.all(
                color: themeData[currentSettings['theme']]!['accent']!,
                width: 2.0 * widthFactor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            
            // the container child, which is a column
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // the text widget, which shows the text "Current Location" marking the heading of the container
                Text(
                  'Current Location',
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Fredoka'
                  ),
                ),
                // A divider between the heading and the list tile
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0 * heightFactor, 
                    bottom: 5.0 * heightFactor, 
                  ),
                  height: 1.0 * heightFactor,
                  color: themeData[currentSettings['theme']]!['accent'],
                ),
                // The list tile, which shows the temperature, city name and icon or a circular progress indicator
                listTile
              ],
            ),
          );
        }
      },
    );

    // Using willpopscope to control the back button navigation
    // ignore: deprecated_member_use
    return WillPopScope(
      // when the back button is pressed, then show an alert dialog to confirm the exit
      onWillPop: () async {
        // show the alert dialog
        return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actionsAlignment: MainAxisAlignment.end, // align the action buttons to the end i.e. right
            backgroundColor: themeData[currentSettings['theme']]!['accent'], // the background color of the alert dialog
            title: Text(
              'Are you sure?', // the title of the alert dialog
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                fontWeight: FontWeight.w500, // the font weight is set to 500, which is medium
                fontFamily: 'Fredoka'
              ),
            ),
            content: Text(
              'Do you want to exit the app?', // the content of the alert dialog
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                fontFamily: 'Fredoka'
              ),
            ),
            // the action buttons go here
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // if the user presses no, then pop the alert dialog
                child: Text(
                  'No', // the text of the button
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop(); // if the user presses yes, then exit the app
                },
                child: Text(
                  'Yes', // the text of the button
                  style: TextStyle(
                    color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
        )) ?? false;
      },
      // adding a scaffold
      child: Scaffold(
        // the floating action button, which takes the user to the search page
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          backgroundColor: themeData[currentSettings['theme']]!['accent'], // the background color of the floating action button
          foregroundColor: themeData[currentSettings['theme']]!['text'], // the text color of the floating action button
          child: const Icon(Icons.search),
        ),
        // the app bar
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'], // the background color of the app bar
          shadowColor: themeData[currentSettings['theme']]!['shadow'], // the shadow color of the app bar
          elevation: 4.0, // the elevation of the app bar
          // the leading icon button, which takes the user to the contact page
          leading: Container(
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor // only adding margin to the left, so that the icon is not too close to the edge
            ),
            child: IconButton(
              // when pressed the user is taken to the contact page, and when the contact page is popped the page is reloaded
              onPressed: () async {
                var result = await Navigator.pushNamed(context, '/contact');
                if (result == 'reload') {
                  setState(() {});
                }
              },
              // the icon is the contact page icon
              icon: Icon(
                Icons.contact_page_rounded, 
                color: themeData[currentSettings['theme']]!['text'],  // the text color from the current theme
                size: 30.0 * heightFactor, // the size of the icon
              )
            ),
          ),
          // the title of the app bar, which is the app name
          title: Center(
            child: Text(
              'WeatherFull', // the app name
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'], // the text color from the current theme
                fontSize: 30.0 * heightFactor, // the font size that is set according to the device height
                fontWeight: FontWeight.w600,
                fontFamily: 'Fredoka'
              ),
            ),
          ),
          // the action buttons at the end of the appbar
          actions: [
            // the settings icon button, which takes the user to the settings page
            IconButton(
              // padding the icon from the right, so that it is not too close to the edge
              padding: EdgeInsets.only(
                right: 15.0 * widthFactor
              ),
              icon: Icon(
                Icons.settings_sharp,
                size: 30.0 * heightFactor,
              ),
              color: themeData[currentSettings['theme']]!['flat_icons'], // the color of the icon
              // when the icon is pressed, the user is taken to the settings page, and when the settings page is popped the page is reloaded
              onPressed: () async {
                var result = await Navigator.pushNamed(context, '/settings');
                if (result == 'themeChanged') {
                  setState(() {});
                }
              },
            ),
          ],
        ),
        // the body of the scaffold, using single child scroll view to make the body scrollable, so that the contents dont overflow
        body: SingleChildScrollView(
          // the body container that contains all the contents of the body
          child: Container(
            // the container margin and padding
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

            // the main column
            child: Column(
              children: [
                // the row that contains the logo and the current time and date
                Row(
                  children: [
                    // the logo container
                    Container(
                      // the container margin and width
                      margin: EdgeInsets.only(
                        left: 10.0 * widthFactor, 
                        top: 10.0 * heightFactor, 
                        bottom: 10.0 * heightFactor, 
                        right: 5.0 * widthFactor
                      ),
                      width: deviceWidth * 0.45,
                      // the logo button, which takes the user to the about page when pressed
                      child: ElevatedButton(
                        // the button style
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(150, 255, 255, 255)),
                          elevation: WidgetStateProperty.all(5.0), // the elevation of the button
                          shadowColor: WidgetStateProperty.all<Color>(themeData[currentSettings['theme']]!['shadow']!), // the shadow color of the button
                          shape: WidgetStateProperty.all<CircleBorder>(const CircleBorder()), // the shape of the button is a circle
                        ),
                        // when the button is pressed, the user is taken to the about page
                        onPressed: () async {
                          // going to the about page and reloading when the screen is popped so if any changes are made, they are reflected
                          var result = await Navigator.pushNamed(context, '/about');
                          if (result == 'reload') {
                            setState(() {});
                          }
                        },
                        child: Image.asset('assets/images/logo.png') // the logo image
                      ),
                    ),
                    // the current time and date container
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
                          // the current time
                          Text(
                            makeReadableTIme(now), // the current time 
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!,
                              fontSize: 32.0 * heightFactor, // the font size that is set according to the device height
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Fredoka'
                            )
                          ),
                          // the divider between the time and the date
                          Container(
                            height: 2.0 * heightFactor,
                            margin: EdgeInsets.only(
                              left: 5.0 * widthFactor, 
                              right: 5.0 * widthFactor
                            ),
                            color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.2),
                          ),
                          // the current weekday
                          Text(
                            weekdays[now.weekday], // the current weekday
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                              fontSize: 24.0 * heightFactor, // the font size that is set according to the device height
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Fredoka'
                            )
                          ),
                          // the current date
                          Text(
                            makeReadableDate(now), // the current date 
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text']!, // the text color from the current theme
                              fontSize: 18.0 * heightFactor, // the font size that is set according to the device height
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Fredoka'
                            )
                          ),
                        ],
                      )
                    )
                  ],
                ),
                // the current location container
                widg,
                // the favourites container
                Container(
                  // the container margin and padding
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
                  // the container decoration
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5), // the color of the container, taken from the accent color of the current theme
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!, // the color of the border of the container, taken from the accent color of the current theme
                      width: 2.0 * widthFactor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)), // the border radius of the container, set to 10.0, to get a squircle shape
                  ),
                  // the container child, which is a column
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // the column alignment is set to start, meaning the children will be aligned to the left
                    children: [
                      // the text widget, which shows the text "Favorites" marking the heading of the container
                      Text(
                        'Favorites',
                        style: TextStyle(
                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7), // the text color from the current theme
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Fredoka'
                        ),
                      ),
                      // A divider between the heading and the list tile
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor, 
                          bottom: 5.0 * heightFactor
                        ),
                        height: 1.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['accent'],
                      ),
                      // the favourite list
                      favouriteContainer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // the background color of the scaffold
      ),
    );
  }
}