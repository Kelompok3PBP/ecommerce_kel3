import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'theme_page.dart';

class SharedPreferencesPage extends StatefulWidget {
  const SharedPreferencesPage({super.key});

  @override
  State<SharedPreferencesPage> createState() => _SharedPreferencesPageState();
}

class _SharedPreferencesPageState extends State<SharedPreferencesPage> {
  Map<String, Object> data = {};

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
    setState(() {
      data = temp;
    });
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadAllPrefs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Semua data SharedPreferences dihapus 🗑️")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Shared Preferences"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllPrefs),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clearPrefs),
        ],
      ),
      body: data.isEmpty
          ? Center(child: Text("Belum ada data tersimpan", style: TextStyle(fontSize: 16))) // <-- GANTI DARI 12.sp
          : ListView(
              padding: EdgeInsets.all(2.w), // <-- Layout Sizer OK
              children: data.entries.map((entry) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // <-- GANTI DARI 12.sp
                      ),
                    ),
                    subtitle: Text(
                      entry.value.toString(),
                      style: TextStyle(fontSize: 14), // <-- GANTI DARI 10.sp
                    ),
                    leading:
                        Icon(Icons.storage, color: AppTheme.primaryColor),
                  ),
                );
              }).toList(),
            ),
    );
  }
}