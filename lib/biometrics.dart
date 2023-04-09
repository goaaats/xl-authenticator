import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';

import 'generalsetting.dart';
import 'home.dart';

enum BiometricsAuthStatus {
  DONE,
  IN_PROGRESS,
  NOT_AUTHENTICATED
}

class Biometrics {

  static Biometrics instance = new Biometrics();

  BiometricsAuthStatus authStatus = BiometricsAuthStatus.NOT_AUTHENTICATED;

  var authentication = new LocalAuthentication();

  Future<void> lifecycleAuth(AppLifecycleState state) async {
    var homePageState = HomePageState.instance;
    if (homePageState == null) return;
    switch (state) {
      case AppLifecycleState.inactive:
        homePageState.updateOtp();
        break;
      case AppLifecycleState.paused:
        authStatus = BiometricsAuthStatus.NOT_AUTHENTICATED;
        homePageState.updateOtp();
        break;
      default:
        if (authStatus != BiometricsAuthStatus.DONE) {
          await forceAuthentication();
          homePageState.updateOtp();
        }
    }
  }

  Future<void> forceAuthentication() async {
    if (!(await authentication.canCheckBiometrics) || authStatus == BiometricsAuthStatus.DONE) {
      return;
    }
    if (await GeneralSetting.getRequireBiometrics()) {
      var authenticated = false;
      while (!authenticated) {
        authenticated = await authenticate();
      }
    }
    authStatus = BiometricsAuthStatus.DONE;
  }

  Future<bool> authenticate() {
    return authentication.authenticate(
          localizedReason:
          "XL Authenticator is configured to require your biometrics.",
          options: new AuthenticationOptions(stickyAuth: true, biometricOnly: true));
  }

}
