import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:go_router/go_router.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final ValueNotifier<Map<String, dynamic>> _deviceData = ValueNotifier({});
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (kIsWeb) {
        final info = await deviceInfo.webBrowserInfo;
        deviceData = {
          "Browser Name": describeEnum(info.browserName),
          "User Agent": info.userAgent,
          "Platform": info.platform,
          "Vendor": info.vendor,
        };
      } else if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        deviceData = {
          "OS": "Windows",
          "Computer Name": info.computerName,
          "Number of Cores": info.numberOfCores,
          "System Memory (MB)": info.systemMemoryInMegabytes,
          "OS Version": "${info.majorVersion}.${info.minorVersion}",
        };
      } else if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceData = {
          "OS": "Android",
          "Brand": info.brand,
          "Model": info.model,
          "Android Version": info.version.release,
          "SDK Int": info.version.sdkInt,
          "Device": info.device,
        };
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceData = {
          "OS": "iOS",
          "Name": info.name,
          "Model": info.model,
          "System Version": info.systemVersion,
        };
      } else {
        deviceData = {"OS": "Unknown"};
      }
    } catch (e) {
      deviceData = {"Error": "Failed to get device info"};
    }

    if (mounted) {
      _deviceData.value = deviceData;
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        centerTitle: true,
        title: Text(
          "Device Info",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, loading, child) {
          if (loading) return const Center(child: CircularProgressIndicator());

          final deviceData = _deviceData.value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: deviceData.entries.map((e) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    e.value.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
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
    _deviceData.dispose();
    _isLoading.dispose();
    super.dispose();
  }
}
