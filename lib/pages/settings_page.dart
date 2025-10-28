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
  bool darkMode = false;
  bool notif = true;

  @override
  void initState() {
    super.initState();
    _loadUserPrefs();
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      notif = prefs.getBool('notif') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('notif', notif);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.purple,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            icon: Icons.dark_mode,
            title: "Tampilan & Notifikasi",
            children: [
              SwitchListTile(
                activeColor: Colors.purple,
                title: const Text("Mode Gelap"),
                secondary: const Icon(Icons.nights_stay, color: Colors.purple),
                value: darkMode,
                onChanged: (val) async {
                  setState(() => darkMode = val);
                  await _savePrefs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val ? 'Mode Gelap Aktif 🌙' : 'Mode Terang Aktif ☀️',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                activeColor: Colors.purple,
                title: const Text("Notifikasi"),
                secondary: const Icon(
                  Icons.notifications,
                  color: Colors.purple,
                ),
                value: notif,
                onChanged: (val) async {
                  setState(() => notif = val);
                  await _savePrefs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'Notifikasi Diaktifkan 🔔'
                            : 'Notifikasi Dimatikan 🔕',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.info_outline,
            title: "Informasi Aplikasi",
            children: [
              _buildListTile(
                icon: Icons.devices,
                title: "Device Info",
                subtitle: "Lihat detail perangkat kamu",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceInfoPage()),
                ),
              ),
              _buildListTile(
                icon: Icons.storage,
                title: "Shared Preferences",
                subtitle: "Lihat data tersimpan di aplikasi",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SharedPreferencesPage(),
                  ),
                ),
              ),
              _buildListTile(
                icon: Icons.feedback,
                title: "Feedback",
                subtitle: "Berikan masukan untuk aplikasi ini",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.settings,
            title: "Lainnya",
            children: [
              _buildListTile(
                icon: Icons.language,
                title: "Bahasa",
                subtitle: "Pilih bahasa aplikasi",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text("Pilih Bahasa"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text("Indonesia 🇮🇩"),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
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
                                const SnackBar(
                                  content: Text('Language set to English 🇬🇧'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: "Tentang Aplikasi",
                subtitle: "Informasi versi & deskripsi aplikasi",
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Luminé Care",
                    applicationVersion: "1.0.0",
                    applicationIcon: const Icon(
                      Icons.spa,
                      color: Colors.purple,
                    ),
                    applicationLegalese:
                        "© 2025 Luminé Beauty Care\nAll rights reserved.",
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "Luminé Care membantu kamu memeriksa kandungan produk kecantikan dengan mudah dan cepat",
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
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.purple),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.purple,
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
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
