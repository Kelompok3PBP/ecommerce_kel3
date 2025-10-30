import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // Simpan user baru
  static Future<void> registerUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);
  }

  // Ambil user yang sudah tersimpan
  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final password = prefs.getString('user_password');

    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  // Validasi login
  static Future<bool> login(String email, String password) async {
    final user = await getUser();
    if (user == null) return false;
    return user['email'] == email && user['password'] == password;
  }

  // Logout / hapus data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_password');
  }
}
