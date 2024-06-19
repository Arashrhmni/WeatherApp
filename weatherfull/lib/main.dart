import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/weather.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('history');
  historyList = Hive.box('history').get('history', defaultValue: <String>[]);
  historyList = historyList.toSet().toList();
  historyLatLongList = Hive.box('history').get('latlong', defaultValue: <List<double>>[]).cast<List<double>>();
  historyLatLongList = historyLatLongList.toSet().toList();
  history.put('history', historyList);
  history.put('latlong', historyLatLongList);
  runApp(
    const Root()
  );
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/homepage': (context) => const HomeScreen(),
        '/search': (context) => const SearchWindow(),
        '/settings': (context) => const SettingsWindow(),
        '/weather': (context) => WeatherScreen(cityLatLong: ModalRoute.of(context)!.settings.arguments as List<double>,),
      },
      home: const HomeScreen()
    );
  }
}