import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

import 'generalsetting.dart';
import 'home.dart';

enum AuthenticationStatus {
  DONE,
  IN_PROGRESS,
  NOT_AUTHENTICATED
}

class Authentication {

  static Authentication instance = new Authentication();

  AuthenticationStatus authStatus = AuthenticationStatus.NOT_AUTHENTICATED;

  var authentication = new LocalAuthentication();

  Future<void> lifecycleAuth(AppLifecycleState state) async {
    var homePageState = HomePageState.instance;
    if (homePageState == null) return;
    switch (state) {
      case AppLifecycleState.inactive:
        homePageState.updateOtp();
        break;
      case AppLifecycleState.paused:
        authStatus = AuthenticationStatus.NOT_AUTHENTICATED;
        homePageState.updateOtp();
        break;
      default:
        if (authStatus != AuthenticationStatus.DONE) {
          await forceAuthentication();
          homePageState.updateOtp();
        }
    }
  }

  Future<void> forceAuthentication() async {
    if (!(await authentication.canCheckBiometrics) || authStatus == AuthenticationStatus.DONE) {
      return;
    }
    if (await GeneralSetting.getRequireBiometrics()) {
      var authenticated = false;
      while (!authenticated) {
        authenticated = await authentication.authenticate(
            localizedReason:
            "XL Authenticator is configured to require your biometrics.",
            options: new AuthenticationOptions(stickyAuth: true, biometricOnly: true));
      }
    }
    authStatus = AuthenticationStatus.DONE;
  }

}
