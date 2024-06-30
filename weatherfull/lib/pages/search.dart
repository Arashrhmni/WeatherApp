import 'package:google_places_autocomplete_text_field/model/prediction.dart';

import '../allsettings.dart';
import 'package:flutter/material.dart';
import '../confidential_constants.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// history box
var history = Hive.box('history');
List<String> historyList = history.get('history', defaultValue: []); // get history list
List<List<double>> historyLatLongList = history.get('latlong', defaultValue: []); // get history lat long list

// get latitude and longitude of a city
Future<List<double>> getLatitudeLongitude(String city) async {
  String apiKey = googleAPIKey; // get your own API key from Google Cloud Console
  String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=$apiKey'; // get the latitude and longitude of the city

  // get the response
  final response = await http.get(Uri.parse(url));

  // if the response is successful, get the latitude and longitude
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body); // decode the response
    var lat = data['results'][0]['geometry']['location']['lat'] as double; // get the latitude
    var lng = data['results'][0]['geometry']['location']['lng'] as double; // get the longitude
    return [lat, lng]; // return the latitude and longitude
  } else {
    throw Exception('Failed to load latitude and longitude'); // throw an exception if the response is not successful
  }
}

// get the autocomplete results
dynamic getAutocompleteResults(String input) async {
  String apiKey = googleAPIKey; // get your own API key from Google Cloud Console
  String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&key=$apiKey'; // get the autocomplete results

  // get the response
  final response = await http.get(Uri.parse(url));

  // if the response is successful, get the predictions
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body); // decode the response
    var predictions = data['predictions']; // get the predictions
    return predictions; // return the predictions
  } else {
    throw Exception('Failed to load autocomplete results'); // throw an exception if the response is not successful
  }
}

// Search stateful widget
class SearchWindow extends StatefulWidget {
  const SearchWindow({super.key});

  @override
  State<SearchWindow> createState() => _SearchWindowState();
}

class _SearchWindowState extends State<SearchWindow> {

  // controller for the text field
  TextEditingController controller = TextEditingController();
  List<dynamic> predictions = []; // predictions list

  // init state
  @override
  void initState() {
    super.initState();

    // Add a listener to the controller to fetch autocomplete results
    // whenever the text changes
    controller.addListener(() async {
      String input = controller.text; // get the input
      if (input.isNotEmpty) {
        predictions = await getAutocompleteResults(input); // get the autocomplete results
        setState(() {}); // Update the UI
      } else {
        predictions = []; // clear the predictions list
        setState(() {}); // Update the UI
      }
    });
  }

