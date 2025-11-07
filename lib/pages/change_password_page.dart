import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'theme_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  Future<void> _savePassword() async {
    if (passController.text != confirmController.text ||
        passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Password tidak sama atau kosong"),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', passController.text);

    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password berhasil diubah"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Password"),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w), // <-- Layout Sizer OK
        child: Column(
          children: [
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
              ),
            ),
            SizedBox(height: 2.h), // <-- Layout Sizer OK
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Konfirmasi Password",
              ),
            ),
            SizedBox(height: 4.h), // <-- Layout Sizer OK
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: _savePassword,
              child: Text(
                "Simpan",
                style: TextStyle(fontSize: 16), // <-- GANTI DARI 13.sp
              ),
            ),
          ],
        ),
      ),
    );
  }
}