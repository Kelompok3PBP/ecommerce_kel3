import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;

  const ProfilePage({super.key, required this.name, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name;
  late String email;

  @override
  void initState() {
    super.initState();
    name = widget.name;
    email = widget.email;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('user_name') ?? name;
      email = prefs.getString('user_email') ?? email;
    });
  }

  Future<void> _saveProfile(String newName, String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    await prefs.setString('user_email', newEmail);
    setState(() {
      name = newName;
      email = newEmail;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.purple,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profil"),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(name: name, email: email), //
                ),
              );

              if (result != null && result is Map) {
                _saveProfile(result['name'], result['email']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil berhasil diperbarui")),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ubah Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
