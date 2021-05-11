import 'package:shared_preferences/shared_preferences.dart';

class SavedAccount {
  static const String SECRET_KEY = "SECRET";
  static const String ACCOUNTNAME_KEY = "ACCOUNT_NAME";

  String? accountName;
  String? secret;

  SavedAccount(this.accountName, this.secret);
  SavedAccount.unnamed(this.secret) : accountName = '';

  static SavedAccount parse(String uri) {
    var parsedUri = Uri.parse(uri);

    var secret = parsedUri.queryParameters["secret"];

    var accountName = parsedUri.pathSegments[0];
    accountName = accountName.substring(15); // Skips "Square Enix ID"

    return SavedAccount(accountName, secret);
  }

  static Future<SavedAccount?> getSaved() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(SavedAccount.SECRET_KEY))
      return null;

    var secret = prefs.getString(SavedAccount.SECRET_KEY);

    if (!prefs.containsKey(SavedAccount.ACCOUNTNAME_KEY))
      return SavedAccount.unnamed(secret);

    var accountName = prefs.getString(SavedAccount.ACCOUNTNAME_KEY);

    return SavedAccount(accountName, secret);
  }

  static Future<void> setSaved(SavedAccount account) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(SavedAccount.SECRET_KEY, account.secret as String);
    prefs.setString(SavedAccount.ACCOUNTNAME_KEY, account.accountName as String);
  }

  @override
  String toString() {
    return '${accountName as String} - ${secret as String}'; 
  }
}
