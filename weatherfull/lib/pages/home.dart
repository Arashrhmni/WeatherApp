import 'package:flutter/material.dart';
import '../allsettings.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    previousRoute = '/homepage';
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          backgroundColor: themeData[currentSettings['theme']]!['accent'],
          foregroundColor: themeData[currentSettings['theme']]!['text'],
          child: const Icon(Icons.search),
        ),
        appBar: AppBar(
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          shadowColor: themeData[currentSettings['theme']]!['shadow'],
          elevation: 4.0,
          leading: SizedBox(
            width: 75.0,
            height: 75.0,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
              
              child: const Image(
                image: AssetImage('assets/images/logo.png')
              ),
            ),
          ),
          title: SingleChildScrollView(
            child: Center(
              child: Text(
                'WeatherFull  ',
                style: TextStyle(
                  color: themeData[currentSettings['theme']]!['text'],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_sharp,
              ),
              color: themeData[currentSettings['theme']]!['flat_icons'],
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: const Column(
          children: [
            
          ],
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      ),
    );
  }
}