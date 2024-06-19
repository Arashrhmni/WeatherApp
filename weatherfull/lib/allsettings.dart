import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

var settings = Hive.box('settings');

String previousRoute = '/homepage';

const Map<String, String> temperatures = {
  'celcius': '°C',
  'fahrenheit': '°F',
};

const Map<String, String> windspeeds = {
  'meter-per-second': 'm/s',
  'kilometer-per-hour': 'km/h',
  'miles-per-hour': 'mph',
};

Map<String, String> currentSettings = {
  'temperature': settings.get('temperature', defaultValue: 'celcius'),
  'wind_speed': settings.get('wind_speed', defaultValue: 'meter-per-second'),
  'theme': settings.get('theme', defaultValue: 'light')
};

const Map<String, Map<String, Color>> themeData = {
  'light': {
    'appBar': Color.fromARGB(255, 32, 127, 186),
    'main_body_background': Color.fromARGB(255, 129, 195, 240),
    'accent': Color.fromARGB(255, 32, 127, 186),
    'text': Color.fromARGB(255, 0, 0, 0),
    'flat_icons': Color.fromARGB(255, 0, 0, 0),
    'shadow': Color.fromARGB(255, 0, 0, 0),
    'dropdown_text': Color.fromARGB(255, 0, 0, 0),
    'dropdown_accent': Color.fromARGB(255, 255, 255, 255),
  },
  'dark': {
    'appBar': Color.fromARGB(255, 32, 127, 186),
    'main_body_background': Color.fromARGB(255, 34, 68, 100),
    'accent': Color.fromARGB(255, 32, 127, 186),
    'text': Color.fromARGB(255, 255, 255, 255),
    'flat_icons': Color.fromARGB(255, 209, 209, 209),
    'shadow': Color.fromARGB(255, 255, 255, 255),
    'dropdown_text': Color.fromARGB(255, 0, 0, 0),
    'dropdown_accent': Color.fromARGB(255, 202, 202, 202),
  },
};