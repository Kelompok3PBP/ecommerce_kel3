import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:sizer/sizer.dart';

import '../../../address/domain/entities/address.dart';
import '../../../address/presentation/cubits/address_cubit.dart';
import '../cubits/shipping_cubit.dart';
import '../../domain/entities/shipping_option.dart';
import '../../../settings/data/notification_service.dart';
import 'package:ecommerce/app/theme/app_theme.dart';

class ShippingSelectionPage extends StatefulWidget {
  static const String routeName = '/shipping-selection';
  final dynamic extra;

  const ShippingSelectionPage({super.key, this.extra});

  @override
  State<ShippingSelectionPage> createState() => _ShippingSelectionPageState();
}

class _ShippingSelectionPageState extends State<ShippingSelectionPage> {
  late final ValueNotifier<Address?> _selectedAddressNotifier;
  late final ValueNotifier<double> _subtotalNotifier;
  late final ValueNotifier<double> _totalWeightNotifier;

  @override
  void initState() {
    super.initState();
    _subtotalNotifier = ValueNotifier<double>(0.0);
    _totalWeightNotifier = ValueNotifier<double>(0.0);
    _selectedAddressNotifier = ValueNotifier<Address?>(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final addrCubit = context.read<AddressCubit>();
        addrCubit.fetchAll();
      } catch (_) {}

      if (widget.extra is Map<String, dynamic>) {
        final buyNowData = widget.extra as Map<String, dynamic>;
        final price = (buyNowData['price'] as num?)?.toDouble() ?? 0.0;
        final quantity = (buyNowData['quantity'] as num?)?.toInt() ?? 1;
        final total =
            (buyNowData['total'] as num?)?.toDouble() ?? (price * quantity);

        _subtotalNotifier.value = total;
        _totalWeightNotifier.value = quantity * 1.0;
      } else {
        _loadSelectedCheckout();
      }

      _restoreSelectedShippingOption();
    });
  }

  Future<void> _restoreSelectedShippingOption() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final shippingJson = prefs.getString('selected_shipping_option');
    if (shippingJson != null) {
      try {
        final shippingMap = jsonDecode(shippingJson) as Map<String, dynamic>;
        final option = ShippingOption.fromJson(shippingMap);
        if (mounted) {
          context.read<ShippingCubit>().selectShippingOption(option);
        }
      } catch (e) {
        print('Error restoring shipping option: $e');
      }
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
        weight += qty * 1.0;
      }

      _subtotalNotifier.value = subtotal;
      _totalWeightNotifier.value = weight;
    } catch (_) {}
  }

  void _onLoadShippingOptions() {
    if (_selectedAddressNotifier.value == null) {
      NotificationService.showIfEnabledDialog(
        context,
        title: 'Alamat',
        body: 'Pilih alamat terlebih dahulu',
      );
      return;
    }

    context.read<ShippingCubit>().loadShippingOptions(
      address: _selectedAddressNotifier.value!,
      totalWeight: _totalWeightNotifier.value > 0
          ? _totalWeightNotifier.value
          : 1.0,
    );
  }

  Future<void> _saveSelectedAddress(Address addr) async {
    try {
      final prefs = await sp.SharedPreferences.getInstance();
      await prefs.setString('selected_address', jsonEncode(addr.toJson()));
    } catch (e) {
      print('Failed to save selected address: $e');
    }
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

    final finalTotal = _subtotalNotifier.value + selected.cost;

    final source = (widget.extra is Map<String, dynamic>)
        ? (widget.extra as Map<String, dynamic>)['source'] as String?
        : null;

    context.go(
      '/payment',
      extra: {'finalTotal': finalTotal, 'source': source ?? 'cart'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        final double width = MediaQuery.of(context).size.width;
        final bool isMobile = width < 600;
        final bool isTablet = width >= 600 && width < 1024;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: isMobile ? 24.0 : 28.0,
                color: Colors.white,
              ),
              onPressed: () {
                String source = 'cart';
                if (widget.extra is Map<String, dynamic>) {
                  source =
                      (widget.extra as Map<String, dynamic>)['source']
                          as String? ??
                      'cart';
                }

                if (source == 'detail' &&
                    widget.extra is Map<String, dynamic>) {
                  final pid =
                      (widget.extra as Map<String, dynamic>)['productId']
                          ?.toString() ??
                      '';
                  if (pid.isNotEmpty) {
                    context.go('/detail/$pid');
                    return;
                  }
                }

                context.go('/cart');
              },
            ),
            title: Text(
              'Pilih Jasa Pengiriman',
              style: TextStyle(
                fontSize: isMobile ? 18.0 : 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Alamat',
                  style: TextStyle(
                    fontSize: isMobile ? 20.0 : 24.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isMobile ? 12.0 : 16.0),

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
                          style: TextStyle(fontSize: isMobile ? 12.0 : 14.0),
                        );
                      }

                      return ValueListenableBuilder<Address?>(
                        valueListenable: _selectedAddressNotifier,
                        builder: (context, selAddr, _) {
                          return Column(
                            children: addrs.map((addr) {
                              return RadioListTile<Address>(
                                value: addr,
                                groupValue: selAddr,
                                title: Text(
                                  '${addr.label} — ${addr.street}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.0 : 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  '${addr.city} • ${addr.postalCode}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12.0 : 14.0,
                                  ),
                                ),
                                onChanged: (v) {
                                  _selectedAddressNotifier.value = v;
                                  if (v != null) {
                                    _saveSelectedAddress(v);
                                  }
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () => _onLoadShippingOptions(),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
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
                  style: TextStyle(
                    fontSize: isMobile ? 18.0 : 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),

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
                            style: TextStyle(fontSize: isMobile ? 12.0 : 14.0),
                          );
                        }

                        return ListView(
                          children: options.map((opt) {
                            return RadioListTile<ShippingOption>(
                              value: opt,
                              groupValue: state.selectedOption,
                              title: Text(
                                '${opt.courierName} — ${opt.name}',
                                style: TextStyle(
                                  fontSize: isMobile ? 14.0 : 16.0,
                                ),
                              ),
                              subtitle: Text(
                                'Estimasi: ${opt.estimate ?? '-'} • Biaya: Rp ${opt.cost.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12.0 : 14.0,
                                ),
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

                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tekan tombol di bawah untuk memuat opsi pengiriman',
                              style: TextStyle(
                                fontSize: isMobile ? 12.0 : 14.0,
                              ),
                            ),
                            SizedBox(height: isMobile ? 12.0 : 16.0),
                            ElevatedButton(
                              onPressed: _onLoadShippingOptions,
                              child: Text(
                                'Pilih Jasa Pengiriman',
                                style: TextStyle(
                                  fontSize: isMobile ? 14.0 : 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                BlocBuilder<ShippingCubit, ShippingState>(
                  builder: (context, sState) {
                    double shippingCost = 0.0;
                    if (sState is ShippingLoaded &&
                        sState.selectedOption != null) {
                      shippingCost = sState.selectedOption!.cost;
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 14.0 : 18.0,
                          ),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: Text(
                          'Lanjut ke Pembayaran (Rp ${(_subtotalNotifier.value + shippingCost).toStringAsFixed(0)})',
                          style: TextStyle(fontSize: isMobile ? 14.0 : 16.0),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _subtotalNotifier.dispose();
    _totalWeightNotifier.dispose();
    _selectedAddressNotifier.dispose();
    super.dispose();
  }
}
