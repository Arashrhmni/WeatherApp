import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../allsettings.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../confidential_constants.dart';

TextEditingController nameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController messageController = TextEditingController();
String name = '';
String email = '';
String message = '';
String subject = '';
GlobalKey<FormState> _formKey = GlobalKey<FormState>();

// Function to send email
Future<bool> sendEmail(String name, String email, String text, String subject) async {
  // Create a SMTP client (Simple Mail Transfer Protocol) for gmail
  final smtpServer = gmail(username, password);

  String html = '<b>From:</b> $name<br><b>Subject:</b> $subject<br><b>Email:</b> $email<br><hr><p>$text</p>';

  // Create our message
  final message = Message()
    ..from = Address(email, name)
    ..recipients.add(Address(username, 'WeatherFull'))
    ..subject = subject
    ..headers = {
      'X-Priority': '1',
      'Importance': 'high',
    }
    ..html = html;

  // Send the message
  try {
    await send(message, smtpServer);
    return true;
  } catch (e) {
    return false;
  }
}

// Contact Screen stateful widget
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {


  @override
  Widget build(BuildContext context) {
    // WillPopScope to handle back button press
    // ignore: deprecated_member_use
    return WillPopScope(
      // when back button is pressed, pop the current screen and push the homepage screen
      onWillPop: () async {
        Navigator.popAndPushNamed(context, '/homepage');
        return true;
      },
      // Scaffold widget to create the UI of the screen
      child: Scaffold(
        appBar: AppBar( // AppBar widget to create the app bar
          backgroundColor: themeData[currentSettings['theme']]!['appBar'], // set the background color of the app bar
          elevation: 4.0, // elevation of the app bar, to give shadow
          shadowColor: themeData[currentSettings['theme']]!['shadow'], // color of the shadow of the app bar
          leading: IconButton(
            // IconButton widget to create the leading icon button of the app bar
            // padding to give some space from the left edge of the screen
            padding: EdgeInsets.only(left: 10.0 * widthFactor),
            icon: Icon(
              Icons.home, // Icon of the button, home icon
              color: themeData[currentSettings['theme']]!['text'], // color of the icon
              size: 30.0 * heightFactor, // size of the icon
            ),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/homepage'); // when the button is pressed, pop the current screen and push the homepage screen
            },
          ),
          // title of the app bar
          title: Center(
            child: Text(
              'Contact Us', // text of the title
              style: TextStyle(
                color: themeData[currentSettings['theme']]!['text'], // color of the text
                fontFamily: 'Fredoka', // font family of the text
                fontSize: 30.0 * heightFactor, // size of the text
                fontWeight: FontWeight.w600, // weight of the text, w600 is semi-bold
              ),
            ),
          ),
          // actions of the app bar
          actions: [
            // IconButton widget to create the action icon button of the app bar
            IconButton(
              // padding to give some space from the right edge of the screen
              padding: EdgeInsets.only(right: 10.0 * widthFactor),
              icon: Icon(
                Icons.settings, // Icon of the button, settings icon
                color: themeData[currentSettings['theme']]!['text'], // color of the icon
                size: 30.0 * heightFactor, // size of the icon
              ),
              onPressed: () async {
                // when the button is pressed, navigate to the settings screen
                var result = await Navigator.pushNamed(context, '/settings');
                // if the result is 'themeChanged', then update the state of the screen
                if (result == 'themeChanged') {
                  setState(() {});
                }
              },
            ),
          ],
        ),
        // body of the scaffold
        body: Container(
          // container widget to create the body of the screen
          // container decoration to give some styling to the container
          decoration: BoxDecoration(
            color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4), // color of the container
            borderRadius: BorderRadius.circular(10.0), // border radius of the container
            border: Border.all( // border of the container
              color: themeData[currentSettings['theme']]!['accent']!,
              width: 2.0,
            ),
          ),
          // container margin to give some space from the edges of the screen
          margin: EdgeInsets.only(
            left: 10.0 * widthFactor,
            right: 10.0 * widthFactor,
            top: 10.0 * heightFactor,
            bottom: 10.0 * heightFactor,
          ),
          // container padding to give some space inside the container
          padding: EdgeInsets.only(
            left: 10.0 * widthFactor,
            right: 10.0 * widthFactor,
            top: 10.0 * heightFactor,
            bottom: 10.0 * heightFactor,
          ),
          // container width and height to make the container scrollable
          width: deviceWidth - (20.0 * widthFactor),
          height: deviceHeight - (20.0 * heightFactor),
          // singleChildScrollView widget to make the container scrollable
          child: SingleChildScrollView(
            // Form widget to create the form in the screen
            child: Form(
              key: _formKey, // key of the form, to validate the form
              child: Column(
                // column widget to create the children widgets in a column
                children: [
                  // Text widget to create the title of the form
                  Text(
                    'Contact Form',
                    style: TextStyle(
                      color: themeData[currentSettings['theme']]!['text'],
                      fontFamily: 'Fredoka',
                      fontSize: 20.0 * heightFactor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // divider container to create a divider line
                  Container(
                    margin: EdgeInsets.only(
                      top: 10.0 * heightFactor,
                      bottom: 10.0 * heightFactor,
                    ),
                    color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                    height: 2.0 * heightFactor,
                  ),
                  // Column widget to create the form fields in a column
                  Column(
                    // children of the column widget
                    children: [
                      // Container widget to create the name field
                      Container(
                        // container decoration to give some styling to the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0,
                          ),
                        ),
                        // container padding to give some space inside the container
                        padding: EdgeInsets.only(
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                        ),
                        // container child to create the child widgets of the container
                        child: Row(
                          children: [
                            // Icon widget to create the person icon
                            Icon(
                              Icons.person,
                              color: themeData[currentSettings['theme']]!['text'],
                              size: 30.0 * heightFactor,
                            ),
                            // SizedBox widget to give some space between the icon and the text field
                            SizedBox(
                              width: 10.0 * widthFactor,
                            ),
                            // Expanded widget to make the text field take the remaining space
                            Expanded(
                              child: TextFormField(
                                // text editing controller of the text field
                                controller: nameController, 
                                // validator function to validate the text field
                                validator: (value) {
                                  // if the value is empty, return an error message
                                  // or if the value is null, return an error message
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  // return null if the value is not empty
                                  return null;
                                },
                                // onFieldSubmitted function to set the name variable
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    name = value;
                                  });
                                },
                                // keyboardType of the text field
                                keyboardType: TextInputType.text,
                                // enableSuggestions of the text field
                                enableSuggestions: false,
                                // autocorrect of the text field
                                autocorrect: false,
                                // textCapitalization of the text field
                                textCapitalization: TextCapitalization.words,
                                // decoration of the text field
                                decoration: InputDecoration(
                                  // errorStyle of the text field
                                  errorStyle: TextStyle(
                                    color: const Color.fromARGB(255, 200, 0, 0),
                                    fontFamily: 'Fredoka',
                                    fontSize: 12.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // hintText of the text field
                                  hintText: 'Name',
                                  // hintStyle of the text field
                                  hintStyle: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                    fontFamily: 'Fredoka',
                                    fontSize: 20.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none, // border of the text field
                                ),
                                // style of the text field
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontFamily: 'Fredoka',
                                  fontSize: 20.0 * heightFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container widget to create a divider line
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor,
                          bottom: 5.0 * heightFactor,
                        ),
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        height: 2.0 * heightFactor,
                      ),
                      // Container widget to create the email field
                      Container(
                        // container decoration to give some styling to the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0,
                          ),
                        ),
                        // container padding to give some space inside the container
                        padding: EdgeInsets.only(
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                        ),
                        // row widget to create the child widgets of the container
                        child: Row(
                          children: [
                            // Icon widget to create the email icon
                            Icon(
                              Icons.email_rounded,
                              color: themeData[currentSettings['theme']]!['text'],
                              size: 30.0 * heightFactor,
                            ),
                            // SizedBox widget to give some space between the icon and the text field
                            SizedBox(
                              width: 10.0 * widthFactor,
                            ),
                            // Expanded widget to make the text field take the remaining space
                            Expanded(
                              child: TextFormField(
                                // text editing controller of the text field
                                controller: emailController,
                                // validator function to validate the text field
                                validator: (value) {
                                  // if the value is empty, return an error message
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email address';
                                  } else {
                                    // Check if the email address is valid, using regular expression (regex)
                                    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                                    // RegExp class to create a regular expression
                                    RegExp regExp = RegExp(pattern);
                                    // if the email address does not match the regular expression, return an error message
                                    if (!regExp.hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                  }
                                  // return null if the value is not empty and is valid
                                  return null;
                                },
                                // onFieldSubmitted function to set the email variable
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                                // keyboardType of the text field
                                keyboardType: TextInputType.emailAddress,
                                // enableSuggestions of the text field
                                enableSuggestions: false,
                                // autocorrect of the text field
                                autocorrect: false,
                                // decoration of the text field
                                decoration: InputDecoration(
                                  hintText: 'Email Address', // hintText of the text field
                                  // errorStyle of the text field
                                  errorStyle: TextStyle(
                                    color: const Color.fromARGB(255, 200, 0, 0),
                                    fontFamily: 'Fredoka',
                                    fontSize: 12.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // hintStyle of the text field
                                  hintStyle: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                    fontFamily: 'Fredoka',
                                    fontSize: 18.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // border of the text field
                                  border: InputBorder.none,
                                ),
                                // style of the text field
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontFamily: 'Fredoka',
                                  fontSize: 18.0 * heightFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container widget to create a divider line
                      Container(
                        margin: EdgeInsets.only(
                          top: 5.0 * heightFactor,
                          bottom: 5.0 * heightFactor,
                        ),
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        height: 2.0 * heightFactor,
                      ),
                      // Container widget to create the message field
                      Container(
                        // container decoration to give some styling to the container
                        decoration: BoxDecoration(
                          color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: themeData[currentSettings['theme']]!['accent']!,
                            width: 2.0,
                          ),
                        ),
                        // container padding to give some space inside the container
                        padding: EdgeInsets.only(
                          left: 10.0 * widthFactor,
                          right: 10.0 * widthFactor,
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                        ),
                        // row widget to create the child widgets of the container
                        child: Row(
                          // mainAxisAlignment of the row widget to align the widgets to the start
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment of the row widget to align the widgets to the start
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon widget to create the message icon
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10.0 * heightFactor
                              ),
                              child: Icon(
                                Icons.message,
                                color: themeData[currentSettings['theme']]!['text'],
                                size: 30.0 * heightFactor,
                              ),
                            ),
                            // SizedBox widget to give some space between the icon and the text field
                            SizedBox(
                              width: 10.0 * widthFactor,
                            ),
                            // Expanded widget to make the text field take the remaining space
                            Expanded(
                              child: TextFormField(
                                // text editing controller of the text field
                                controller: messageController,
                                // validator function to validate the text field
                                validator: (value) {
                                  // if the value is empty, return an error message
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your message';
                                  }
                                  // return null if the value is not empty
                                  return null;
                                },
                                // onFieldSubmitted function to set the message variable
                                onFieldSubmitted: (value) {
                                  setState(() {
                                    message = value;
                                  });
                                },
                                // maximum number of characters allowed in the text field
                                maxLength: 1000,
                                // maxLengthEnforcement of the text field
                                maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
                                // keyboardType of the text field
                                keyboardType: TextInputType.multiline,
                                // maximum number of lines to show on the screen in the text field
                                maxLines: 19,
                                // enableSuggestions of the text field
                                enableSuggestions: true,
                                // autocorrect of the text field
                                autocorrect: true,
                                // decoration of the text field
                                decoration: InputDecoration(
                                  hintText: 'Message', // hintText of the text field
                                  // errorStyle of the text field
                                  errorStyle: TextStyle(
                                    color: const Color.fromARGB(255, 200, 0, 0),
                                    fontFamily: 'Fredoka',
                                    fontSize: 12.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // hintStyle of the text field
                                  hintStyle: TextStyle(
                                    color: themeData[currentSettings['theme']]!['text']!.withOpacity(0.5),
                                    fontFamily: 'Fredoka',
                                    fontSize: 18.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  // border of the text field
                                  border: InputBorder.none,
                                ),
                                // style of the text field
                                style: TextStyle(
                                  color: themeData[currentSettings['theme']]!['text'],
                                  fontFamily: 'Fredoka',
                                  fontSize: 18.0 * heightFactor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Container widget to create a divider line
                      Container(
                        margin: EdgeInsets.only(
                          top: 10.0 * heightFactor,
                          bottom: 10.0 * heightFactor,
                        ),
                        color: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                        height: 2.0 * heightFactor,
                      ),
                    ],
                  ),
                  // ElevatedButton widget to create the submit button
                  ElevatedButton(
                    // onPressed function of the button
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // Create a subject for the email
                        DateTime current = DateTime.now();
                        setState(() {
                          subject = '${current.millisecondsSinceEpoch - current.timeZoneOffset.inMilliseconds}_${nameController.text.split(' ').join('_')}';
                        });
                        // If the form is valid, we want to show a Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          // SnackBar widget to create the snackbar
                          SnackBar(
                            // content of the snackbar
                            content: Text(
                              'Sending message...',
                              // text style of the content
                              style: TextStyle(
                                color: themeData[currentSettings['theme']]!['text'],
                                fontFamily: 'Fredoka',
                                fontSize: 20.0 * heightFactor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // background color of the snackbar
                            backgroundColor: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                            // duration of the snackbar
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        // Send the email
                        sendEmail(nameController.text, emailController.text, messageController.text, subject).then((value) {
                          // Show a snackbar based on the result of the email sending
                          if (value == true){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Message sent successfully', // message sent successfully
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 40, 184, 40),
                                    fontFamily: 'Fredoka',
                                    fontSize: 20.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // background color of the snackbar
                                backgroundColor: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                                // duration of the snackbar
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            sleep(const Duration(seconds: 1));
                            nameController.clear(); // clear the name field
                            emailController.clear(); // clear the email field
                            messageController.clear(); // clear the message field
                          } else {
                            // Show a snackbar if the email sending failed
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  // message if the email sending failed
                                  'Failed to send message',
                                  // text style of the content
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 184, 40, 40),
                                    fontFamily: 'Fredoka',
                                    fontSize: 20.0 * heightFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // background color of the snackbar
                                backgroundColor: themeData[currentSettings['theme']]!['accent']!.withOpacity(0.4),
                                // duration of the snackbar
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        });
                      }
                    },
                    // style of the button
                    style: ButtonStyle(
                      // backgroundColor of the button
                      backgroundColor: WidgetStateProperty.all<Color>(
                        themeData[currentSettings['theme']]!['accent']!,
                      ),
                      // shape of the button
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // border radius of the button
                        ),
                      ),
                    ),
                    // child of the button
                    child: Text(
                      'Submit', // text of the button
                      // style of the text
                      style: TextStyle(
                        color: themeData[currentSettings['theme']]!['text'],
                        fontFamily: 'Fredoka',
                        fontSize: 20.0 * heightFactor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: themeData[currentSettings['theme']]!['main_body_background'], // background color of the screen
      ),
    );
  }
}