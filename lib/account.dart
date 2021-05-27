import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    var secure = new FlutterSecureStorage();

    var secret = await secure.read(key: SavedAccount.SECRET_KEY);

    if (secret == null) {
      var saved = await getSavedInsecure();

      if (saved != null) {
        await setSaved(saved);
      }

      return saved;
    }

    var accountName = await secure.read(key: SavedAccount.ACCOUNTNAME_KEY);

    if (accountName == null)
      return SavedAccount.unnamed(secret);

    return SavedAccount(accountName, secret);
  }

  static Future<SavedAccount?> getSavedInsecure() async {
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
    var secure = new FlutterSecureStorage();
    await secure.write(key: SavedAccount.SECRET_KEY, value: account.secret);
    await secure.write(key: SavedAccount.ACCOUNTNAME_KEY, value: account.accountName);

    var prefs = await SharedPreferences.getInstance();
    await prefs.remove(SavedAccount.SECRET_KEY);
    await prefs.remove(SavedAccount.ACCOUNTNAME_KEY);
  }

  @override
  String toString() {
    return '${accountName as String} - ${secret as String}';
  }
}
