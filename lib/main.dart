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
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.blueAccent, secondary: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(primary: Colors.blueAccent, secondary: Colors.blueAccent),
      ),
      home: HomePage(title: 'XIVLauncher Authenticator'),
    );
  }
}