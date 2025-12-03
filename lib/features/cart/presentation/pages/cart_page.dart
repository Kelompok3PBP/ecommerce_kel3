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
  final Set<dynamic> selectedProducts = {};

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
    for (var product in selectedProducts) {
      final qty = items[product] ?? 0;
      total += (product.price ?? 0) * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
          final double iconSize = isMobile ? 18.w : (isTablet ? 64.0 : 80.0);
          final double imageWidth = isMobile
              ? 20.w
              : (isTablet ? 120.0 : 140.0);
          final double imageHeight = isMobile
              ? 12.h
              : (isTablet ? 100.0 : 120.0);
          final double outerPaddingH = isMobile
              ? 4.w
              : (isTablet ? 24.0 : 32.0);
          final double outerPaddingV = isMobile
              ? 2.h
              : (isTablet ? 16.0 : 20.0);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
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
                          SizedBox(height: isMobile ? 2.h : 16.0),
                          Text(
                            context.t('cart_empty') + ' 🛍️',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 18.0,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Select all by default if nothing selected.
                  // Use post frame callback to avoid calling setState during build.
                  if (selectedProducts.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          selectedProducts.addAll(state.items.keys);
                        });
                      }
                    });
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
                            fontSize: isMobile ? 20 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2.h : 16.0),
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.items.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: isMobile ? 1.5.h : 12.0),
                            itemBuilder: (context, index) {
                              final entry = state.items.entries.elementAt(
                                index,
                              );
                              final product = entry.key;
                              final qty = entry.value;

                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isMobile ? 3.w : 16.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: selectedProducts.contains(
                                          product,
                                        ),
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedProducts.add(product);
                                            } else {
                                              selectedProducts.remove(product);
                                            }
                                          });
                                        },
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          product.image,
                                          width: imageWidth,
                                          height: imageHeight,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 3.w : 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: isMobile ? 16 : 18.0,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 0.5.h : 8.0,
                                            ),
                                            Text(
                                              formatRupiah(product.price),
                                              style: TextStyle(
                                                fontSize: isMobile ? 15 : 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: isMobile ? 1.h : 10.0,
                                            ),
                                            Row(
                                              children: [
                                                // quantity control
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
                                                          size: isMobile
                                                              ? 20
                                                              : 20.0,
                                                          color: AppTheme
                                                              .primaryColor,
                                                        ),
                                                        onPressed: () => context
                                                            .read<CartCubit>()
                                                            .decrease(product),
                                                      ),
                                                      Text(
                                                        '$qty',
                                                        style: TextStyle(
                                                          fontSize: isMobile
                                                              ? 16
                                                              : 16.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.add,
                                                          size: isMobile
                                                              ? 20
                                                              : 20.0,
                                                          color: AppTheme
                                                              .secondaryColor,
                                                        ),
                                                        onPressed: () => context
                                                            .read<CartCubit>()
                                                            .add(product),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                // delete button
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.redAccent,
                                                    size: isMobile ? 24 : 26.0,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedProducts.remove(
                                                        product,
                                                      );
                                                    });
                                                    context
                                                        .read<CartCubit>()
                                                        .remove(product);
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
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();

          final selectedTotal = getSelectedTotal(state.items);

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(0.1),
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
                    const Text(
                      "Total Price",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondaryColor,
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
                    onPressed: selectedProducts.isEmpty
                        ? null
                        : () async {
                            final prefs = await SharedPreferences.getInstance();
                            final sel = selectedProducts.map((p) {
                              return {
                                'product_id': p.id.toString(),
                                'product_name': p.title,
                                'product_image': p.image,
                                'price': p.price,
                                'quantity':
                                    (context.read<CartCubit>().state.items[p] ??
                                    1),
                              };
                            }).toList();
                            await prefs.setString(
                              'selected_checkout',
                              jsonEncode(sel),
                            );

                            context.go('/shipping-selection');
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
      ),
    );
  }
}
