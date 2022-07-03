import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Communication {
  static const String IP_KEY = "IP";

  static Future<String?> getSavedIps() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(IP_KEY))
      return null;

    return prefs.getString(IP_KEY);
  }

  static Future<void> setSavedIps(String ips) async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString(IP_KEY, ips);
  }

  static Future<bool> sendOtp(String otp) async {
    String? ips = await Communication.getSavedIps();

    if (ips == null)
      return false;

    List<String>? ipList = ips.split(';');

    for (var currentIp = 0; currentIp < ips.length; currentIp++) {
      var ip = ipList[currentIp];
      var uri = Uri.http("$ip:4646", "ffxivlauncher/$otp");
      try {
        await http.get(uri);
      } on http
          .ClientException catch (e) { // This happens since the XL http server is badly implemented, no problem though
        developer.log('ClientException: ' + uri.toString(),
            name: 'com.goatsoft.xl_otpsend', error: e);
        return true;
      }
      catch (e) {
        developer.log('could not send to: ' + uri.toString(),
            name: 'com.goatsoft.xl_otpsend', error: e);
      }
    }
    return true;
  }
}