import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_size/window_size.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/about.dart';
import 'pages/weather.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/settings.dart';
import 'pages/contact.dart';
import 'allsettings.dart';

// main function
void main() async {
  // make sure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize hive
  await Hive.initFlutter();
  // open boxes
  await Hive.openBox('settings');
  await Hive.openBox('history');
  await Hive.openBox('favourites');
  await Hive.openBox('lastLocation');

  // get history box and make sure it does not have duplicate values
  var history = Hive.box('history');
  var historyList = history.get('history', defaultValue: <String>[]).cast<String>();
  historyList = historyList.toSet().toList();
  var historyLatLongList = history.get('latlong', defaultValue: <List<double>>[]).cast<List<double>>();
  historyLatLongList = historyLatLongList.toSet().toList();
  history.put('history', historyList);
  history.put('latlong', historyLatLongList);

  // if the device is not web, and is being run on a desktop, set the window size to unchangeable
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setWindowSize(const Size(450, 900));
    setWindowMinSize(const Size(450, 900));
    setWindowMaxSize(const Size(450, 900));
  }

  // request location permission, if denied, permanently denied or restricted, open app settings, if granted, continue with the app else exit
  var status = await Permission.locationWhenInUse
      .onDeniedCallback(() {
        openAppSettings();
      })
      .onGrantedCallback(() {
        
      })
      .onPermanentlyDeniedCallback(() {
        openAppSettings();
      })
      .onRestrictedCallback(() {
        openAppSettings();
      })
      .onLimitedCallback(() {
        openAppSettings();
      })
      .onProvisionalCallback(() {
        
      })
    .request();
  if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
    exit(1);
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(
      const Root()
    );
  });
}

// root widget
class Root extends StatelessWidget {
  const Root({super.key});

  // build function
  @override
  Widget build(BuildContext context) {
    // get device width and height
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    // calculate width and height factors
    widthFactor = deviceWidth / 484;
    heightFactor = deviceHeight / 1025;
    
    // return material app
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      routes: {
        '/homepage': (context) => const HomeScreen(), // home screen
        '/search': (context) => const SearchWindow(), // search screen
        '/settings': (context) => const SettingsWindow(), // settings screen
        '/weather': (context) => WeatherScreen(cityLatLong: ((ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['cityLatLong'] as List<dynamic>).cast<double>(),cityName: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['cityName'] as String), // weather screen
        '/contact': (context) => const ContactScreen(), // contact screen
        '/about': (context) => const AboutUsScreen(), // about screen
      },
      home: const HomeScreen() // home screen
    );
  }
}