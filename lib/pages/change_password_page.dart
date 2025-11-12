import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'theme_page.dart';
import '../services/localization_extension.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  Future<void> _savePassword() async {
    final newPassword = passController.text;
    if (newPassword.isEmpty || newPassword != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('password_mismatch')),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('current_user');
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('error')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<String> registeredUsers =
        prefs.getStringList('registered_users') ?? [];
    int userIndex = -1;

    for (int i = 0; i < registeredUsers.length; i++) {
      final parts = registeredUsers[i].split(':');
      if (parts.length == 2 && parts[0] == email) {
        userIndex = i;
        break;
      }
    }

    if (userIndex != -1) {
      registeredUsers.removeAt(userIndex);
      registeredUsers.add("$email:$newPassword");
      await prefs.setStringList('registered_users', registeredUsers);
    } else {
      print("Error: Gagal menemukan user $email di registered_users");
    }

    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('success')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('change_password'))),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(labelText: context.t('new_password')),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.t('confirm_password'),
              ),
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style,
              onPressed: _savePassword,
              child: Text(context.t('save'), style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
