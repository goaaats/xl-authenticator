import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xl_otpsend/account.dart';
import 'package:xl_otpsend/communication.dart';
import 'package:xl_otpsend/generalsetting.dart';
import 'package:xl_otpsend/qr.dart';
import 'package:xl_otpsend/scanresult.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isRestartChecked = false;

  @override
  void initState() {
    GeneralSetting.getIsAutoClose().then((value) {
      setState(() {
        isRestartChecked = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        brightness: Brightness.dark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _navigateAndScanQr(context);
              },
              child: Text('Set-Up OTP code'),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: FutureBuilder(
                future: Communication.getSavedIp(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("XIVLauncher IP: " + (snapshot.data as String));
                  } else {
                    return Text("XIVLauncher IP: <none set>");
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var result = await prompt(context,
                    title: Text("Enter XIVLauncher IP"),
                    textOK: Text("OK"),
                    textCancel: Text("Cancel"),
                    maxLines: 1,
                    minLines: 1,
                    autoFocus: true,
                    textCapitalization: TextCapitalization.none,
                    initialValue: await Communication.getSavedIp());

                if (result != null) {
                  debugPrint("Manual entry: $result");
                  setState(() {
                    Communication.setSavedIp(result);
                  });
                }
              },
              child: Text('Set XIVLauncher IP'),
            ),
            Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                    ),
                    Text("Close app after sending:"),
                    Checkbox(
                        value: isRestartChecked,
                        onChanged: (value) {
                          setState(() {
                            isRestartChecked = value as bool;
                            GeneralSetting.setIsAutoClose(value);
                          });
                        })
                  ],
                ))
          ],
        ),
      ),
    );
  }

  _navigateAndScanQr(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => QRViewExample()),
    );

    if (result == null) return;

    switch (result.type) {
      case ScanResultType.Uri:
        await SavedAccount.setSaved(SavedAccount.parse(result.data));
        break;
      case ScanResultType.Raw:
        await SavedAccount.setSaved(SavedAccount.unnamed(result.data));
        break;
    }

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("Saved!")));
  }
}
