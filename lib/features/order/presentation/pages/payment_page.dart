import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/features/settings/data/notification_service.dart';
import 'package:ecommerce/features/shipping/domain/entities/shipping_option.dart';

class PaymentPage extends StatefulWidget {
  final dynamic extra;
  const PaymentPage({super.key, this.extra});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late ValueNotifier<String?> selectedMethodNotifier;
  bool isBuyNow = false;
  Map<String, dynamic> buyNowData = {};
  double total = 0;
  ShippingOption? selectedShippingOption;
  String source = 'cart';

  @override
  void initState() {
    super.initState();
    selectedMethodNotifier = ValueNotifier<String?>(null);
    if (widget.extra is Map) {
      final extraMap = widget.extra as Map<String, dynamic>;
      source = extraMap['source'] as String? ?? 'cart';

      if (source == 'detail' && extraMap.containsKey('productId')) {
        isBuyNow = true;
        buyNowData = extraMap;
        total = (extraMap['total'] as num?)?.toDouble() ?? 0;
      } else if (extraMap.containsKey('finalTotal')) {
        total = (extraMap['finalTotal'] as num?)?.toDouble() ?? 0;
      }
    } else if (widget.extra is double) {
      total = widget.extra as double;
      source = 'cart';
    }
    _loadShippingData();
  }

