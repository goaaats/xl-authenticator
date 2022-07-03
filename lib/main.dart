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
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
       brightness: Brightness.dark,
      ),
      home: HomePage(title: 'XIVLauncher Authenticator'),
    );
  }
}