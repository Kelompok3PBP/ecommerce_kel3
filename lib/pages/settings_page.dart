import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import '../bloc/language_cubit.dart';
import '../services/localization_service.dart';
import '../services/localization_extension.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notif = true;

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
    final background = theme.colorScheme.surface;
    final textMain = theme.textTheme.bodyLarge!.color!;
    final textSub = theme.textTheme.bodyMedium!.color!;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(context.t('app_settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigasi kembali ke dashboard pakai GoRouter
            context.go('/dashboard');
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: EdgeInsets.all(4.w),
            children: [
              _buildSection(
                icon: Icons.notifications,
                title: context.t('notifications'),
                theme: theme,
                children: [
                  SwitchListTile(
                    activeThumbColor: primary,
                    title: Text(
                      context.t('notifications'),
                      style: TextStyle(color: textMain, fontSize: 16),
                    ),
                    secondary: Icon(Icons.notifications, color: primary),
                    value: notif,
                    onChanged: (val) async {
                      setState(() => notif = val);
                      await _savePrefs(val);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? context.t('notifications_enabled')
                                : context.t('notifications_disabled'),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: secondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildSection(
                icon: Icons.info_outline,
                title: context.t('app_info'),
                theme: theme,
                children: [
                  _buildListTile(
                    icon: Icons.devices,
                    title: context.t('device_info'),
                    subtitle: context.t('view_device_info'),
                    theme: theme,
                    onTap: () {
                      context.push('/device-info');
                    },
                  ),
                  _buildListTile(
                    icon: Icons.feedback,
                    title: context.t('feedback'),
                    subtitle: context.t('send_feedback'),
                    theme: theme,
                    onTap: () {
                      context.push('/feedback');
                    },
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildSection(
                icon: Icons.settings,
                title: context.t('settings'),
                theme: theme,
                children: [
                  _buildListTile(
                    icon: Icons.language,
                    title: context.t('language'),
                    subtitle: context.t('select_language'),
                    theme: theme,
                    onTap: () {
                      _showLanguageDialog(context, primary, secondary);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.info,
                    title: context.t('about_app'),
                    subtitle: context.t('app_info'),
                    theme: theme,
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Belanja.in",
                        applicationVersion: "1.0.0",
                        applicationIcon: Icon(Icons.storefront, color: primary),
                        applicationLegalese: context.t('all_rights_reserved'),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 1.5.h),
                            child: Text(
                              context.t('app_description'),
                              style: TextStyle(color: textSub, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.group,
                    title: 'About Us',
                    subtitle: 'Team member names',
                    theme: theme,
                    onTap: () {
                      // Navigate to About page via GoRouter
                      context.go('/about');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Row(
              children: [
                Icon(icon, color: primary),
                SizedBox(width: 2.5.w),
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
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textMain,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textSub, fontSize: 14))
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primary),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    Color primary,
    Color secondary,
  ) {
    final languages = AppLocalizations.getLanguages();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          AppLocalizations.t(
            'select_language',
            languageCode: context.read<LanguageCubit>().state.languageCode,
          ),
          style: TextStyle(color: primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            final code = entry.key;
            final langData = entry.value;
            final name = langData['name'] ?? '';
            final flag = langData['flag'] ?? '';

            return ListTile(
              title: Text('$name $flag', style: const TextStyle(fontSize: 15)),
              onTap: () {
                context.read<LanguageCubit>().changeLanguage(code, name, flag);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: secondary,
                    content: Text(
                      AppLocalizations.t(
                        'language_changed',
                        languageCode: code,
                      ),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
