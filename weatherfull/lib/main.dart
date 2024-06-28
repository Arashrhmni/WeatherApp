import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/about.dart';
import 'pages/weather.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/settings.dart';
import 'pages/contact.dart';
import 'allsettings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('history');
  await Hive.openBox('favourites');
  await Hive.openBox('lastLocation');
  var history = Hive.box('history');
  var historyList = history.get('history', defaultValue: <String>[]).cast<String>();
  historyList = historyList.toSet().toList();
  var historyLatLongList = history.get('latlong', defaultValue: <List<double>>[]).cast<List<double>>();
  historyLatLongList = historyLatLongList.toSet().toList();
  history.put('history', historyList);
  history.put('latlong', historyLatLongList);
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await DesktopWindow.setWindowSize(const Size(450, 900));
    setWindowMinSize(const Size(450, 900));
    setWindowMaxSize(const Size(450, 900));
  }
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

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    widthFactor = deviceWidth / 484;
    heightFactor = deviceHeight / 1025;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/homepage': (context) => const HomeScreen(),
        '/search': (context) => const SearchWindow(),
        '/settings': (context) => const SettingsWindow(),
        '/weather': (context) => WeatherScreen(cityLatLong: ((ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['cityLatLong'] as List<dynamic>).cast<double>(),cityName: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['cityName'] as String),
        '/contact': (context) => const ContactScreen(),
        '/about': (context) => const AboutUsScreen(),
      },
      home: const HomeScreen()
    );
  }
}