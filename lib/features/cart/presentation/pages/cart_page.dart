import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/app/theme/app_theme.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ValueNotifier<Set<String>> selectedProducts = ValueNotifier({});

  @override
  void initState() {
    super.initState();
  }

  Color _getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  String formatRupiah(double price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(price);
  }

  double getSelectedTotal(Map<dynamic, int> items) {
    double total = 0;
    for (final entry in items.entries) {
      final product = entry.key;
      final qty = entry.value;
      final id = product.id?.toString() ?? '';
      if (!selectedProducts.value.contains(id)) continue;

      final price = (product.price is num)
          ? (product.price as num).toDouble()
          : double.tryParse(product.price.toString()) ?? 0.0;

      total += price * (qty ?? 0);
    }
    return total;
  }

  @override
  void dispose() {
    selectedProducts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimaryColor = _getTextPrimaryColor(context);
    final textSecondaryColor = _getTextSecondaryColor(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(
          context.t('cart'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isMobile = width < 600;
          final bool isTablet = width >= 600 && width < 1024;

          final double iconSize = isMobile ? 18.w : (isTablet ? 64 : 80);
          final double imageWidth = isMobile ? 20.w : (isTablet ? 120 : 140);
          final double imageHeight = isMobile ? 12.h : (isTablet ? 100 : 120);

          final double outerPaddingH = isMobile ? 4.w : (isTablet ? 24 : 32);
          final double outerPaddingV = isMobile ? 2.h : (isTablet ? 16 : 20);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: BlocListener<CartCubit, CartState>(
                listener: (context, state) {
                  if (state.items.isNotEmpty) {
                    final cartProductIds = Set.of(
                      state.items.keys.map((p) => p.id?.toString() ?? ''),
                    );
                    final validSelected = selectedProducts.value
                        .where(cartProductIds.contains)
                        .toSet();
                    if (validSelected.length != selectedProducts.value.length) {
                      selectedProducts.value = validSelected;
                    }
                  }
                },
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    if (state.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: AppTheme.secondaryColor,
                              size: iconSize,
                            ),
                            SizedBox(height: isMobile ? 2.h : 16),
                            Text(
                              context.t('cart_empty') + ' 🛍️',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 18,
                                color: textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: outerPaddingH,
                        vertical: outerPaddingV,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "(${state.items.length} Item)",
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 22,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: isMobile ? 2.h : 16),

                          Expanded(
                            child: ValueListenableBuilder<Set<String>>(
                              valueListenable: selectedProducts,
                              builder: (context, selectedSet, _) {
                                return ListView.separated(
                                  itemCount: state.items.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: isMobile ? 1.5.h : 12),
                                  itemBuilder: (context, index) {
                                    final entry = state.items.entries.elementAt(
                                      index,
                                    );
                                    final product = entry.key;
                                    final qty = entry.value;

                                    return InkWell(
                                      onTap: () {
                                        try {
                                          final pid =
                                              product.id?.toString() ?? '';
                                          if (pid.isNotEmpty) {
                                            context.go('/detail/$pid');
                                          }
                                        } catch (_) {}
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.cardColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: textPrimaryColor
                                                  .withOpacity(0.1),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            isMobile ? 3.w : 16,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: selectedSet.contains(
                                                  product.id?.toString() ?? '',
                                                ),
                                                onChanged: (checked) {
                                                  final newSet = Set.of(
                                                    selectedSet,
                                                  );
                                                  final pid =
                                                      product.id?.toString() ??
                                                      '';
                                                  if (checked == true) {
                                                    newSet.add(pid);
                                                  } else {
                                                    newSet.remove(pid);
                                                  }
                                                  selectedProducts.value =
                                                      newSet;
                                                },
                                                activeColor: theme.primaryColor,
                                                checkColor: Colors.white,
                                              ),

                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  product.image,
                                                  width: imageWidth,
                                                  height: imageHeight,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                              SizedBox(
                                                width: isMobile ? 3.w : 16,
                                              ),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.title ?? '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 15
                                                            : 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppTheme
                                                            .primaryColor,
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: isMobile
                                                          ? 1.h
                                                          : 10,
                                                    ),

                                                    Text(
                                                      formatRupiah(
                                                        (product.price as num)
                                                            .toDouble(),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 14
                                                            : 15,
                                                        color: textPrimaryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),

                                                    SizedBox(
                                                      height: isMobile
                                                          ? 1.h
                                                          : 12,
                                                    ),

                                                    Row(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: AppTheme
                                                                  .secondaryColor,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.remove,
                                                                  size: 20,
                                                                  color: AppTheme
                                                                      .primaryColor,
                                                                ),
                                                                onPressed: () =>
                                                                    context
                                                                        .read<
                                                                          CartCubit
                                                                        >()
                                                                        .decrease(
                                                                          product,
                                                                        ),
                                                              ),
                                                              Text(
                                                                '$qty',
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      textPrimaryColor,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  size: 20,
                                                                  color: AppTheme
                                                                      .primaryColor,
                                                                ),
                                                                onPressed: () =>
                                                                    context
                                                                        .read<
                                                                          CartCubit
                                                                        >()
                                                                        .add(
                                                                          product,
                                                                        ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const Spacer(),

                                                        IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 26,
                                                          ),
                                                          onPressed: () {
                                                            final newSet = Set.of(
                                                              selectedProducts
                                                                  .value,
                                                            );
                                                            newSet.remove(
                                                              product.id
                                                                      ?.toString() ??
                                                                  '',
                                                            );
                                                            selectedProducts
                                                                    .value =
                                                                newSet;

                                                            context
                                                                .read<
                                                                  CartCubit
                                                                >()
                                                                .remove(
                                                                  product,
                                                                );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();

          return ValueListenableBuilder<Set<String>>(
            valueListenable: selectedProducts,
            builder: (context, selectedSet, _) {
              final selectedTotal = getSelectedTotal(state.items);

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: textPrimaryColor.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Price",
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondaryColor,
                          ),
                        ),
                        Text(
                          formatRupiah(selectedTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: selectedSet.isEmpty
                            ? null
                            : () async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                final sel = state.items.entries
                                    .where(
                                      (e) => selectedSet.contains(
                                        e.key.id?.toString() ?? '',
                                      ),
                                    )
                                    .map((e) {
                                      final product = e.key;
                                      return {
                                        'product_id': product.id.toString(),
                                        'product_name': product.title,
                                        'product_image': product.image,
                                        'price': product.price,
                                        'quantity': e.value ?? 1,
                                      };
                                    })
                                    .toList();

                                await prefs.setString(
                                  'selected_checkout',
                                  jsonEncode(sel),
                                );

                                context.go(
                                  '/shipping-selection',
                                  extra: {'source': 'cart'},
                                );
                              },
                        child: Text(
                          context.t('checkout'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
