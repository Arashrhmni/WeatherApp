import '../allsettings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// settings box
var settings = Hive.box('settings');
bool isDark = settings.get('theme', defaultValue: theme) == 'dark'; // dark theme boolean
String windspeed = settings.get('wind_speed', defaultValue: 'meter-per-second'); // wind speed
String temperature = settings.get('temperature', defaultValue: 'celcius'); // temperature
String timeFormat = settings.get('time_format', defaultValue: '24'); // time format
String dateFormat = settings.get('date_format', defaultValue: 'dmy'); // date format
String pressure = settings.get('pressure', defaultValue: 'hPa'); // pressure
String visibility = settings.get('visibility', defaultValue: 'meters'); // visibility

// settings stateless widget
class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key});

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {

  // build method
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      // will pop scope for controlling the functionality of the back button
      onWillPop: () async {
        setState(() {});
        Navigator.pop(context, 'themeChanged');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'], // appbar color
          shadowColor: themeData[currentSettings['theme']]!['shadow'], // appbar shadow color
          elevation: 4.0, // appbar shadow elevation
          leading: Container(
            // adding left margin to the leading icon so that it is not stuck to the left edge
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
              icon: Icon(
                Icons.home, // home icon
                color: themeData[currentSettings['theme']]!['text'],
                size: 30 * heightFactor
              )
            ),
          ),
          // title of the screen
          title: Center(
            child: Text(
              'Settings',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Fredoka'
              ),
            ),
          ),
          actions: [
            // back button to go back to the previous screen
            Container(
              margin: EdgeInsets.only(
                right: 15.0 * widthFactor,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context, 'themeChanged');
                },
                icon: Icon(
                  Icons.arrow_back_sharp, // back icon
                  color: themeData[currentSettings['theme']]!['text'], 
                  size: 30 * heightFactor
                )
              ),
            ),
          ]
        ),
        // floating action button to save the settings
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context, 'themeChanged');
            },
            backgroundColor: themeData[currentSettings['theme']]!['accent']!, // floating action button color
            child: Icon(
              Icons.save, // save icon
              color: themeData[currentSettings['theme']]!['text']! // save icon color
            ),
        ),
        body: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                // Theme settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Theme', // theme title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // light theme radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Light', // light theme
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: false, // value of the radio button
                    groupValue: isDark, // group value of the radio buttons
                    onChanged: (value) {
                      // on change of the radio button
                      setState(() {
                        isDark = value as bool; // set the value of the radio button
                        currentSettings['theme'] = 'light'; // set the theme to light
                        settings.put('theme', 'light'); // save the theme to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // dark theme radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Dark', // dark theme
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: true, // value of the radio button
                    groupValue: isDark, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        isDark = value as bool; // set the value of the radio button
                        currentSettings['theme'] = 'dark'; // set the theme to dark
                        settings.put('theme', 'dark'); // save the theme to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Temperature Unit settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Temperature Unit', // temperature title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // celcius radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Celcius (°C)', // celcius
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'celcius', // value of the radio button
                    groupValue: temperature, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String; // set the value of the radio button
                        currentSettings['temperature'] = 'celcius'; // set the temperature to celcius
                        settings.put('temperature', 'celcius'); // save the temperature to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // fahrenheit radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Fahrenheit (°F)', // fahrenheit
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'fahrenheit', // value of the radio button
                    groupValue: temperature, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String; // set the value of the radio button
                        currentSettings['temperature'] = 'fahrenheit'; // set the temperature to fahrenheit
                        settings.put('temperature', 'fahrenheit'); // save the temperature to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // kelvin radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kelvin (K)', // kelvin
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'kelvin', // value of the radio button
                    groupValue: temperature, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String; // set the value of the radio button
                        currentSettings['temperature'] = 'kelvin'; // set the temperature to kelvin
                        settings.put('temperature', 'kelvin'); // save the temperature to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Wind Speed settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Wind-Speed Unit', // wind speed title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // meter per second radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Meter per Second (m/s)', // meter per second
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'meter-per-second', // value of the radio button
                    groupValue: windspeed, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String; // set the value of the radio button
                        currentSettings['wind_speed'] = 'meter-per-second'; // set the wind speed to meter per second
                        settings.put('wind_speed', 'meter-per-second'); // save the wind speed to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // kilometer per hour radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kilometer per Hour (km/h)', // kilometer per hour
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'kilometer-per-hour', // value of the radio button
                    groupValue: windspeed, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String; // set the value of the radio button
                        currentSettings['wind_speed'] = 'kilometer-per-hour';  // set the wind speed to kilometer per hour
                        settings.put('wind_speed', 'kilometer-per-hour'); // save the wind speed to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // miles per hour radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Miles per Hour (mph)', // miles per hour
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'miles-per-hour', // value of the radio button
                    groupValue: windspeed, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String; // set the value of the radio button
                        currentSettings['wind_speed'] = 'miles-per-hour'; // set the wind speed to miles per hour
                        settings.put('wind_speed', 'miles-per-hour'); // save the wind speed to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Pressure settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Pressure Unit',  // pressure title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // pascal radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Pascal (Pa)', // pascal
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'pa', // value of the radio button
                    groupValue: pressure, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String; // set the value of the radio button
                        currentSettings['pressure'] = 'pa'; // set the pressure to pascal
                        settings.put('pressure', 'pa'); // save the pressure to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // hectopascal radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'], 
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Hectopascal (hPa) (1 hPa = 100 Pa)', // hectopascal
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'hPa', // value of the radio button
                    groupValue: pressure, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String; // set the value of the radio button
                        currentSettings['pressure'] = 'hPa'; // set the pressure to hectopascal
                        settings.put('pressure', 'hPa'); // save the pressure to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // standard atmosphere radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Standard Atmosphere (atm)', // standard atmosphere
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'atm', // value of the radio button
                    groupValue: pressure, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String; // set the value of the radio button
                        currentSettings['pressure'] = 'atm'; // set the pressure to standard atmosphere
                        settings.put('pressure', 'atm'); // save the pressure to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // millimeters of mercury radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Millimeters of Mercury (mmHg)', // millimeters of mercury
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'mmHg', // value of the radio button
                    groupValue: pressure, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String; // set the value of the radio button
                        currentSettings['pressure'] = 'mmHg'; // set the pressure to millimeters of mercury
                        settings.put('pressure', 'mmHg'); // save the pressure to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Visibility settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Visibility Unit', // visibility title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // meters radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Meters (m)', // meters
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'meters', // value of the radio button
                    groupValue: visibility, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String; // set the value of the radio button
                        currentSettings['visibility'] = 'meters'; // set the visibility to meters
                        settings.put('visibility', 'meters'); // save the visibility to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // kilometers radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kilometers (km)', // kilometers
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'kilometers', // value of the radio button
                    groupValue: visibility, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String; // set the value of the radio button
                        currentSettings['visibility'] = 'kilometers'; // set the visibility to kilometers
                        settings.put('visibility', 'kilometers'); // save the visibility to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // miles radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Miles (miles)', // miles
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'miles', // value of the radio button
                    groupValue: visibility, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String; // set the value of the radio button
                        currentSettings['visibility'] = 'miles'; // set the visibility to miles
                        settings.put('visibility', 'miles'); // save the visibility to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // feet radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Feet (ft)', // feet
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'feet', // value of the radio button
                    groupValue: visibility, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String; // set the value of the radio button
                        currentSettings['visibility'] = 'feet'; // set the visibility to feet
                        settings.put('visibility', 'feet'); // save the visibility to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Time Format settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Time Format', // time format title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // 24 hour radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      '24 Hour', // 24 hour
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: '24', // value of the radio button
                    groupValue: timeFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        timeFormat = value as String; // set the value of the radio button
                        currentSettings['time_format'] = '24'; // set the time format to 24 hour
                        settings.put('time_format', '24');  // save the time format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // 12 hour radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      '12 Hour', // 12 hour
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: '12', // value of the radio button
                    groupValue: timeFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        timeFormat = value as String; // set the value of the radio button
                        currentSettings['time_format'] = '12'; // set the time format to 12 hour
                        settings.put('time_format', '12'); // save the time format to the settings
                      });
                    },
                  ),
                ),
                // space between the radio buttons
                Container(
                  height: 8.0 * heightFactor,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: Container(
                    height: 2.0 * heightFactor,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 8.0 * heightFactor,
                ),
                // Date Format settings
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Date Format', // date format title
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Fredoka'
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // day month year radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Day / Month / Year', // day month year
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'dmy', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'dmy'; // set the date format to day month year
                        settings.put('date_format', 'dmy'); // save the date format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // day year month radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Day / Year / Month', // day year month
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'dym', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String; // set the value of the radio button
                        currentSettings['date_format'] = 'dym'; // set the date format to day year month
                        settings.put('date_format', 'dym'); // save the date format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // month day year radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Month / Day / Year', // month day year
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'mdy', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String; // set the value of the radio button
                        currentSettings['date_format'] = 'mdy'; // set the date format to month day year
                        settings.put('date_format', 'mdy'); // save the date format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // month year day radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Month / Year / Day', // month year day
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'myd', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String; // set the value of the radio button
                        currentSettings['date_format'] = 'myd'; // set the date format to month year day
                        settings.put('date_format', 'myd'); // save the date format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // year day month radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Year / Month / Day', // year month day
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'ymd', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String; // set the value of the radio button
                        currentSettings['date_format'] = 'ymd'; // set the date format to year month day
                        settings.put('date_format', 'ymd'); // save the date format to the settings
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  // year month day radio button
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Year / Day / Month', // year day month
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka'
                      ),
                    ),
                    value: 'ydm', // value of the radio button
                    groupValue: dateFormat, // group value of the radio buttons
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String; // set the value of the radio button
                        currentSettings['date_format'] = 'ydm';  // set the date format to year day month
                        settings.put('date_format', 'ydm'); // save the date format to the settings
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // background color of the screen
      ),
    );
  }
}