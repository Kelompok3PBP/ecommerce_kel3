import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Map<String, dynamic> _deviceData = {};

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    {
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
          "Build Number": info.buildNumber,
        };
      } else if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceData = {
          "OS": "Android",
          "Brand": info.brand,
          "Model": info.model,
          "Android Version": info.version.release,
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
    }

    if (mounted) setState(() => _deviceData = deviceData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Info")),
      body: _deviceData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _deviceData.entries.map((e) {
                return ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(e.key),
                  subtitle: Text(e.value.toString()),
                );
              }).toList(),
            ),
    );
  }
}
