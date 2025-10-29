// pages/profile_page.dart

import 'dart:io' show File;
import 'dart:convert'; // untuk base64 web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "";
  String userEmail = "";
  String? _imagePath;
  String? _webBase64; // khusus web

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = prefs.getString('user_name') ?? 'User';
        userEmail = prefs.getString('user_email') ?? 'user@mail.com';
        _imagePath = prefs.getString('profile_picture_path');
        _webBase64 = prefs.getString('profile_picture_base64');
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (mounted) Navigator.pop(context); // Tutup bottom sheet

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile == null) return; // Pengguna batal

      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        // ✅ WEB: simpan base64
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        await prefs.setString('profile_picture_base64', base64Image);
        await prefs.remove('profile_picture_path'); // bersihin sisa lama

        if (mounted) {
          setState(() {
            _webBase64 = base64Image;
            _imagePath = null;
          });
        }
      } else {
        // ✅ ANDROID / iOS: simpan file biasa
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final savedImagePath = path.join(appDir.path, fileName);
        final savedImage = await File(pickedFile.path).copy(savedImagePath);

        await prefs.setString('profile_picture_path', savedImage.path);
        await prefs.remove('profile_picture_base64');

        if (mounted) {
          setState(() {
            _imagePath = savedImage.path;
            _webBase64 = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal mengambil gambar. Pastikan izin kamera/galeri diizinkan.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil dari Kamera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildProfileImage() {
    // ✅ WEB
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }

    // ✅ MOBILE
    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return FileImage(File(_imagePath!));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    backgroundImage: _buildProfileImage(),
                    child: _buildProfileImage() == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.primaryColor,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showImageSourceActionSheet,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: Icon(Icons.edit_note, color: theme.primaryColor),
              title: const Text("Edit Profil"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfilePage(name: userName, email: userEmail),
                  ),
                );
                if (result == true && mounted) {
                  _loadProfile();
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.lock_reset, color: theme.primaryColor),
              title: const Text("Ubah Password"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
