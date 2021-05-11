import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
import 'dart:async';

import 'package:xl_otpsend/account.dart';
import 'package:xl_otpsend/communication.dart';
import 'package:xl_otpsend/set.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController controller;
  late Stopwatch refreshStopwatch;

  String? savedSecret;

  int timeOffset = 0;

  @override
  void initState() {
    setup();

    var startTimestep = getTimestep();

    timeOffset = (30000 * startTimestep).floor();
    debugPrint("timeOffset:" + timeOffset.toString());

    refreshStopwatch = Stopwatch();
    refreshStopwatch.start();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {
          //debugPrint("refresh: " + controller.value.toString());
          if (refreshStopwatch.elapsedMilliseconds > 30000 - timeOffset) {
            timeOffset = 0;
            _currentOtp = getCode();
            refreshStopwatch.reset();

            debugPrint("refresh!! " + timeOffset.toString());
          }
        });
      });
    controller.forward(from: startTimestep);
    controller.repeat(reverse: false);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setup() async {
    var savedAccount = await SavedAccount.getSaved();

    if (savedAccount != null) {
      savedSecret = savedAccount.secret as String;
      showNewOtp();

      await Communication.sendOtp(_currentOtp);
    } else {
      debugPrint("No secret found, opening settings");

      await openSettings();
    }
  }

  Future<void> openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );

    var savedAccount = await SavedAccount.getSaved();

    if (savedAccount != null) {
      debugPrint("Updating secret...");
      savedSecret = savedAccount.secret;
    }
  }

  double getCurrentInterval() {
    var ms = DateTime.now().millisecondsSinceEpoch;

    return ms / 30000;
  }

  double getTimestep() {
    var interval = getCurrentInterval();

    return (interval - interval.truncate());
  }

  String getCode() {
    if (savedSecret == null) {
      return "???";
    }

    return OTP.generateTOTPCodeString(
        savedSecret as String, DateTime.now().millisecondsSinceEpoch,
        length: 6, interval: 30, algorithm: Algorithm.SHA1, isGoogle: true);
  }

  String _currentOtp = "";

  void showNewOtp() {
    setState(() {
      OTP.useTOTPPaddingForHOTP = true;

      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _currentOtp = getCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title as String),
        brightness: Brightness.dark,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Your OTP:',
            ),
            Text(
              '$_currentOtp',
              style: Theme.of(context).textTheme.headline4,
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: LinearProgressIndicator(
                  value: controller.value,
                  semanticsLabel: 'Linear progress indicator',
                )),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: ElevatedButton(
                onPressed: () async {
                  var res = await Communication.sendOtp(_currentOtp);

                  if (res) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text("Sent!")));
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text("IP not set or connection failed")));
                  }
                },
                child: Text('Resend to XL'),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          openSettings();
        },
        tooltip: 'Settings',
        child: Icon(Icons.settings),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
