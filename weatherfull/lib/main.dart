import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/homepage': (context) => const HomeScreen(),
      },
      home: const HomeScreen()
    );
  }
}

