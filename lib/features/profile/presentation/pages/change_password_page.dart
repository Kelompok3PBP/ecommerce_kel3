import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _old = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('current_user') ?? '';
    final users = prefs.getStringList('registered_users') ?? [];

    for (int i = 0; i < users.length; i++) {
      final parts = users[i].split(':');
      if (parts.length == 2 && parts[0] == current) {
        if (parts[1] != _old.text) {
          if (mounted) {
            await NotificationService.showIfEnabledDialog(
              context,
              title: 'Error',
              body: context.t('old_password_wrong'),
            );
          }
          return;
        }

        if (_pass.text != _confirm.text) {
          if (mounted) {
            await NotificationService.showIfEnabledDialog(
              context,
              title: 'Error',
              body: context.t('password_mismatch'),
            );
          }
          return;
        }

        users[i] = '${parts[0]}:${_pass.text}';
        await prefs.setStringList('registered_users', users);
        if (mounted) {
          await NotificationService.showIfEnabledDialog(
            context,
            title: 'Berhasil',
            body: context.t('password_changed'),
          );
        }
        context.pop();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('change_password'))),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                TextField(
                  controller: _old,
                  decoration: InputDecoration(
                    labelText: context.t('old_password'),
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: _pass,
                  decoration: InputDecoration(
                    labelText: context.t('new_password'),
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: _confirm,
                  decoration: InputDecoration(
                    labelText: context.t('confirm_password'),
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _change,
                    child: Text(context.t('change')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
