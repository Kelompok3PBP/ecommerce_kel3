import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_cubit.dart';
import 'theme_page.dart';
import '../services/localization_extension.dart';

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
      appBar: AppBar(title: Text(context.t('cart'))),
      body: Center(
        child: ConstrainedBox(
          // <-- Adaptif OK
          constraints: const BoxConstraints(maxWidth: 800),
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    context.t('cart_empty') + ' 🛍️',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(3.w), // <-- Layout Sizer OK
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final entry = state.items.entries.elementAt(index);
                  final product = entry.key;
                  final qty = entry.value;

                  return Card(
                    margin: EdgeInsets.symmetric(
                      vertical: 1.h,
                    ), // <-- Layout Sizer OK
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(
                        3.w,
                      ), // <-- Layout Sizer OK
                      leading: Image.network(
                        product.image,
                        width: 15.w, // <-- Layout Sizer OK
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15), // <-- GANTI DARI 11.sp
                      ),
                      subtitle: Text(
                        formatRupiah(product.price * qty),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // <-- GANTI DARI 11.sp
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppTheme.primaryColor,
                              size: 28, // <-- GANTI DARI 20.sp
                            ),
                            onPressed: () =>
                                context.read<CartCubit>().decrease(product),
                          ),
                          Text(
                            '$qty',
                            style: TextStyle(
                              fontSize: 16,
                            ), // <-- GANTI DARI 13.sp
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.secondaryColor,
                              size: 28, // <-- GANTI DARI 20.sp
                            ),
                            onPressed: () =>
                                context.read<CartCubit>().add(product),
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
      bottomNavigationBar: Builder(
        builder: (context) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.all(4.w), // <-- Layout Sizer OK
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
                      '${context.t('cart_total')}: ${formatRupiah(state.total)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    ElevatedButton(
                      style: theme.elevatedButtonTheme.style,
                      onPressed: () {
                        context.push('/payment', extra: state.total);
                      },
                      child: Text(
                        context.t('checkout'),
                        style: TextStyle(fontSize: 15),
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
