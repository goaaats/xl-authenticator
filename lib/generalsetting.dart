import 'package:shared_preferences/shared_preferences.dart';

class GeneralSetting {
  static const String BIOMETRICS_KEY = "BIOMETRICS";
  static const String ISCLOSE_KEY = "ISCLOSE";

  static Future<bool> getRequireBiometrics() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(BIOMETRICS_KEY))
      return false;

    return prefs.getBool(BIOMETRICS_KEY) as bool;
  }

  static Future<void> setRequireBiometrics(bool state) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setBool(BIOMETRICS_KEY, state);
  }


  static Future<bool> getIsAutoClose() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(ISCLOSE_KEY))
      return false;

    return prefs.getBool(ISCLOSE_KEY) as bool;
  }

  static Future<void> setIsAutoClose(bool state) async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setBool(ISCLOSE_KEY, state);
  }
}