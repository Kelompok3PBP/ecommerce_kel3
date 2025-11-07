import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart'; // <--- TAMBAHKAN IMPORT INI
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

  // (Fungsi _loadAllPrefs dan _clearPrefs tidak berubah)
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
          ? Center(child: Text("Belum ada data tersimpan", style: TextStyle(fontSize: 12.sp))) // Ganti size
          : ListView(
              // Ganti padding statis
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp, // Ganti size
                      ),
                    ),
                    subtitle: Text(
                      entry.value.toString(),
                      style: TextStyle(fontSize: 10.sp), // Ganti size
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