import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';

var settings = Hive.box('settings');

String previousRoute = '/homepage';

const Map<String, String> temperatures = {
  'celcius': '°C',
  'fahrenheit': '°F',
  'kelvin': 'K',
};

const Map<String, String> windspeeds = {
  'meter-per-second': 'm/s',
  'kilometer-per-hour': 'km/h',
  'miles-per-hour': 'mph',
};


dynamic makeIcon(String icon, String size) {
  if (icon == '') {
    return const Text('!');
  } else {
    return Image.network('https://openweathermap.org/img/wn/$icon@$size.png');
  }
}

String makeReadableTIme(DateTime d) {
  String fmt = settings.get('time_format', defaultValue: '24');

  String hour(DateTime d, int i) { return (d.hour - i) < 10 ? '0${(d.hour - i)}' : '${(d.hour - i)}'; }
  String minute(DateTime d) { return d.minute < 10 ? '0${d.minute}' : '${d.minute}'; }
  String ampm(DateTime d) { return d.hour > 12 ? 'PM' : 'AM'; }

  if (fmt == '24') {
    return '${hour(d, 0)} : ${minute(d)}';
  } else {
    return '${d.hour > 12 ? hour(d, 12) : hour(d, 0)} : ${minute(d)} ${ampm(d)}';
  }
}

String makeReadableDate(DateTime d) {

  String month(DateTime d) { return d.month < 10 ? '0${d.month}' : '${d.month}'; }
  String day(DateTime d) { return d.day < 10 ? '0${d.day}' : '${d.day}'; }
  String year(DateTime d) {
    if (d.year < 10) {
      return '000${d.year}';
    } else if (d.year < 100) {
      return '00${d.year}';
    } else if (d.year < 1000) {
      return '0${d.year}';
    } else {
      return '${d.year}';
    }
  }

  String fmt = settings.get('date_format', defaultValue: 'dmy');
  if (fmt == 'dmy') {
    return '${day(d)} / ${month(d)} / ${year(d)}';
  } else if (fmt == 'dym') {
    return '${day(d)} / ${year(d)} / ${month(d)}';
  } else if (fmt == 'mdy') {
    return '${month(d)} / ${day(d)} / ${year(d)}';
  } else if (fmt == 'myd') {
    return '${month(d)} / ${year(d)} / ${day(d)}';
  } else if (fmt == 'ymd') {
    return '${year(d)} / ${month(d)} / ${day(d)}';
  } else {
    return '${year(d)} / ${day(d)} / ${month(d)}';
  }
}

double heightFactor = 1;
double widthFactor = 1;
double deviceWidth = 484;
double deviceHeight = 1025;

var x = SchedulerBinding.instance.platformDispatcher.platformBrightness;
String theme = x == Brightness.dark ? 'dark' : 'light';

Map<String, String> currentSettings = {
  'temperature': settings.get('temperature', defaultValue: 'celcius'),
  'wind_speed': settings.get('wind_speed', defaultValue: 'meter-per-second'),
  'theme': settings.get('theme', defaultValue: theme),
  'time_format': settings.get('time_format', defaultValue: '24'),
  'date_format': settings.get('date_format', defaultValue: 'dmy'),
  'pressure': settings.get('pressure', defaultValue: 'hPa'),
  'visibility': settings.get('visibility', defaultValue: 'meters'),
};

String convertPressure(double pressure) {
  String unit = settings.get('pressure', defaultValue: 'hPa');
  if (unit == 'hPa') {
    return '${pressure.toStringAsFixed(1)} hPa';
  } else if (unit == 'atm') {
    return '${(pressure / 1013.25).toStringAsFixed(3)} atm';
  } else if (unit == 'mmHg') {
    return '${(pressure * 0.750062).toStringAsFixed(0)} mmHg';
  } else {
    return '${(pressure * 100).toStringAsFixed(0)} Pa';
  }
}

String convertVisibility(int vis) {
  double visibility = vis.toDouble();
  String unit = settings.get('visibility', defaultValue: 'meters');
  if (unit == 'meters') {
    return '${visibility.toStringAsFixed(0)} m';
  } else if (unit == 'kilometers') {
    return '${(visibility / 1000).toStringAsFixed(2)} km';
  } else if (unit == 'miles') {
    return '${(visibility * 0.000621371).toStringAsFixed(2)} miles';
  } else {
    return '${(visibility * 3.28084).toStringAsFixed(0)} ft';
  }
}

const Map<String, Map<String, Color>> themeData = {
  'light': {
    'appBar': Color.fromARGB(255, 59, 138, 187),
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
    'accent': Color.fromARGB(255, 52, 135, 187),
    'text': Color.fromARGB(255, 240, 240, 240),
    'flat_icons': Color.fromARGB(255, 209, 209, 209),
    'shadow': Color.fromARGB(255, 219, 218, 218),
    'dropdown_text': Color.fromARGB(255, 0, 0, 0),
    'dropdown_accent': Color.fromARGB(255, 202, 202, 202),
  },
};