import '../allsettings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


var settings = Hive.box('settings');
bool dark = settings.get('theme', defaultValue: 'light') == 'dark';
String windspeed = settings.get('wind_speed', defaultValue: 'meter-per-second');
String temperature = settings.get('temperature', defaultValue: 'celcius');
String timeFormat = settings.get('time_format', defaultValue: '24');
String dateFormat = settings.get('date_format', defaultValue: 'dmy');
String pressure = settings.get('pressure', defaultValue: 'hPa');
String visibility = settings.get('visibility', defaultValue: 'meters');

class SettingsWindow extends StatefulWidget {
  const SettingsWindow({super.key});

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {


  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        setState(() {});
        Navigator.pop(context, 'themeChanged');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          shadowColor: themeData[currentSettings['theme']]!['shadow'],
          elevation: 4.0,
          leading: Container(
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor,
            ),
            child: IconButton(
              padding: EdgeInsets.only(
                left: 15.0 * widthFactor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
              icon: Icon(
                Icons.home, 
                color: themeData[currentSettings['theme']]!['text'],
                size: 30 * heightFactor
              )
            ),
          ),
          title: Center(
            child: Text(
              'Settings',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(
                top: 8.0 * heightFactor,
                bottom: 8.0 * heightFactor,
                right: 8.0 * widthFactor,
                left: 8.0 * widthFactor,
              ),
              child: IconButton(
                padding: EdgeInsets.only(
                  right: 15.0 * widthFactor,
                ),
                onPressed: () {
                  Navigator.pop(context, 'themeChanged');
                },
                icon: Icon(
                  Icons.arrow_back_sharp, 
                  color: themeData[currentSettings['theme']]!['text'], 
                  size: 30 * heightFactor
                )
              ),
            ),
          ]
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context, 'themeChanged');
            },
            backgroundColor: themeData[currentSettings['theme']]!['accent']!,
            child: Icon(
              Icons.save, 
              color: themeData[currentSettings['theme']]!['text']!
            ),
        ),
        body: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Light',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: false,
                    groupValue: dark,
                    onChanged: (value) {
                      setState(() {
                        dark = value as bool;
                        currentSettings['theme'] = 'light';
                        settings.put('theme', 'light');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Dark',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: true,
                    groupValue: dark,
                    onChanged: (value) {
                      setState(() {
                        dark = value as bool;
                        currentSettings['theme'] = 'dark';
                        settings.put('theme', 'dark');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Temperature Unit',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Celcius (°C)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'celcius',
                    groupValue: temperature,
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String;
                        currentSettings['temperature'] = 'celcius';
                        settings.put('temperature', 'celcius');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Fahrenheit (°F)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'fahrenheit',
                    groupValue: temperature,
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String;
                        currentSettings['temperature'] = 'fahrenheit';
                        settings.put('temperature', 'fahrenheit');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kelvin (K)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'kelvin',
                    groupValue: temperature,
                    onChanged: (value) {
                      setState(() {
                        temperature = value as String;
                        currentSettings['temperature'] = 'kelvin';
                        settings.put('temperature', 'kelvin');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Wind-Speed Unit',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Meter per Second (m/s)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'meter-per-second',
                    groupValue: windspeed,
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String;
                        currentSettings['wind_speed'] = 'meter-per-second';
                        settings.put('wind_speed', 'meter-per-second');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kilometer per Hour (km/h)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'kilometer-per-hour',
                    groupValue: windspeed,
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String;
                        currentSettings['wind_speed'] = 'kilometer-per-hour';
                        settings.put('wind_speed', 'kilometer-per-hour');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Miles per Hour (mph)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'miles-per-hour',
                    groupValue: windspeed,
                    onChanged: (value) {
                      setState(() {
                        windspeed = value as String;
                        currentSettings['wind_speed'] = 'miles-per-hour';
                        settings.put('wind_speed', 'miles-per-hour');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Pressure Unit',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Pascal (Pa)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'pa',
                    groupValue: pressure,
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String;
                        currentSettings['pressure'] = 'pa';
                        settings.put('pressure', 'pa');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Hectopascal (hPa) (1 hPa = 100 Pa)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'hPa',
                    groupValue: pressure,
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String;
                        currentSettings['pressure'] = 'hPa';
                        settings.put('pressure', 'hPa');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Standard Atmosphere (atm)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'atm',
                    groupValue: pressure,
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String;
                        currentSettings['pressure'] = 'atm';
                        settings.put('pressure', 'atm');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Millimeters of Mercury (mmHg)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'mmHg',
                    groupValue: pressure,
                    onChanged: (value) {
                      setState(() {
                        pressure = value as String;
                        currentSettings['pressure'] = 'mmHg';
                        settings.put('pressure', 'mmHg');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Visibility Unit',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Meters (m)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'meters',
                    groupValue: visibility,
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String;
                        currentSettings['visibility'] = 'meters';
                        settings.put('visibility', 'meters');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Kilometers (km)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'kilometers',
                    groupValue: visibility,
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String;
                        currentSettings['visibility'] = 'kilometers';
                        settings.put('visibility', 'kilometers');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Miles (miles)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'miles',
                    groupValue: visibility,
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String;
                        currentSettings['visibility'] = 'miles';
                        settings.put('visibility', 'miles');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Feet (ft)',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'feet',
                    groupValue: visibility,
                    onChanged: (value) {
                      setState(() {
                        visibility = value as String;
                        currentSettings['visibility'] = 'feet';
                        settings.put('visibility', 'feet');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Time Format',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      '24 Hour',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: '24',
                    groupValue: timeFormat,
                    onChanged: (value) {
                      setState(() {
                        timeFormat = value as String;
                        currentSettings['time_format'] = '24';
                        settings.put('time_format', '24');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      '12 Hour',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: '12',
                    groupValue: timeFormat,
                    onChanged: (value) {
                      setState(() {
                        timeFormat = value as String;
                        currentSettings['time_format'] = '12';
                        settings.put('time_format', '12');
                      });
                    },
                  ),
                ),
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 15.0 * heightFactor,
                    right: 18.0 * widthFactor,
                    left: 18.0 * widthFactor, 
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Date Format',
                      style: TextStyle(
                        fontSize: 20.0 * heightFactor,
                        color: themeData[currentSettings['theme']]!['text'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Day / Month / Year',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'dmy',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'dmy';
                        settings.put('date_format', 'dmy');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Day / Year / Month',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'dym',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'dym';
                        settings.put('date_format', 'dym');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Month / Day / Year',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'mdy',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'mdy';
                        settings.put('date_format', 'mdy');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Month / Year / Day',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'myd',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'myd';
                        settings.put('date_format', 'myd');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Year / Month / Day',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'ymd',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'ymd';
                        settings.put('date_format', 'ymd');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: 8.0 * widthFactor,
                    left: 8.0 * widthFactor,
                  ),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: WidgetStateProperty.all(themeData[currentSettings['theme']]!['text']),
                    title: Text(
                      'Year / Day / Month',
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                    value: 'ydm',
                    groupValue: dateFormat,
                    onChanged: (value) {
                      setState(() {
                        dateFormat = value as String;
                        currentSettings['date_format'] = 'ydm';
                        settings.put('date_format', 'ydm');
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      ),
    );
  }
}