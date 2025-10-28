// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  // ✅ Constructor sekarang KOSONG, tidak butuh parameter lagi
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel untuk menampung data yang akan diambil
  String name = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data saat halaman dibuka
    _loadProfile();
  }

  // Fungsi untuk mengambil data dari SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        name = prefs.getString('user_name') ?? "No Name";
        email = prefs.getString('user_email') ?? "No Email";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.purple,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profil"),
            onTap: () async {
              // Pindah ke halaman edit, kirim data yang sudah di-load
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfilePage(name: name, email: email)),
              );
              // Jika ada perubahan (result == true), muat ulang data profil
              if (result == true) {
                _loadProfile();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profil berhasil diperbarui"), backgroundColor: Colors.green),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ubah Password"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
          ),
        ],
      ),
    );
  }
}