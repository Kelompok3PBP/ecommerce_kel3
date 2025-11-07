import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'theme_page.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
  });

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
    await prefs.setString('user_name', nameController.text);
    await prefs.setString('user_email', emailController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil berhasil disimpan ✅"),
        backgroundColor: Colors.green,
      ),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profil"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w), // <-- Layout Sizer OK
          child: Container(
            constraints:
                const BoxConstraints(maxWidth: 600), // <-- Adaptif OK
            padding: EdgeInsets.all(6.w), // <-- Layout Sizer OK
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                  ),
                ),
                SizedBox(height: 2.5.h), // <-- Layout Sizer OK
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                SizedBox(height: 4.h), // <-- Layout Sizer OK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          padding: WidgetStateProperty.all(
                            EdgeInsets.symmetric(vertical: 1.8.h), // <-- Layout Sizer OK
                          ),
                        ),
                    onPressed: _saveProfile,
                    child: Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16), // <-- GANTI DARI 13.sp
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