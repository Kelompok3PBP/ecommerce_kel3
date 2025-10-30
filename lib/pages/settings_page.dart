import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_info_page.dart';
import 'shared_preferences_page.dart';
import 'feedback_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true; // default true

  @override
  void initState() {
    super.initState();
    _loadUserPrefs();
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotif = prefs.getBool('notif');
    if (mounted) {
      setState(() {
        notif = savedNotif ?? true;
      });
    }
  }

  Future<void> _savePrefs(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final background = theme.colorScheme.background;
    final textMain = theme.textTheme.bodyLarge!.color!;
    final textSub = theme.textTheme.bodyMedium!.color!;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔔 Bagian Notifikasi
          _buildSection(
            icon: Icons.notifications,
            title: "Notifikasi",
            theme: theme,
            children: [
              SwitchListTile(
                activeColor: primary,
                title: Text("Notifikasi", style: TextStyle(color: textMain)),
                secondary: Icon(Icons.notifications, color: primary),
                value: notif,
                onChanged: (val) async {
                  setState(() => notif = val);
                  await _savePrefs(val); // Simpan nilai baru
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'Notifikasi Diaktifkan 🔔'
                            : 'Notifikasi Dimatikan 🔕',
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: secondary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ℹ️ Bagian Informasi Aplikasi
          _buildSection(
            icon: Icons.info_outline,
            title: "Informasi Aplikasi",
            theme: theme,
            children: [
              _buildListTile(
                icon: Icons.devices,
                title: "Device Info",
                subtitle: "Lihat detail perangkat kamu",
                theme: theme,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceInfoPage()),
                ),
              ),
              _buildListTile(
                icon: Icons.feedback,
                title: "Feedback",
                subtitle: "Berikan masukan untuk aplikasi ini",
                theme: theme,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackPage()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ⚙️ Bagian Lainnya
          _buildSection(
            icon: Icons.settings,
            title: "Lainnya",
            theme: theme,
            children: [
              _buildListTile(
                icon: Icons.language,
                title: "Bahasa",
                subtitle: "Pilih bahasa aplikasi",
                theme: theme,
                onTap: () {
                  _showLanguageDialog(context, primary, secondary);
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: "Tentang Aplikasi",
                subtitle: "Informasi versi & deskripsi aplikasi",
                theme: theme,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "MaroonMart",
                    applicationVersion: "1.0.0",
                    applicationIcon: Icon(Icons.storefront, color: primary),
                    applicationLegalese:
                        "© 2025 MaroonMart\nAll rights reserved.",
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "MaroonMart adalah platform e-commerce elegan dengan sentuhan maroon dan beige yang memudahkan kamu dalam berbelanja online.",
                          style: TextStyle(color: textSub),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    final primary = theme.colorScheme.primary;
    final background = theme.colorScheme.surface;
    return Card(
      color: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final primary = theme.colorScheme.primary;
    final textMain = theme.textTheme.bodyLarge!.color!;
    final textSub = theme.textTheme.bodyMedium!.color!;

    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textMain),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textSub))
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primary),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(
      BuildContext context, Color primary, Color secondary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Pilih Bahasa",
          style: TextStyle(color: primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Indonesia 🇮🇩"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: secondary,
                    content: const Text(
                      'Bahasa diatur ke Indonesia 🇮🇩',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("English 🇬🇧"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: secondary,
                    content: const Text(
                      'Language set to English 🇬🇧',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
