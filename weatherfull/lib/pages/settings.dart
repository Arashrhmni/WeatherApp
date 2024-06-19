import '../allsettings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


var settings = Hive.box('settings');
bool dark = settings.get('theme', defaultValue: 'light') == 'dark';
String windspeed = settings.get('wind_speed', defaultValue: 'meter-per-second');
String temperature = settings.get('temperature', defaultValue: 'celcius');

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
        Navigator.popAndPushNamed(context, previousRoute);
        return true;
      },
      child: Scaffold(
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
          title: Text(
            'Settings',
            style: TextStyle(
              color: themeData[currentSettings['theme']]!['text'],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Select Theme',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 2.0,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Select Temperature Unit',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                        currentSettings['temperature'] = temperatures[temperature]!;
                        settings.put('temperature', 'celcius');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                        currentSettings['temperature'] = temperatures[temperature]!;
                        settings.put('temperature', 'fahrenheit');
                      });
                    },
                  ),
                ),
                Container(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 2.0,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Select Wind-Speed Unit',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: themeData[currentSettings['theme']]!['text'],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                        currentSettings['wind_speed'] = windspeeds[windspeed]!;
                        settings.put('wind_speed', 'meter-per-second');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                        currentSettings['wind_speed'] = windspeeds[windspeed]!;
                        settings.put('wind_speed', 'kilometer-per-hour');
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RadioListTile(
                    activeColor: themeData[currentSettings['theme']]!['text'],
                    fillColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
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
                        currentSettings['wind_speed'] = windspeeds[windspeed]!;
                        settings.put('wind_speed', 'miles-per-hour');
                      });
                    },
                  ),
                ),
                Container(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 2.0,
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.5),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, previousRoute);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['accent']),
                          foregroundColor: MaterialStateProperty.all(themeData[currentSettings['theme']]!['text']),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      ),
    );
  }
}