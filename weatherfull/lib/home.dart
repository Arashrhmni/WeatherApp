import 'package:flutter/material.dart';

import 'themedata.dart';

int themeNumber = 0;
List<Color> data = light;
Icon icon = lightIcon;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: data[0],
            shadowColor: Colors.black,
            elevation: 1.0,
            leading: const Image(
              image: AssetImage('assets/images/logo.png')
            ),
            title: SearchAnchor(
              viewConstraints: const BoxConstraints(
                maxHeight: 300.0,
                maxWidth: double.infinity,
                minHeight: 50.0,
                minWidth: double.infinity,
              ),
              isFullScreen: false,
              builder: (BuildContext context, SearchController controller) => SearchBar(
                overlayColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => data[2]),
                hintText: 'Search for a city',
                hintStyle: MaterialStatePropertyAll<TextStyle>(TextStyle(color: data[1], fontSize: 14.0)),
                backgroundColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => data[2]),
                shadowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) => data[1]),
                controller: controller,
                padding: const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () => {
                  controller.openView(),
                },
                onChanged: (_) => {
                  controller.openView(),
                },
              ),
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(5, (int index) {
                  String cityName = 'city $index';
                  final String item = cityName;
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              },
            ),
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
        body: const Center(
          child: Text('Hello, World!'),
        ),
        backgroundColor: data[0],
      ),
    );
  }
}