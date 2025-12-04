import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final ValueNotifier<ll.LatLng?> _selectedLatLng = ValueNotifier(null);
  final ValueNotifier<bool> _useSatellite = ValueNotifier(false);

  Future<ll.LatLng> _getUserLocation() async {
    try {
      loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          throw Exception('Location service is disabled');
        }
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted == loc.PermissionStatus.denied ||
            permissionGranted == loc.PermissionStatus.deniedForever) {
          throw Exception('Location permission denied');
        }
      }

      final userLocation = await location.getLocation();

      if (userLocation.latitude == null || userLocation.longitude == null) {
        throw Exception('Could not get current location');
      }

      return ll.LatLng(userLocation.latitude!, userLocation.longitude!);
    } catch (e) {
      return const ll.LatLng(-6.2088, 106.8456);
    }
  }

  Future<Map<String, String>> _reverseGeocode(ll.LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) {
        return {
          "street": "${latLng.latitude}, ${latLng.longitude}",
          "city": "",
          "postal": "",
        };
      }

      final place = placemarks.first;

      return {
        "street": "${place.street ?? ''} ${place.thoroughfare ?? ''}".trim(),
        "city": place.subAdministrativeArea ?? place.locality ?? "",
        "postal": place.postalCode ?? "",
      };
    } catch (e) {
      return {
        "street": "${latLng.latitude}, ${latLng.longitude}",
        "city": "",
        "postal": "",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ll.LatLng>(
      future: _getUserLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(context.t('pick_location'))),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(context.t('back')),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final center = snapshot.data as ll.LatLng;

        return ValueListenableBuilder<bool>(
          valueListenable: _useSatellite,
          builder: (context, useSat, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text(context.t('pick_location')),
                actions: [
                  IconButton(
                    tooltip: useSat ? 'Streets' : 'Satellite',
                    icon: Icon(useSat ? Icons.map : Icons.satellite_alt),
                    onPressed: () => _useSatellite.value = !useSat,
                  ),
                ],
              ),
              body: Stack(
                children: [
                  fm.FlutterMap(
                    options: fm.MapOptions(
                      center: ll.LatLng(center.latitude, center.longitude),
                      zoom: 16.0,
                      onTap: (tapPosition, latlng) {
                        _selectedLatLng.value = latlng;
                      },
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: useSat
                            ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: useSat ? const [] : const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      ValueListenableBuilder<ll.LatLng?>(
                        valueListenable: _selectedLatLng,
                        builder: (context, sel, _) {
                          if (sel == null) return const SizedBox.shrink();
                          return fm.MarkerLayer(
                            markers: [
                              fm.Marker(
                                point: sel,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  ValueListenableBuilder<ll.LatLng?>(
                    valueListenable: _selectedLatLng,
                    builder: (context, sel, _) {
                      if (sel == null) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 22,
                        left: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: () async {
                            final data = await _reverseGeocode(sel);
                            data['lat'] = sel.latitude.toString();
                            data['lng'] = sel.longitude.toString();
                            context.pop(data);
                          },
                          child: Text(context.t('use_this_location')),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedLatLng.dispose();
    _useSatellite.dispose();
    super.dispose();
  }
}
