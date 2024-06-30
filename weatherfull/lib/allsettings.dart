import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/weather.dart';

var settings = Hive.box('settings');
var x = SchedulerBinding.instance.platformDispatcher.platformBrightness;
String theme = x == Brightness.dark ? 'dark' : 'light';
// ignore: unused_element
var _ = settings.put('theme', theme);

String previousRoute = '/homepage';

double heightFactor = 1;
double widthFactor = 1;
double deviceWidth = 484;
double deviceHeight = 1025;

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

Map<String, String> currentSettings = {
  'temperature': settings.get('temperature', defaultValue: 'celcius'),
  'wind_speed': settings.get('wind_speed', defaultValue: 'meter-per-second'),
  'theme': settings.get('theme', defaultValue: theme),
  'time_format': settings.get('time_format', defaultValue: '24'),
  'date_format': settings.get('date_format', defaultValue: 'dmy'),
  'pressure': settings.get('pressure', defaultValue: 'hPa'),
  'visibility': settings.get('visibility', defaultValue: 'meters'),
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
    'text': Color.fromARGB(255, 255, 255, 255),
    'flat_icons': Color.fromARGB(255, 209, 209, 209),
    'shadow': Color.fromARGB(255, 219, 218, 218),
    'dropdown_text': Color.fromARGB(255, 0, 0, 0),
    'dropdown_accent': Color.fromARGB(255, 202, 202, 202),
  },
};

final Map weekdays = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

// Function to convert temperature to the selected unit in the settings
String convertTemp(double temp) {
  // If the temperature is in celcius, return the temperature as it is
  if(currentSettings['temperature'] == 'celcius') {
    return '${temp.toStringAsFixed(0)} °C';
  } else if(currentSettings['temperature'] == 'fahrenheit') {
    // If the temperature is in fahrenheit, convert it to fahrenheit and return
    return '${(((temp*9)/5) + 32).toStringAsFixed(0)} °F';
  } else {
    // If the temperature is in kelvin, convert it to kelvin and return
    return '${(temp + 273.15).toStringAsFixed(0)} K';
  }
}

// Function to get the temperature data for the weather
Map<String, String> getTemperatureForWeather(Weather w) {
  // defining the current temperature, minimum temperature, maximum temperature, and feels like temperature variables
  String currentTemp, minTemp, maxTemp, feelsLikeTemp;

  // An if else check to get the temperature in the selected unit in the settings
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
  // Return the temperature data in a map
  return {
    'current' : currentTemp,
    'min' : minTemp,
    'max' : maxTemp,
    'feels_like' : feelsLikeTemp,
  };
}

// Function to make the 2nd part of the address better by capitalizing the first letter of each word and acronymizing the words
String makeBetter2ndAddress(String address) {
  // Split the address by ', ' to get the parts of the address
  List<String> parts = address.split(', ');
  // The final string to return
  String finalString = '';
  // For each part of the address
  for (int i = 0; i < parts.length; i++) {
    // Split the part by ' ' to get the words of the part
    List<String> words = parts[i].split(' ');
    String part = '';
    // If the part has more than one word
    if (words.length > 1) {
      // For each word in the part
      for (int j = 0; j < words.length; j++) {
        // add the first letter of the word capitalized to the part
        part += words[j][0].capitalize();
      }
    } else {
      // If the part has only one word, add the first two letters of the word to the part
      part += parts[i];
    }
    // If it is the first part, add the part to the final string
    if (i == 0) {
      finalString += part;
    } else {
      // If it is not the first part, add ', ' and the part to the final string
      finalString += ', $part';
    }
  }
  // Return the final string
  return finalString;
}


// An extension to the string class to capitalize the first letter of each word in a given string
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