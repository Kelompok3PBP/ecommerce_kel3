import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const EditProfilePage({super.key, required this.name, required this.email});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String newName = nameController.text;
    final String newEmail = emailController.text;
    final String oldEmail = widget.email;

    await prefs.setString('user_name', newName);
    await prefs.setString('user_email', newEmail);
    await prefs.setString('current_user', newEmail);

    if (newEmail != oldEmail) {
      List<String> registeredUsers =
          prefs.getStringList('registered_users') ?? [];
      String userPassword = '';
      int userIndex = -1;

      for (int i = 0; i < registeredUsers.length; i++) {
        final parts = registeredUsers[i].split(':');
        if (parts.length == 2 && parts[0] == oldEmail) {
          userPassword = parts[1];
          userIndex = i;
          break;
        }
      }

      if (userIndex != -1) {
        registeredUsers.removeAt(userIndex);
        registeredUsers.add("$newEmail:$userPassword");
        await prefs.setStringList('registered_users', registeredUsers);
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.t('profile_updated') + ' ✅'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(context.t('edit_profile'))),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: context.t('name')),
                ),
                SizedBox(height: 2.5.h),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: context.t('email')),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style
                        ?.copyWith(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(vertical: 1.8.h),
                          ),
                        ),
                    onPressed: _saveProfile,
                    child: Text(
                      context.t('save'),
                      style: TextStyle(fontSize: 16),
                    ),
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
