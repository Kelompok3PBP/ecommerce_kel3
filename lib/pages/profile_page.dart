import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// 'dart:io' show File; <-- DIHAPUS
// 'path_provider' dan 'path' juga tidak diperlukan untuk web
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
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
  // String? _imagePath; <-- DIHAPUS (Hanya untuk native)
  String? _webBase64;

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
        // _imagePath = prefs.getString('profile_picture_path'); <-- DIHAPUS
        _webBase64 = prefs.getString('profile_picture_base64');
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (mounted) Navigator.pop(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;
      final prefs = await SharedPreferences.getInstance();

      // Hanya jalankan logika WEB
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      await prefs.setString('profile_picture_base64', base64Image);
      await prefs.remove('profile_picture_path'); 

      if (mounted) {
        setState(() {
          _webBase64 = base64Image;
          // _imagePath = null; <-- DIHAPUS
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal mengambil gambar.',
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
    // Hanya jalankan logika WEB
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }
    // Bagian 'FileImage' dihapus
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: Center( 
          child: ConstrainedBox( 
            constraints: const BoxConstraints(
              maxWidth: 600, 
            ),
            child: ListView(
              padding: EdgeInsets.all(6.w),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 15.sp, 
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        backgroundImage: _buildProfileImage(),
                        child: _buildProfileImage() == null
                            ? Icon(
                                Icons.person,
                                size: 15.sp, 
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 5.sp, 
                          backgroundColor: theme.primaryColor,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 5.sp, 
                            ),
                            onPressed: _showImageSourceActionSheet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  userEmail,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.edit_note, color: theme.primaryColor),
                  title: Text("Edit Profil", style: TextStyle(fontSize: 13.sp)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 12.sp),
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
                  title: Text("Ubah Password", style: TextStyle(fontSize: 13.sp)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 12.sp),
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
        ),
      ),
    );
  }
}