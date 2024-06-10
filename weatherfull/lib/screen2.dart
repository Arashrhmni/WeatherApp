import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weatherfull/home.dart';
import 'themedata.dart';

int themeNumber = 0;
List<Color> data = light;
Icon icon = lightIcon;

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.home),
          ),
          appBar: AppBar(
            backgroundColor: data[0],
            leading: const Image(image: AssetImage('assets/images/logo.png')),
            actions: [
              IconButton(
                icon: icon,
                onPressed: () {
                  setState(() {
                    if (themeNumber == 0) {
                      data = dark;
                      icon = darkIcon;
                      themeNumber = 1;
                    } else {
                      data = light;
                      icon = lightIcon;
                      themeNumber = 0;
                    }
                  });
                },
              ),
            ],
          ),
          body: ListView(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                width: 300,
                height: 100,
                child: Center(
                  child: Text('List 1'),
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                width: 300,
                height: 100,
                child: Center(
                  child: Text('List 2'),
                ),
              ),
            ],
          ),
          backgroundColor: data[0],
        ),
      ),
    );
  }
}
