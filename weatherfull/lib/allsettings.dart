import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/weather.dart';

// settings box
var settings = Hive.box('settings');

// extracting the theme from the platform brightness
var x = SchedulerBinding.instance.platformDispatcher.platformBrightness;
String theme = x == Brightness.dark ? 'dark' : 'light';
// putting the theme in the settings box
// ignore: unused_element
var _ = settings.put('theme', theme);

// defining the previous route
String previousRoute = '/homepage';

// height and width factors for the responsiveness of the app
double heightFactor = 1;
double widthFactor = 1;
double deviceWidth = 484; // value derived from the device width of the phone used for development
double deviceHeight = 1025; // value derived from the device height of the phone used for development

// Map of the temperature units
const Map<String, String> temperatures = {
  'celcius': '°C',
  'fahrenheit': '°F',
  'kelvin': 'K',
};

// Map of the wind speed units
const Map<String, String> windspeeds = {
  'meter-per-second': 'm/s',
  'kilometer-per-hour': 'km/h',
  'miles-per-hour': 'mph',
};

// Map of the theme data for both light and dark themes
const Map<String, Map<String, Color>> themeData = {
  // Light theme data
  'light': {
    'appBar': Color.fromARGB(255, 59, 138, 187), // Color for the app bar
    'main_body_background': Color.fromARGB(255, 129, 195, 240), // Color for the main body background 
    'accent': Color.fromARGB(255, 32, 127, 186), // Color for the accent
    'text': Color.fromARGB(255, 0, 0, 0), // Color for the text
    'flat_icons': Color.fromARGB(255, 0, 0, 0), // Color for the flat icons
    'shadow': Color.fromARGB(255, 0, 0, 0), // Color for the shadow
  },
  // Dark theme data
  'dark': { 
    'appBar': Color.fromARGB(255, 32, 127, 186), // Color for the app bar
    'main_body_background': Color.fromARGB(255, 34, 68, 100), // Color for the main body background
    'accent': Color.fromARGB(255, 52, 135, 187), // Color for the accent
    'text': Color.fromARGB(255, 255, 255, 255), // Color for the text
    'flat_icons': Color.fromARGB(255, 209, 209, 209), // Color for the flat icons
    'shadow': Color.fromARGB(255, 219, 218, 218), // Color for the shadow
  },
};

// storing the data of the team members
const List<Map<String, String>> teamData = [
  {
    'name': 'Rafael de Athayde Moraes',
    'role': 'Scrum Master',
    'image': 'assets/images/rafael.jpg',
    'matriculation': '59752266',
    'email': 'rafael.deathaydemoraes@ue-germany.de'
  },
  {
    'name': 'Paulo Cesar Moraes',
    'role': 'Product Owner',
    'image': 'assets/images/paulo.jpg',
    'matriculation': '39960655',
    'email': 'paulocesar.quadrosdefreitascardosodemoraes@ue-germany.de'
  },
  {
    'name': 'Arash Rahmani',
    'role': 'Tester',
    'image': 'assets/images/arash.jpg',
    'matriculation': '26819056',
    'email': 'arash.rahmani@ue-germany.de'
  },
  {
    'name': 'Shaurrya Baheti',
    'role': 'Developer',
    'image': 'assets/images/shaurrya.jpg',
    'matriculation': '63119302',
    'email': 'shaurrya.baheti@ue-germany.de'
  },
  {
    'name': 'Srivetrikumaran Senthilnayagam',
    'role': 'Developer',
    'image': 'assets/images/siri.jpg',
    'matriculation': '63292185',
    'email': 'senthilnayagam.srivetrikumaran@ue-germany.de'
  },
  {
    'name': 'Emmanuel Nwogo',
    'role': 'Developer',
    'image': 'assets/images/emmanuel.jpg',
    'matriculation': '99219199',
    'email': 'emmanuel.nwogo@ue-germany.de'
  },
];

// Map of the weekdays
final Map weekdays = <int, String>{
    DateTime.monday: 'Monday',
    DateTime.tuesday: 'Tuesday',
    DateTime.wednesday: 'Wednesday',
    DateTime.thursday: 'Thursday',
    DateTime.friday: 'Friday',
    DateTime.saturday: 'Saturday',
    DateTime.sunday: 'Sunday',
  };

// Map of the current settings of the app
Map<String, String> currentSettings = {
  'temperature': settings.get('temperature', defaultValue: 'celcius'),
  'wind_speed': settings.get('wind_speed', defaultValue: 'meter-per-second'),
  'theme': settings.get('theme', defaultValue: theme),
  'time_format': settings.get('time_format', defaultValue: '24'),
  'date_format': settings.get('date_format', defaultValue: 'dmy'),
  'pressure': settings.get('pressure', defaultValue: 'hPa'),
  'visibility': settings.get('visibility', defaultValue: 'meters'),
};

