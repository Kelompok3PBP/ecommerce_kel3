import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';

class SharedPreferencesPage extends StatefulWidget {
  const SharedPreferencesPage({super.key});

  @override
  State<SharedPreferencesPage> createState() => _SharedPreferencesPageState();
}

class _SharedPreferencesPageState extends State<SharedPreferencesPage> {
  final ValueNotifier<Map<String, Object>> dataNotifier = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _loadAllPrefs();
  }

  Future<void> _loadAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final Map<String, Object> temp = {};
    for (var key in allKeys) {
      temp[key] = prefs.get(key) ?? 'null';
    }
    dataNotifier.value = temp;
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadAllPrefs();
    await NotificationService.showIfEnabledDialog(
      context,
      title: context.t('success'),
      body: 'Data telah dihapus 🗑️',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('app_info')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllPrefs),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearPrefs),
        ],
      ),
      body: ValueListenableBuilder<Map<String, Object>>(
        valueListenable: dataNotifier,
        builder: (context, data, child) {
          if (data.isEmpty) {
            return Center(
              child: Text(context.t('info'), style: TextStyle(fontSize: 16)),
            );
          }

          return ListView(
            padding: EdgeInsets.all(2.w),
            children: data.entries.map((entry) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    entry.value.toString(),
                    style: TextStyle(fontSize: 14),
                  ),
                  leading: Icon(Icons.storage, color: AppTheme.primaryColor),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    dataNotifier.dispose();
    super.dispose();
  }
}
