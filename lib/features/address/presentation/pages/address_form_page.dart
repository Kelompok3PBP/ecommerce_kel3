import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/address/presentation/cubits/address_cubit.dart';
import 'package:ecommerce/features/address/domain/entities/address.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

class AddressFormPage extends StatefulWidget {
  final Address? address;
  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  ll.LatLng? _previewLatLng;
  late ValueNotifier<bool> useSatelliteNotifier;

  late TextEditingController labelController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController postalController;
  late TextEditingController phoneController;

  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();
    useSatelliteNotifier = ValueNotifier<bool>(false);
    labelController = TextEditingController(text: widget.address?.label ?? '');
    streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    cityController = TextEditingController(text: widget.address?.city ?? '');
    postalController = TextEditingController(
      text: widget.address?.postalCode ?? '',
    );
    phoneController = TextEditingController(text: widget.address?.phone ?? '');

    latitudeController = TextEditingController(
      text: widget.address?.latitude?.toString() ?? '',
    );
    longitudeController = TextEditingController(
      text: widget.address?.longitude?.toString() ?? '',
    );

    final initialLat = widget.address?.latitude;
    final initialLng = widget.address?.longitude;
    if (initialLat != null && initialLng != null) {
      _previewLatLng = ll.LatLng(initialLat, initialLng);
    }
  }

  @override
  void dispose() {
    labelController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalController.dispose();
    phoneController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final double? latitude = double.tryParse(latitudeController.text);
      final double? longitude = double.tryParse(longitudeController.text);

      final address = Address(
        id: widget.address?.id ?? 0,
        label: labelController.text,
        street: streetController.text,
        city: cityController.text,
        postalCode: postalController.text,
        phone: phoneController.text,

        latitude: latitude,
        longitude: longitude,
      );

      final cubit = context.read<AddressCubit>();

      if (widget.address == null) {
        cubit.create(address);
      } else {
        cubit.update(address);
      }

      context.pop();
    }
  }

  void _handleMapResult(Map<String, dynamic> result) {
    streetController.text = result['street'] ?? '';
    cityController.text = result['city'] ?? '';
    postalController.text = result['postal'] ?? '';

    final latStr = result['lat'];
    final lngStr = result['lng'];

    if (latStr != null && lngStr != null) {
      final lat = double.tryParse(latStr.toString());
      final lng = double.tryParse(lngStr.toString());

      if (lat != null && lng != null) {
        _previewLatLng = ll.LatLng(lat, lng);

        latitudeController.text = lat.toString();
        longitudeController.text = lng.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 700;

    final double fieldFontSize = isWide ? 16.0 : 12.sp;
    final double contentVertical = isWide ? 12.0 : 1.h;
    final double contentHorizontal = isWide ? 12.0 : 3.w;
    final double spacingSmall = isWide ? 12.0 : 1.h;
    final double spacingLarge = isWide ? 18.0 : 2.h;
    final double buttonHeight = isWide ? 48.0 : 6.h;
    final EdgeInsetsGeometry outerPadding = isWide
        ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0)
        : EdgeInsets.all(4.w);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Tambah Alamat' : 'Edit Alamat'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: outerPadding,
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: spacingSmall),

                  TextFormField(
                    controller: labelController,
                    decoration: InputDecoration(
                      labelText: 'Label',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: contentVertical,
                        horizontal: contentHorizontal,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: TextStyle(fontSize: fieldFontSize),
                  ),

                  SizedBox(height: spacingSmall),

                  TextFormField(
                    controller: streetController,
                    decoration: InputDecoration(
                      labelText: 'Jalan',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: contentVertical,
                        horizontal: contentHorizontal,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: TextStyle(fontSize: fieldFontSize),
                  ),

                  SizedBox(height: spacingSmall),

                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'Kota',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: contentVertical,
                        horizontal: contentHorizontal,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: TextStyle(fontSize: fieldFontSize),
                  ),

                  SizedBox(height: spacingSmall),

                  TextFormField(
                    controller: postalController,
                    decoration: InputDecoration(
                      labelText: 'Kode Pos',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: contentVertical,
                        horizontal: contentHorizontal,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: TextStyle(fontSize: fieldFontSize),
                  ),

                  SizedBox(height: spacingSmall),

                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Telepon',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: contentVertical,
                        horizontal: contentHorizontal,
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                    style: TextStyle(fontSize: fieldFontSize),
                  ),

                  SizedBox(height: spacingLarge),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                          await context.push('/map') as Map<String, dynamic>?;

                      if (result != null) {
                        _handleMapResult(result);
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: Text(
                      _previewLatLng == null
                          ? "Pilih Lokasi di Maps"
                          : "Ubah Lokasi di Maps",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, buttonHeight),
                    ),
                  ),

                  SizedBox(
                    height: 0,
                    width: 0,
                    child: Column(
                      children: [
                        TextFormField(controller: latitudeController),
                        TextFormField(controller: longitudeController),
                      ],
                    ),
                  ),

                  SizedBox(height: spacingLarge),

                  if (_previewLatLng != null)
                    ValueListenableBuilder<bool>(
                      valueListenable: useSatelliteNotifier,
                      builder: (context, useSatellite, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lokasi Dipilih (${_previewLatLng!.latitude.toStringAsFixed(4)}, ${_previewLatLng!.longitude.toStringAsFixed(4)})',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                IconButton(
                                  tooltip: useSatellite
                                      ? 'Streets'
                                      : 'Satellite',
                                  icon: Icon(
                                    useSatellite
                                        ? Icons.map
                                        : Icons.satellite_alt,
                                  ),
                                  onPressed: () {
                                    useSatelliteNotifier.value = !useSatellite;
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: isWide ? 260 : 180,
                              child: fm.FlutterMap(
                                options: fm.MapOptions(
                                  initialCenter: _previewLatLng!,
                                  initialZoom: 16.0,
                                ),
                                children: [
                                  fm.TileLayer(
                                    urlTemplate: useSatellite
                                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                        : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: useSatellite
                                        ? const []
                                        : const ['a', 'b', 'c'],
                                  ),
                                  fm.MarkerLayer(
                                    markers: [
                                      fm.Marker(
                                        point: _previewLatLng!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  SizedBox(height: spacingLarge),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        widget.address == null ? 'Tambah' : 'Simpan',
                        style: TextStyle(fontSize: fieldFontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
