import 'package:flutter/material.dart';

import 'package:xl_otpsend/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XL Authenticator',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
       brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(primary: Colors.blue, secondary: Colors.blueAccent),
      ),
      home: HomePage(title: 'XIVLauncher Authenticator'),
    );
  }
}