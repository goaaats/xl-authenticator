import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'home.dart';

Future<void> lifecycleAuth(AppLifecycleState state) async {
  var homePageState = HomePageState.instance;
  if (homePageState == null) return;
  switch (state) {
    case AppLifecycleState.inactive:
      homePageState.updateOtp();
      break;
    case AppLifecycleState.paused:
      homePageState.authStatus = AuthenticationStatus.NOT_AUTHENTICATED;
      homePageState.updateOtp();
      break;
    default:
      if (homePageState.authStatus != AuthenticationStatus.DONE) {
        await homePageState.forceAuthentication();
        homePageState.updateOtp();
      }
  }
}