import 'package:google_places_autocomplete_text_field/model/prediction.dart';

import '../allsettings.dart';
import 'package:flutter/material.dart';
import '../apikeys.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


var history = Hive.box('history');
List<String> historyList = history.get('history', defaultValue: []);
List<List<double>> historyLatLongList = history.get('latlong', defaultValue: []);

Future<List<double>> getLatitudeLongitude(String city) async {
  String apiKey = googleAPIKey;
  String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$city&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var lat = data['results'][0]['geometry']['location']['lat'] as double;
    var lng = data['results'][0]['geometry']['location']['lng'] as double;
    print([lat, lng]);
    return [lat, lng];
  } else {
    throw Exception('Failed to load latitude and longitude');
  }
}

dynamic getAutocompleteResults(String input) async {
  String apiKey = googleAPIKey;
  String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    var predictions = data['predictions'];
    return predictions;
  } else {
    throw Exception('Failed to load autocomplete results');
  }
}

class SearchWindow extends StatefulWidget {
  const SearchWindow({super.key});

  @override
  State<SearchWindow> createState() => _SearchWindowState();
}

class _SearchWindowState extends State<SearchWindow> {

  TextEditingController controller = TextEditingController();
  List<dynamic> predictions = [];

  @override
  void initState() {
    super.initState();

    // Add a listener to the controller to fetch autocomplete results
    // whenever the text changes
    controller.addListener(() async {
      String input = controller.text;
      if (input.isNotEmpty) {
        predictions = await getAutocompleteResults(input);
        setState(() {}); // Update the UI
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    previousRoute = '/search';
    bool shouldDisplay = true;
    double height = MediaQuery.of(context).size.height * 0.2;
    List<double> cityLatLong = [];
    // Widget screen = WeatherScreen(latitube, longitude);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData[currentSettings['theme']]!['appBar'],
        shadowColor: themeData[currentSettings['theme']]!['shadow'],
        elevation: 4.0,
        leading: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/homepage');
          },
          child: const Image(
            image: AssetImage('assets/images/logo.png')
          ),
        ),
        title: Center(
          child: Text(
            'Search  ',
            style: TextStyle(
              color: themeData[currentSettings['theme']]!['text'],
            )
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_sharp,
            ),
            color: themeData[currentSettings['theme']]!['flat_icons'],
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: themeData[currentSettings['theme']]!['main_body_background'],
                  border: Border.all(
                    color: themeData[currentSettings['theme']]!['accent']!,
                    width: 2.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  children: [
                    TextField(
                      onTapOutside: (event) async {
                        await Future.delayed(Duration.zero);
                        setState(() {
                          height = 0.0;
                          shouldDisplay = false;
                        });
                      },
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for a city',
                        hintStyle: TextStyle(
                          color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                        ),
                      ),
                      onChanged: (value) async {
                        await Future.delayed(Duration.zero);
                        if (value.isEmpty || shouldDisplay == false) {
                          setState(() {
                            predictions = [];
                            shouldDisplay = false;
                          });
                        } else {
                          predictions = await getAutocompleteResults(value);
                          setState(() {
                            height = MediaQuery.of(context).size.height * 0.2;
                            shouldDisplay = true;
                          });
                        }
                      },
                    ),
                    Visibility(
                      visible: shouldDisplay && predictions.isNotEmpty,
                      child: SizedBox(
                        height: height,
                        child: ListView.builder(
                          itemCount: predictions.length,
                          itemBuilder: (context, index) {
                            Prediction prediction = Prediction.fromJson(predictions[index]);
                            return ListTile(
                              title: Text(
                                prediction.description ?? "",
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                                ),
                              ),
                              onTap: () async {
                                cityLatLong = await getLatitudeLongitude(prediction.description!);
                                setState(() {
                                  historyList.insert(0, prediction.description!);
                                  historyList = historyList.toSet().toList();
                                  historyLatLongList.insert(0, cityLatLong);
                                  historyLatLongList = historyLatLongList.toSet().toList();
                                  if (historyList.length > 10) {
                                    historyList.removeLast();
                                  }
                                  if (historyLatLongList.length > 10) {
                                    historyLatLongList.removeLast();
                                  }
                                  history.put('history', historyList);
                                  history.put('latlong', historyLatLongList);
                                  predictions = [];
                                  shouldDisplay = false;
                                  Navigator.pushNamed(
                                    context,
                                    '/weather',
                                    arguments: cityLatLong,
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
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: themeData[currentSettings['theme']]!['main_body_background'],
                  border: Border.all(
                    color: themeData[currentSettings['theme']]!['accent']!,
                    width: 2.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.7),
                        
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 0, right: 0),
                      height: 1.0,
                      color: themeData[currentSettings['theme']]!['accent'],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            historyList[index],
                            style: TextStyle(
                              color: themeData[currentSettings['theme']]!['text'],
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/weather',
                              arguments: historyLatLongList[index]
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
      backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], 
    );
  }
}