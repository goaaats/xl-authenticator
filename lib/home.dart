import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp/otp.dart';
import 'dart:async';

import 'package:xl_otpsend/account.dart';
import 'package:xl_otpsend/communication.dart';
import 'package:xl_otpsend/generalsetting.dart';
import 'package:xl_otpsend/set.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.title}) : super(key: key);

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

  Future<void> setup() async {
    var savedAccount = await SavedAccount.getSaved();

    if (savedAccount != null) {
      savedSecret = savedAccount.secret as String;
      showNewOtp();

      var sent = await Communication.sendOtp(_currentOtp);
      var isClose = await GeneralSetting.getIsAutoClose();

      if (sent && isClose) {
        Fluttertoast.showToast(
            msg: "OTP sent!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        SystemNavigator.pop();

        // This is illegal but we're not on the App Store anyway
        if (Platform.isIOS) {
          exit(0);
        }
      }
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
      _currentOtp = getCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title as String),
        brightness: Brightness.dark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 100, right: 100),
                child: Image(image: AssetImage('assets/logo.png'))),
            Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                'Your OTP:',
              ),
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
                  var res = await Communication.sendOtp(getCode());

                  if (res) {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text("Sent!")));
                  } else {
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                          content: Text("IP not set or connection failed")));
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
      ),
    );
  }
}
