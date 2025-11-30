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
  const AddressFormPage({Key? key, this.address}) : super(key: key);

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  ll.LatLng? _previewLatLng;
  bool _useSatellite = false;
  late TextEditingController labelController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController postalController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.address?.label ?? '');
    streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    cityController = TextEditingController(text: widget.address?.city ?? '');
    postalController = TextEditingController(
      text: widget.address?.postalCode ?? '',
    );
    phoneController = TextEditingController(text: widget.address?.phone ?? '');
  }

  @override
  void dispose() {
    labelController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = Address(
        id: widget.address?.id ?? 0,
        label: labelController.text,
        street: streetController.text,
        city: cityController.text,
        postalCode: postalController.text,
        phone: phoneController.text,
      );
      final cubit = context.read<AddressCubit>();
      if (widget.address == null) {
        cubit.create(address);
      } else {
        cubit.update(address);
      }
      Navigator.pop(context);
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

                  // LABEL
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

                  // STREET
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

                  // CITY
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

                  // POSTAL CODE
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

                  // PHONE
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

                  // ➕ GOOGLE MAP PICKER BUTTON
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result =
                          await context.push('/map') as Map<String, dynamic>?;

                      if (result != null) {
                        setState(() {
                          streetController.text = result['street'] ?? '';
                          cityController.text = result['city'] ?? '';
                          postalController.text = result['postal'] ?? '';

                          // if map returned coordinates, show map preview
                          final latStr = result['lat'];
                          final lngStr = result['lng'];
                          if (latStr != null && lngStr != null) {
                            final lat = double.tryParse(latStr.toString());
                            final lng = double.tryParse(lngStr.toString());
                            if (lat != null && lng != null) {
                              _previewLatLng = ll.LatLng(lat, lng);
                            }
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text("Pilih Lokasi di Maps"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, buttonHeight),
                    ),
                  ),

                  SizedBox(height: spacingLarge),

                  // MAP PREVIEW (with satellite toggle)
                  if (_previewLatLng != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: _useSatellite ? 'Streets' : 'Satellite',
                              icon: Icon(
                                _useSatellite ? Icons.map : Icons.satellite_alt,
                              ),
                              onPressed: () => setState(
                                () => _useSatellite = !_useSatellite,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: isWide ? 260 : 180,
                          child: fm.FlutterMap(
                            options: fm.MapOptions(
                              center: _previewLatLng,
                              zoom: 16.0,
                            ),
                            children: [
                              fm.TileLayer(
                                urlTemplate: _useSatellite
                                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: _useSatellite
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
                    ),

                  // SUBMIT BUTTON
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
