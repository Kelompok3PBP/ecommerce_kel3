import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ValueNotifier<String> userNameNotifier;
  late final ValueNotifier<String> userEmailNotifier;
  late final ValueNotifier<String?> _imagePathNotifier;
  late final ValueNotifier<String?> _webBase64Notifier;

  @override
  void initState() {
    super.initState();
    userNameNotifier = ValueNotifier<String>('');
    userEmailNotifier = ValueNotifier<String>('');
    _imagePathNotifier = ValueNotifier<String?>(null);
    _webBase64Notifier = ValueNotifier<String?>(null);

    _loadProfile();
  }

  @override
  void dispose() {
    userNameNotifier.dispose();
    userEmailNotifier.dispose();
    _imagePathNotifier.dispose();
    _webBase64Notifier.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userNameNotifier.value = prefs.getString('user_name') ?? 'User';
    userEmailNotifier.value = prefs.getString('user_email') ?? 'user@mail.com';
    _imagePathNotifier.value = prefs.getString('profile_picture_path');
    _webBase64Notifier.value = prefs.getString('profile_picture_base64');
  }

  Future<void> _pickImage(ImageSource source) async {
    if (mounted) Navigator.pop(context);

    if (!kIsWeb) {
      final granted = await _ensurePermissionForSource(source);
      if (!granted) return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      final prefs = await SharedPreferences.getInstance();

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        await prefs.setString('profile_picture_base64', base64Image);
        await prefs.remove('profile_picture_path');
        _webBase64Notifier.value = base64Image;
        _imagePathNotifier.value = null;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final savedImagePath = path.join(appDir.path, fileName);

        final File savedImage = await File(
          pickedFile.path,
        ).copy(savedImagePath);

        await prefs.setString('profile_picture_path', savedImage.path);
        await prefs.remove('profile_picture_base64');

        _imagePathNotifier.value = savedImage.path;
        _webBase64Notifier.value = null;
      }
    } catch (e) {
      if (mounted) {
        await NotificationService.showIfEnabledDialog(
          context,
          title: context.t('error'),
          body: 'Gagal menyimpan gambar',
        );
      }
    }
  }

  Future<bool> _ensurePermissionForSource(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
    } else {
      if (Platform.isAndroid) {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }
    }

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        final open = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.t('permission_denied')),
            content: Text(context.t('permission_denied_explain')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(context.t('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(context.t('open_settings')),
              ),
            ],
          ),
        );

        if (open == true) await openAppSettings();
      }
      return false;
    }

    if (mounted) {
      await NotificationService.showIfEnabledDialog(
        context,
        title: context.t('permission_required'),
        body: 'Aplikasi memerlukan akses ke galeri',
      );
    }

    return false;
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
    final webBase64 = _webBase64Notifier.value;
    final imagePath = _imagePathNotifier.value;
    if (kIsWeb && webBase64 != null) {
      try {
        return MemoryImage(base64Decode(webBase64));
      } catch (_) {
        return null;
      }
    }
    if (!kIsWeb && imagePath != null && File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('my_profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.all(6.w),
              children: [
                Center(
                  child: Stack(
                    children: [
                      // Wrap in ValueListenableBuilder so image updates when changed
                      ValueListenableBuilder<String?>(
                        valueListenable: _imagePathNotifier,
                        builder: (context, imagePath, _) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: _webBase64Notifier,
                            builder: (context, webBase64, _) {
                              final profileImage = _buildProfileImage();
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: theme.primaryColor.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: profileImage,
                                child: profileImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: theme.colorScheme.primary,
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: theme.primaryColor,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: _showImageSourceActionSheet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                ValueListenableBuilder<String>(
                  valueListenable: userNameNotifier,
                  builder: (context, userName, _) {
                    return Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    );
                  },
                ),
                SizedBox(height: 1.h),
                ValueListenableBuilder<String>(
                  valueListenable: userEmailNotifier,
                  builder: (context, userEmail, _) {
                    return Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.h),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.edit_note, color: theme.primaryColor),
                  title: Text(
                    context.t('edit_profile'),
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final result = await context.push(
                      '/edit-profile',
                      extra: {
                        'name': userNameNotifier.value,
                        'email': userEmailNotifier.value,
                      },
                    );

                    if (result == true) {
                      await _loadProfile();
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.location_on, color: theme.primaryColor),
                  title: Text(
                    context.t('Alamat'),
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.go('/addresses');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.lock_reset, color: theme.primaryColor),
                  title: Text(
                    context.t('change_password'),
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/change-password');
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
