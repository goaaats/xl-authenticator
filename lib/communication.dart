import 'package:shared_preferences/shared_preferences.dart';

class Communication {
  static const String IP_KEY = "IP";

  static Future<String?> getSavedIp() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(IP_KEY))
      return null;

    return prefs.getString(IP_KEY);
  }

  static Future<void> setSavedIp(String ip) async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString(IP_KEY, ip);
  }

  static Future<void> sendOtp(String otp) async {
    var ip = await Communication.getSavedIp();

    if (ip == null)
      return;

      
  }
}