  @override
  void dispose() {
    selectedMethodNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadShippingData() async {
    final prefs = await sp.SharedPreferences.getInstance();
    final shippingJson = prefs.getString('selected_shipping_option');
    if (shippingJson != null) {
      try {
        final shippingMap = jsonDecode(shippingJson) as Map<String, dynamic>;
        selectedShippingOption = ShippingOption.fromJson(shippingMap);
      } catch (e) {
        print('Error loading shipping option: $e');
      }
    }
  }

  String formatRupiah(double price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isMobile ? 24.0 : 28.0,
            color: Colors.white,
          ),
          onPressed: () {
            if (source == 'detail') {
              final extra = Map<String, dynamic>.from(buyNowData);
              extra['source'] = 'detail';
              context.go('/shipping-selection', extra: extra);
            } else {
              context.go('/shipping-selection', extra: {'source': 'cart'});
            }
          },
        ),
        title: Text(
          context.t('payment'),
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 18.0 : 20.0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: ValueListenableBuilder<String?>(
          valueListenable: selectedMethodNotifier,
          builder: (context, selectedMethod, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.t('cart_total')} ${formatRupiah(total)}',
                  style: TextStyle(
                    fontSize: isMobile ? 18.0 : 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 18.0 : 24.0),
                Text(
                  context.t('payment_method'),
                  style: TextStyle(fontSize: isMobile ? 14.0 : 16.0),
                ),
                RadioListTile<String>(
                  value: 'Transfer Bank',
                  groupValue: selectedMethod,
                  title: Text(
                    'Transfer Bank',
                    style: TextStyle(fontSize: isMobile ? 14.0 : 15.0),
                  ),
                  onChanged: (v) => selectedMethodNotifier.value = v,
                ),
                RadioListTile<String>(
                  value: 'E-Wallet (OVO, DANA, GoPay)',
                  groupValue: selectedMethod,
                  title: Text(
                    'E-Wallet (OVO, DANA, GoPay)',
                    style: TextStyle(fontSize: isMobile ? 14.0 : 15.0),
                  ),
                  onChanged: (v) => selectedMethodNotifier.value = v,
                ),
                RadioListTile<String>(
                  value: 'Bayar di Tempat (COD)',
                  groupValue: selectedMethod,
                  title: Text(
                    'Bayar di Tempat (COD)',
                    style: TextStyle(fontSize: isMobile ? 14.0 : 15.0),
                  ),
                  onChanged: (v) => selectedMethodNotifier.value = v,
                ),
                const Spacer(),
                ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    minimumSize: MaterialStateProperty.all(
                      Size(double.infinity, isMobile ? 52.0 : 56.0),
                    ),
                  ),
                  onPressed: selectedMethod == null
                      ? null
                      : () async {
                          final prefs =
                              await sp.SharedPreferences.getInstance();
                          final email = prefs.getString('current_user') ?? '';
                          final name =
                              prefs.getString('current_user_name') ?? '';
                          final phone =
                              prefs.getString('current_user_phone') ?? '';
                          final addressRaw =
                              prefs.getString('selected_address') ?? '';
                          String address = '';
                          if (addressRaw.isNotEmpty) {
                            try {
                              final Map<String, dynamic> addrMap =
                                  jsonDecode(addressRaw)
                                      as Map<String, dynamic>;
                              final label =
                                  addrMap['label'] ?? addrMap['name'] ?? '';
                              final street = addrMap['street'] ?? '';
                              final city = addrMap['city'] ?? '';
                              final postal =
                                  addrMap['postalCode'] ??
                                  addrMap['postal_code'] ??
                                  '';
                              address = [label, street, city, postal]
                                  .where(
                                    (s) => s != null && s.toString().isNotEmpty,
                                  )
                                  .join(', ');
                            } catch (e) {
                              address = addressRaw;
                            }
                          }

                          List<Map<String, dynamic>> items = [];
                          double productSubtotal = 0;

                          try {
                            if (isBuyNow) {
                              items.add({
                                'product_id':
                                    buyNowData['productId']?.toString() ?? '',
                                'product_name': buyNowData['productName'] ?? '',
                                'product_image':
                                    buyNowData['productImage'] ?? '',
                                'quantity': buyNowData['quantity'] ?? 1,
                                'price': buyNowData['price'] ?? 0,
                                'subtotal':
                                    (buyNowData['price'] ?? 0) *
                                    (buyNowData['quantity'] ?? 1),
                              });
                              productSubtotal = buyNowData['total'] ?? 0;
                            } else {
                              final selJson = prefs.getString(
                                'selected_checkout',
                              );
                              if (selJson != null) {
                                final parsed =
                                    jsonDecode(selJson) as List<dynamic>;
                                for (var entry in parsed) {
                                  final Map<String, dynamic> m =
                                      Map<String, dynamic>.from(entry as Map);
                                  final qty =
                                      int.tryParse(
                                        m['quantity']?.toString() ?? '',
                                      ) ??
                                      (m['quantity'] is num
                                          ? (m['quantity'] as num).toInt()
                                          : 1);
                                  final priceVal =
                                      double.tryParse(
                                        m['price']?.toString() ?? '',
                                      ) ??
                                      (m['price'] is num
                                          ? (m['price'] as num).toDouble()
                                          : 0.0);
                                  items.add({
                                    'product_id':
                                        m['product_id']?.toString() ?? '',
                                    'product_name': m['product_name'] ?? '',
                                    'product_image': m['product_image'] ?? '',
                                    'quantity': qty,
                                    'price': priceVal,
                                    'subtotal': (priceVal * qty),
                                  });
                                  productSubtotal += (priceVal * qty);
                                }
                              } else {
                                final cartState = context
                                    .read<CartCubit>()
                                    .state;
                                cartState.items.forEach((product, quantity) {
                                  final priceVal = (product.price is num)
                                      ? (product.price as num).toDouble()
                                      : double.tryParse(
                                              product.price?.toString() ?? '',
                                            ) ??
                                            0.0;
                                  items.add({
                                    'product_id': product.id.toString(),
                                    'product_name': product.title,
                                    'product_image': product.image,
                                    'quantity': quantity,
                                    'price': priceVal,
                                    'subtotal': priceVal * quantity,
                                  });
                                  productSubtotal += priceVal * quantity;
                                });
                              }
                            }
                          } catch (e) {
                            print('Error extracting cart items: $e');
                            items = [];
                            productSubtotal = total;
                          }

                          final shippingCost =
                              selectedShippingOption?.cost ?? 0.0;
                          final finalTotal = productSubtotal + shippingCost;

                          final orderId = DateTime.now().millisecondsSinceEpoch
                              .toString();
                          final orderDate = DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(DateTime.now());

                          print('DEBUG: items count = ${items.length}');
                          print('DEBUG: productSubtotal = $productSubtotal');
                          if (items.isNotEmpty) {
                            print('DEBUG: first item = ${items[0]}');
                          }

                          final receiptMap = {
                            'order_id': orderId,
                            'order_date': orderDate,
                            'customer_name': name.isNotEmpty ? name : email,
                            'customer_email': email,
                            'customer_phone': phone,
                            'shipping_address': address,
                            'items': items,
                            'subtotal': productSubtotal,
                            'shipping_cost': shippingCost,
                            'tax': 0,
                            'discount': 0,
                            'total_amount': finalTotal,
                            'payment_method': selectedMethod,
                            'payment_status': 'Success',
                            'purchase_structure': 'Pembayaran Penuh',
                            'installment_months': 0,
                            'installment_amount': 0,
                            'selected_shipping_option':
                                selectedShippingOption != null
                                ? selectedShippingOption!.toJson()
                                : null,
                          };

                          final receiptJson = jsonEncode(receiptMap);
                          final historyList =
                              prefs.getStringList('purchase_history') ?? [];
                          historyList.insert(0, receiptJson);
                          await prefs.setStringList(
                            'purchase_history',
                            historyList,
                          );

                          if (!isBuyNow) {
                            context.read<CartCubit>().clear();
                            await prefs.remove('selected_checkout');
                          }

                          await NotificationService.showIfEnabledDialog(
                            context,
                            title: context.t('payment_success'),
                            body: context.t('payment_success'),
                          );

                          if (mounted) {
                            context.go(
                              '/purchase-receipt/$orderId',
                              extra: receiptMap,
                            );
                          }
                        },
                  child: Text(
                    context.t('pay_now'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
