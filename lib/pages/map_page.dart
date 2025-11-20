import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import '../services/localization_extension.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selectedLatLng;

  Future<LatLng> _getUserLocation() async {
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

      return LatLng(userLocation.latitude!, userLocation.longitude!);
    } catch (e) {
      // Return default location (Jakarta) if location access fails
      return const LatLng(-6.2088, 106.8456);
    }
  }

  Future<Map<String, String>> _reverseGeocode(LatLng latLng) async {
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
    return FutureBuilder<LatLng>(
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

        final center = snapshot.data as LatLng;

        return Scaffold(
          appBar: AppBar(title: Text(context.t('pick_location'))),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: center, zoom: 16),
                onMapCreated: (controller) {
                  // Map created
                },
                onTap: (latLng) {
                  setState(() {
                    _selectedLatLng = latLng;
                  });
                },
                markers: _selectedLatLng != null
                    ? {
                        Marker(
                          markerId: const MarkerId("selected"),
                          position: _selectedLatLng!,
                        ),
                      }
                    : {},
              ),

              // CONFIRM BUTTON
              if (_selectedLatLng != null)
                Positioned(
                  bottom: 22,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = await _reverseGeocode(_selectedLatLng!);
                      context.pop(data);
                    },
                    child: Text(context.t('use_this_location')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
