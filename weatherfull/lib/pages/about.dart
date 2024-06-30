import 'package:flutter/material.dart';
import '../allsettings.dart';
import 'package:url_launcher/url_launcher.dart';

// About screen stateful widget
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {

  // launch url function
  Future<void> launchURL(String url) async {
    Uri uri = Uri.parse(url);
    await launchUrl(uri); // launch the url in the browser 
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // will pop scope to handle back button press
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        // pop and push the homescreen
        Navigator.popAndPushNamed(context, '/homepage');
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'About Us', // Window title
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Fredoka',
              ),
            ),
          ),
          // leading icon for home
          leading: Container(
            margin: EdgeInsets.only(
              left: 15.0 * widthFactor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.home, // Home icon
                color: themeData[currentSettings['theme']]!['text'],
                size: 30.0 * heightFactor,
              ),
              onPressed: () {
                // on press pop and push the home screen
                Navigator.popAndPushNamed(context, '/homepage');
              },
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 5.0 * widthFactor
              ),
              child: IconButton(
                icon: Icon(
                  Icons.settings, // settings menu button
                  color: themeData[currentSettings['theme']]!['text'],
                  size: 30.0 * heightFactor,
                ),
                onPressed: () async {
                  // on press switch to the settings screen, which when popped would update this page
                  var result = await Navigator.pushNamed(context, '/settings');
                  if (result == 'themeChanged') {
                    setState(() {});
                  }
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: 15.0 * widthFactor
              ),
              child: IconButton(
                icon: Icon(
                  Icons.web, // website icon
                  color: themeData[currentSettings['theme']]!['text'],
                  size: 30.0 * heightFactor,
                ),
                onPressed: () {
                  // on press launch the website
                  launchURL('http://weatherfull.xyz/');
                },
              ),
            ),
          ],
          backgroundColor: themeData[currentSettings['theme']]!['appBar'], // appbar color
          elevation: 4.0, // elevation
          shadowColor: themeData[currentSettings['theme']]!['shadow'], // shadow color
        ),
        body: Container(
          color: themeData[currentSettings['theme']]!['main_body_background'], // main body color
          // child list view to display the team members
          child: ListView.builder(
            itemCount: teamData.length, // team data length
            itemBuilder: (context, index) {
              return Card(
                color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4), // card color
                margin: EdgeInsets.fromLTRB(
                  10.0 * widthFactor, // margin left
                  (index == 0 || index == teamData.length - 1) ? (index == teamData.length - 1 ? 5.0 : 10.0) * heightFactor : 5.0 * heightFactor,  // margin top
                  10.0 * widthFactor,  // margin right
                  (index == 0 || index == teamData.length - 1) ? ( index == 0 ? 5.0 : 10.0) * heightFactor : 5.0 * heightFactor // margin bottom
                ),
                elevation: 4.0, // elevation
                shadowColor: themeData[currentSettings['theme']]!['shadow'], // shadow color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // border radius
                ),
                child: Container(
                  // container decoration
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0,
                    ),
                  ),
                  // padding of the container
                  padding: EdgeInsets.only(
                    left: 10.0 * widthFactor,
                    right: 10.0 * widthFactor,
                  ),
                  child: Row(
                    children: [
                      // if index is even, display the image on the left
                      if (index % 2 == 0)
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: AssetImage(teamData[index]['image']!),
                        ),
                      Expanded(
                        child: Container(
                          // container margin
                          margin: EdgeInsets.only(
                            left: 15.0 * widthFactor,
                            right: 15.0 * widthFactor,
                            top: 10.0 * heightFactor,
                            bottom: 10.0 * heightFactor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // team member name
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  teamData[index]['name']!,
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 20.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                              // divider
                              Container(
                                margin: EdgeInsets.only(top: 5.0 * heightFactor, bottom: 5.0 * heightFactor),
                                height: 1.0,
                                color: themeData[currentSettings['theme']]!['text'],
                              ),
                              // team member details
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Role In The Project',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                        Text(
                                          'Student At',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                        Text(
                                          'Matriculation No.',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 40.0 * widthFactor),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          teamData[index]['role']!,
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                        Text(
                                          'UE Germany',
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                        Text(
                                          teamData[index]['matriculation']!,
                                          style: TextStyle(
                                            color: themeData[currentSettings['theme']]!['text'],
                                            fontSize: 15.0 * heightFactor,
                                            fontFamily: 'Fredoka',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5.0 * heightFactor, bottom: 5.0 * heightFactor),
                                height: 1.0,
                                color: themeData[currentSettings['theme']]!['text'],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  teamData[index]['email']!,
                                  style: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text'],
                                    fontSize: 15.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Fredoka',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // if index is odd, display the image on the right
                      if (index % 2 == 1)
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: AssetImage(teamData[index]['image']!),
                        ),
                    ]
                  ),
                ) 
              );
            },
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // main body color
      ),
    );
  }
}