  // dispose
  @override
  Widget build(BuildContext context) {

    previousRoute = '/search'; // set the previous route to '/search'
    bool shouldDisplay = true; // should display the autocomplete results
    List<double> cityLatLong = []; // city latitude and longitude
    
    // will pop scope to handle back button
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        // pop and push named to the homepage
        Navigator.popAndPushNamed(context, '/homepage');
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'], // app bar color
          shadowColor: themeData[currentSettings['theme']]!['shadow'], // app bar shadow color
          elevation: 4.0, // app bar elevation
          leading: Container(
            // adding margin to the leading icon so that it is not stuck to the left edge
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor // margin left
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
              icon: Icon(
                Icons.home, // home icon
                color: themeData[currentSettings['theme']]!['text'], // icon color
                size: 30.0 * heightFactor,
              )
            ),
          ),
          title: Center(
            child: Text(
              'Search', // app bar title
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Fredoka'
              )
            ),
          ),
          actions: [
            Container(
              // adding margin to the settings icon so that it is not stuck to the right edge
              margin: EdgeInsets.only(
                right: 15.0 * widthFactor // margin right
              ),
              child: IconButton(
                icon: Icon(
                  Icons.settings_sharp, // settings icon
                  size: 30.0 * heightFactor,
                ),
                color: themeData[currentSettings['theme']]!['flat_icons'], // icon color
                onPressed: () async {
                  // push named to the settings page
                  var result = await Navigator.pushNamed(context, '/settings');
                  if (result == 'themeChanged') {
                    // if the theme is changed, update the UI
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Container(
                  // padding and margin for the text field
                  padding: EdgeInsets.only(
                    top: 10.0 * heightFactor, 
                    bottom: 10.0 * heightFactor, 
                    left: 10.0 * widthFactor, 
                    right: 10.0 * widthFactor
                  ),
                  margin: EdgeInsets.only(
                    top: 10.0 * heightFactor, 
                    bottom: 10.0 * heightFactor, 
                    left: 10.0 * widthFactor, 
                    right: 10.0 * widthFactor
                  ),
                  // container decoration
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    children: [
                      // text field for searching
                      TextField(
                        // on tap outside, unfocus the text field
                        onTapOutside: (event) async {
                          await Future.delayed(Duration.zero);
                          setState(() {
                            shouldDisplay = false;
                          });
                        },
                        // text field properties
                        style: TextStyle(
                          color: themeData[currentSettings['theme']]!['text'],
                          fontFamily: 'Fredoka',
                        ),
                        controller: controller, // controller for the text field
                        decoration: InputDecoration(
                          border: InputBorder.none, // no border
                          hintText: 'Search for a city', // hint text
                          hintStyle: TextStyle(
                            color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.4),
                            fontFamily: 'Fredoka',
                          ),
                        ),
                        // on changed, get the autocomplete results
                        onChanged: (value) async {
                          await Future.delayed(Duration.zero); // delay
                          if (value.isEmpty || shouldDisplay == false) { // if the value is empty or shouldDisplay is false
                            setState(() {
                              predictions = []; // clear the predictions list
                              shouldDisplay = false; // shouldDisplay is false
                            });
                          } else {
                            predictions = await getAutocompleteResults(value); // get the autocomplete results
                            setState(() {
                              shouldDisplay = true; // shouldDisplay is true
                            });
                          }
                        },
                      ),
                      // list view for the autocomplete results
                      Visibility(
                        visible: shouldDisplay && predictions.isNotEmpty, // visible if shouldDisplay is true and predictions is not empty
                        child: SizedBox(
                          height: deviceHeight * 0.2, // height of the list view
                          child: ListView.builder(
                            itemCount: predictions.length, // number of items
                            itemBuilder: (context, index) {
                              Prediction prediction = Prediction.fromJson(predictions[index]); // get the prediction
                              // list tile for the prediction
                              return ListTile(
                                leading: Icon(
                                  Icons.location_city, // location city icon
                                  color: themeData[currentSettings['theme']]!['text'],
                                ),
                                // title for the prediction, contains the description
                                title: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal, // scroll direction
                                  child: Text(
                                    prediction.description ?? "", // description
                                    style: TextStyle(
                                      color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                                      fontFamily: 'Fredoka',
                                    ),
                                  ),
                                ),
                                // on tap, get the latitude and longitude of the city
                                onTap: () async {
                                  cityLatLong = await getLatitudeLongitude(prediction.description!); // get the latitude and longitude
                                  // update the history list and lat long list
                                  setState(() {
                                    historyList.insert(0, prediction.description!); // insert the city name
                                    historyList = historyList.toSet().toList(); // convert to set and then to list
                                    historyLatLongList.insert(0, cityLatLong); // insert the city lat long
                                    historyLatLongList = historyLatLongList.toSet().toList(); // convert to set and then to list
                                    if (historyList.length > 10) {
                                      historyList.removeLast(); // remove the last element if the length is greater than 10
                                    }
                                    if (historyLatLongList.length > 10) {
                                      historyLatLongList.removeLast(); // remove the last element if the length is greater than 10
                                    }
                                    history.put('history', historyList); // put the history list
                                    history.put('latlong', historyLatLongList); // put the history lat long list
                                    predictions = []; // clear the predictions list
                                    shouldDisplay = false; // shouldDisplay is false
                                    // push named to the weather page
                                    Navigator.pushNamed(
                                      context,
                                      '/weather',
                                      arguments: {
                                        'cityLatLong': historyLatLongList[0],
                                        'cityName': historyList[0],
                                      },
                                    );
                                  });
                                },
                              );
                            }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // padding and margin for the history container
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
                  // history container decoration
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0 * widthFactor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // cross axis alignment
                    children: [
                      Text(
                        'History', // history text
                        style: TextStyle(
                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Fredoka'
                        ),
                      ),
                      // divider
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor, 
                          bottom: 5.0 * heightFactor
                        ),
                        height: 1.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['accent'],
                      ),
                      // 
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(), // never scrollable scroll physics
                        shrinkWrap: true, // shrink wrap
                        itemCount: historyList.length, // number of items
                        itemBuilder: (context, index) {
                          // list tile to show history item
                          return ListTile(
                            // leading icon
                            leading: Icon(
                              Icons.history, // history icon
                              color: themeData[currentSettings['theme']]!['text'],
                            ),
                            // title single child scroll view so it doesn't overflow
                            title: SingleChildScrollView(
                              scrollDirection: Axis.horizontal, // scroll direction is horizontal
                              child: Text(
                                historyList[index], // get the history item at the current index
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontFamily: 'Fredoka',
                                ),
                              ),
                            ),
                            onTap: () {
                              // push the weather page
                              Navigator.pushNamed(
                                context,
                                '/weather',
                                arguments: {
                                  'cityLatLong': historyLatLongList[index],
                                  'cityName': historyList[index],
                                }
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // color of the body
      ),
    );
  }
}