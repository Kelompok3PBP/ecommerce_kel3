import 'package:shared_preferences/shared_preferences.dart';

/// Service ini HANYA untuk dibaca oleh GoRouter
/// untuk menentukan status login.
class AuthService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Kita pakai 'is_logged_in' yang sudah kamu set di LoginPage
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (await isLoggedIn()) {
      // Kita pakai 'current_user' yang sudah kamu set di LoginPage
      return prefs.getString('current_user');
    }
    return null;
  }
}