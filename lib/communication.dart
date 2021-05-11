import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  static Future<bool> sendOtp(String otp) async {
    var ip = await Communication.getSavedIp();

    if (ip == null)
      return false;

    var uri = Uri.http("$ip:4646", "ffxivlauncher/$otp");

    try {
      await http.get(uri);
    } catch (e) {
      developer.log('could not send to: ' + uri.toString(), name: 'com.goatsoft.xl_otpsend', error: e);
      return false;
    }
    
    return true;
  }
}