// Function to make an icon from the icon code and size
dynamic makeIcon(String icon, String size) {
  if (icon == '') {
    return const Text('!'); // Return a text widget with '!' if the icon is empty
  } else {
    return Image.network('https://openweathermap.org/img/wn/$icon@$size.png'); // Return an image widget with the icon from the url
  }
}

// Function to make the time readable
String makeReadableTIme(DateTime d) {
  // Get the time format from the settings
  String fmt = settings.get('time_format', defaultValue: '24');

  // Functions to get the hour, minute, and am/pm of the time
  String hour(DateTime d, int i) { return (d.hour - i) < 10 ? '0${(d.hour - i)}' : '${(d.hour - i)}'; }
  String minute(DateTime d) { return d.minute < 10 ? '0${d.minute}' : '${d.minute}'; }
  String ampm(DateTime d) { return d.hour > 12 ? 'PM' : 'AM'; }

  // If the time format is 24 hours, return the time in 24 hours format
  if (fmt == '24') {
    return '${hour(d, 0)} : ${minute(d)}'; // Return the time in 24 hours format
  } else {
    return '${d.hour > 12 ? hour(d, 12) : hour(d, 0)} : ${minute(d)} ${ampm(d)}'; // Return the time in 12 hours format
  }
}

// Function to make the date readable
String makeReadableDate(DateTime d) {
  // Get the date format from the settings
  String fmt = settings.get('date_format', defaultValue: 'dmy');

  // Functions to get the day, month, and year of the date
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


  if (fmt == 'dmy') {
    return '${day(d)} / ${month(d)} / ${year(d)}'; // Return the date in day/month/year format
  } else if (fmt == 'dym') {
    return '${day(d)} / ${year(d)} / ${month(d)}'; // Return the date in day/year/month format
  } else if (fmt == 'mdy') {
    return '${month(d)} / ${day(d)} / ${year(d)}'; // Return the date in month/day/year format
  } else if (fmt == 'myd') {
    return '${month(d)} / ${year(d)} / ${day(d)}'; // Return the date in month/year/day format
  } else if (fmt == 'ymd') {
    return '${year(d)} / ${month(d)} / ${day(d)}'; // Return the date in year/month/day format
  } else {
    return '${year(d)} / ${day(d)} / ${month(d)}'; // Return the date in year/day/month format
  }
}

// Function to convert the pressure to the selected unit in the settings
String convertPressure(double pressure) {
  // Get the pressure unit from the settings
  String unit = settings.get('pressure', defaultValue: 'hPa');


  if (unit == 'hPa') {
    return '${pressure.toStringAsFixed(1)} hPa'; // Return the pressure in hPa
  } else if (unit == 'atm') {
    return '${(pressure / 1013.25).toStringAsFixed(3)} atm'; // Return the pressure in atm
  } else if (unit == 'mmHg') {
    return '${(pressure * 0.750062).toStringAsFixed(0)} mmHg'; // Return the pressure in mmHg
  } else {
    return '${(pressure * 100).toStringAsFixed(0)} Pa'; // Return the pressure in Pa
  }
}

// Function to convert the visibility to the selected unit in the settings
String convertVisibility(int vis) {
  double visibility = vis.toDouble(); // Convert the visibility to double
  // Get the visibility unit from the settings
  String unit = settings.get('visibility', defaultValue: 'meters');


  if (unit == 'meters') {
    return '${visibility.toStringAsFixed(0)} m'; // Return the visibility in meters
  } else if (unit == 'kilometers') {
    return '${(visibility / 1000).toStringAsFixed(2)} km'; // Return the visibility in kilometers
  } else if (unit == 'miles') {
    return '${(visibility * 0.000621371).toStringAsFixed(2)} miles'; // Return the visibility in miles
  } else {
    return '${(visibility * 3.28084).toStringAsFixed(0)} ft'; // Return the visibility in feet
  }
}

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
      return this; // Return the string if it is empty
    } else {
      String result = ''; // The result string
      bool makeUpper = true; // A boolean to check if the next letter should be capitalized
      for (int i = 0; i < length; i++) {
        result += makeUpper ? this[i].toUpperCase() : this[i].toLowerCase(); // Add the letter to the result string
        makeUpper = this[i] == ' '; // If the letter is a space, the next letter should be capitalized
      }
      return result; // Return the result string
    }
  }
}