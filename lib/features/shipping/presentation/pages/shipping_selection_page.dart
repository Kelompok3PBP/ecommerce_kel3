import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:sizer/sizer.dart'; // Import Sizer

// Import Entitas Dummy yang diperlukan untuk memuat opsi
import '../../../address/domain/entities/address.dart';
import '../../../address/presentation/cubits/address_cubit.dart';
import '../cubits/shipping_cubit.dart';
import '../../domain/entities/shipping_option.dart';
import '../../../settings/data/notification_service.dart';

class ShippingSelectionPage extends StatefulWidget {
  static const String routeName = '/shipping-selection';
  final dynamic extra;

  const ShippingSelectionPage({super.key, this.extra});

  @override
  State<ShippingSelectionPage> createState() => _ShippingSelectionPageState();
}

class _ShippingSelectionPageState extends State<ShippingSelectionPage> {
  Address? _selectedAddress;
  double _subtotal = 0.0;
  double _totalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    // Ensure addresses are loaded by AddressCubit
    try {
      final addrCubit = context.read<AddressCubit>();
      addrCubit.fetchAll();
    } catch (_) {
      // AddressCubit not provided above — router should provide it.
    }

    // Handle BUY NOW flow: extra contains product data
    if (widget.extra is Map<String, dynamic>) {
      final buyNowData = widget.extra as Map<String, dynamic>;
      final price = (buyNowData['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (buyNowData['quantity'] as num?)?.toInt() ?? 1;
      final total =
          (buyNowData['total'] as num?)?.toDouble() ?? (price * quantity);

      setState(() {
        _subtotal = total;
        _totalWeight = quantity * 1.0; // assume 1kg per item
      });
    } else {
      _loadSelectedCheckout();
    }
  }

  Future<void> _loadSelectedCheckout() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final selJson = prefs.getString('selected_checkout');
    if (selJson == null) return;

    try {
      final List items = jsonDecode(selJson) as List;
      double subtotal = 0.0;
      double weight = 0.0;
      for (final it in items) {
        final price = (it['price'] as num?)?.toDouble() ?? 0.0;
        final qty = (it['quantity'] as num?)?.toInt() ?? 1;
        subtotal += price * qty;
        weight += qty * 1.0; // assume 1kg per item if not available
      }

      setState(() {
        _subtotal = subtotal;
        _totalWeight = weight;
      });
    } catch (_) {}
  }

  void _onLoadShippingOptions() {
    if (_selectedAddress == null) {
      NotificationService.showIfEnabledDialog(
        context,
        title: 'Alamat',
        body: 'Pilih alamat terlebih dahulu',
      );
      return;
    }

    context.read<ShippingCubit>().loadShippingOptions(
      address: _selectedAddress!,
      totalWeight: _totalWeight > 0 ? _totalWeight : 1.0,
    );
  }

  Future<void> _proceedToPayment() async {
    final state = context.read<ShippingCubit>().state;
    if (state is! ShippingLoaded || state.selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih opsi pengiriman terlebih dahulu')),
      );
      return;
    }

    final selected = state.selectedOption!;
    final prefs = await sp.SharedPreferences.getInstance();
    await prefs.setString(
      'selected_shipping_option',
      jsonEncode(selected.toJson()),
    );

    final finalTotal = _subtotal + selected.cost;

    // Navigate to payment and pass final total
    context.go('/payment', extra: finalTotal);
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Sizer untuk inisialisasi di root widget
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pilih Jasa Pengiriman')),
          body: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Alamat',
                  // 👇 Ukuran font dikecilkan dari 18.sp menjadi 16.sp
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),

                // Addresses
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, astate) {
                    if (astate is AddressLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (astate is AddressListLoaded) {
                      final addrs = astate.addresses;
                      if (addrs.isEmpty) {
                        return Text(
                          'Belum ada alamat. Tambah di Pengaturan > Alamat.',
                          // 👇 Ukuran font dikecilkan dari 11.sp menjadi 9.sp
                          style: TextStyle(fontSize: 9.sp),
                        );
                      }

                      return Column(
                        children: addrs.map((addr) {
                          return RadioListTile<Address>(
                            value: addr,
                            groupValue: _selectedAddress,
                            // 👇 Ukuran font dikecilkan dari 12.sp menjadi 10.sp
                            title: Text('${addr.label} — ${addr.street}',
                                style: TextStyle(fontSize: 10.sp)),
                            // 👇 Ukuran font dikecilkan dari 10.sp menjadi 9.sp
                            subtitle: Text('${addr.city} • ${addr.postalCode}',
                                style: TextStyle(fontSize: 9.sp)),
                            onChanged: (v) => setState(() => _selectedAddress = v),
                          );
                        }).toList(),
                      );
                    }

                    if (astate is AddressError)
                      return Text('Error: ${astate.message}');

                    return const Text('Memuat alamat...');
                  },
                ),

                SizedBox(height: 1.5.h),

                const Divider(),
                SizedBox(height: 1.h),

                Text(
                  'Opsi Pengiriman',
                  // 👇 Ukuran font dikecilkan dari 18.sp menjadi 16.sp
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),

                // Shipping options
                Expanded(
                  child: BlocConsumer<ShippingCubit, ShippingState>(
                    listener: (context, state) {
                      if (state is ShippingError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      if (state is ShippingLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ShippingLoaded) {
                        final options = state.options;
                        if (options.isEmpty) {
                          return Text(
                            'Tidak ada opsi pengiriman.',
                            // 👇 Ukuran font dikecilkan dari 11.sp menjadi 9.sp
                            style: TextStyle(fontSize: 9.sp),
                          );
                        }

                        return ListView(
                          children: options.map((opt) {
                            return RadioListTile<ShippingOption>(
                              value: opt,
                              groupValue: state.selectedOption,
                              // 👇 Ukuran font dikecilkan dari 12.sp menjadi 10.sp
                              title: Text('${opt.courierName} — ${opt.name}',
                                  style: TextStyle(fontSize: 10.sp)),
                              subtitle: Text(
                                'Estimasi: ${opt.estimate ?? '-'} • Biaya: Rp ${opt.cost.toStringAsFixed(0)}',
                                // 👇 Ukuran font dikecilkan dari 10.sp menjadi 9.sp
                                style: TextStyle(fontSize: 9.sp),
                              ),
                              onChanged: (v) {
                                if (v != null) {
                                  context
                                      .read<ShippingCubit>()
                                      .selectShippingOption(v);
                                }
                              },
                            );
                          }).toList(),
                        );
                      }

                      // Initial / empty state
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tekan tombol di bawah untuk memuat opsi pengiriman',
                              // 👇 Ukuran font dikecilkan dari 11.sp menjadi 9.sp
                              style: TextStyle(fontSize: 9.sp),
                            ),
                            SizedBox(height: 1.5.h),
                            ElevatedButton(
                              onPressed: _onLoadShippingOptions,
                              child: Text('Pilih Jasa Pengiriman',
                                  // 👇 Ukuran font dikecilkan dari 11.sp menjadi 10.sp
                                  style: TextStyle(fontSize: 10.sp)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom action: proceed to payment
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: Text(
                      'Lanjut ke Pembayaran (Rp ${(_subtotal + (context.read<ShippingCubit>().state is ShippingLoaded && (context.read<ShippingCubit>().state as ShippingLoaded).selectedOption != null ? (context.read<ShippingCubit>().state as ShippingLoaded).selectedOption!.cost : 0.0)).toStringAsFixed(0)})',
                      // 👇 Ukuran font dikecilkan dari 12.sp menjadi 11.sp
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}