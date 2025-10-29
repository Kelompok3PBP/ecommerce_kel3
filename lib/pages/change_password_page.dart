// change_password_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_page.dart'; // ✅ panggil theme di sini

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
          backgroundColor: AppTheme.primaryColor, // ✅ Ganti
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', passController.text);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Password berhasil diubah"),
        backgroundColor: Colors.green, // ✅ Ganti ke warna sukses
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Konfirmasi Password",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style, // ✅ Ganti
              onPressed: _savePassword,
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}