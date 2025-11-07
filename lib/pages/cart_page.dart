// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../bloc/cart_cubit.dart';
import 'theme_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      
      // 👇👇 INI PERUBAHANNYA 👇👇
      body: Center( // 1. Buat ke tengah
        child: ConstrainedBox( // 2. Batasi lebarnya
          constraints: const BoxConstraints(
            maxWidth: 800, // 3. Lebar maksimal 800px
          ),
          child: BlocBuilder<CartCubit, CartState>( // 4. Ini konten aslimu
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    'Keranjang masih kosong 🛍️',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(3.w),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final entry = state.items.entries.elementAt(index);
                  final product = entry.key;
                  final qty = entry.value;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(3.w),
                      leading: Image.network(
                        product.image,
                        width: 15.w,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      subtitle: Text(
                        formatRupiah(product.price * qty),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppTheme.primaryColor,
                              size: 20.sp, // Ganti dari .dp ke .sp
                            ),
                            onPressed: () =>
                                context.read<CartCubit>().decrease(product),
                          ),
                          Text(
                            '$qty',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.secondaryColor,
                              size: 20.sp, // Ganti dari .dp ke .sp
                            ),
                            onPressed: () => context.read<CartCubit>().add(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      // 👆👆 SAMPAI SINI 👆👆

      bottomNavigationBar: Builder(
        builder: (context) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${formatRupiah(state.total)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/payment',
                        arguments: state.total,
                      ),
                      child: Text(
                        'Checkout',
                        style: TextStyle(fontSize: 12.sp),
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