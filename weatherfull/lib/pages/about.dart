import 'package:flutter/material.dart';
import '../allsettings.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

List<Map<String, String>> teamData = [
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
    'email': 'arash.rahmani@ue-germani.de'
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

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        Navigator.pushNamed(context, '/homepage');
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'About Us',
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'],
                fontSize: 30.0 * heightFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Fredoka',
              ),
            ),
          ),
          leading: IconButton(
            padding: EdgeInsets.only(left: 10.0 * widthFactor),
            icon: Icon(
              Icons.home,
              color: themeData[currentSettings['theme']]!['text'],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/homepage');
            },
          ),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.only(right: 10.0 * widthFactor),
              icon: Icon(
                Icons.settings,
                color: themeData[currentSettings['theme']]!['text'],
              ),
              onPressed: () async {
                var result = await Navigator.pushNamed(context, '/settings');
                if (result == 'themeChanged') {
                  setState(() {});
                }
              },
            ),
          ],
          backgroundColor: themeData[currentSettings['theme']]!['appBar'],
          elevation: 4.0,
          shadowColor: themeData[currentSettings['theme']]!['shadow'],
        ),
        body: Container(
          color: themeData[currentSettings['theme']]!['main_body_background'],
          child: ListView.builder(
            itemCount: teamData.length,
            itemBuilder: (context, index) {
              return Card(
                color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                margin: EdgeInsets.fromLTRB(
                  10.0 * widthFactor, 
                  (index == 0 || index == teamData.length - 1) ? (index == teamData.length - 1 ? 5.0 : 10.0) * heightFactor : 5.0 * heightFactor, 
                  10.0 * widthFactor, 
                  (index == 0 || index == teamData.length - 1) ? ( index == 0 ? 5.0 : 10.0) * heightFactor : 5.0 * heightFactor
                ),
                elevation: 3.0,
                shadowColor: themeData[currentSettings['theme']]!['shadow'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: themeData[currentSettings['theme']]!['accent']!,
                      width: 2.0,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 10.0 * widthFactor,
                    right: 10.0 * widthFactor,
                  ),
                  child: Row(
                    children: [
                      if (index % 2 == 0)
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: AssetImage(teamData[index]['image']!),
                        ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 15.0 * widthFactor,
                            right: 15.0 * widthFactor,
                            top: 10.0 * heightFactor,
                            bottom: 10.0 * heightFactor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Container(
                                margin: EdgeInsets.only(top: 5.0 * heightFactor, bottom: 5.0 * heightFactor),
                                height: 1.0,
                                color: themeData[currentSettings['theme']]!['text'],
                              ),
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
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'],
      ),
    );
  }
}