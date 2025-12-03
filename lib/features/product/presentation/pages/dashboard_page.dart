import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:ecommerce/features/cart/presentation/cubits/cart_cubit.dart';
import 'package:ecommerce/features/product/presentation/cubits/product_cubit.dart';
import 'package:ecommerce/features/product/domain/entities/product.dart';
import 'package:ecommerce/app/theme/theme_provider.dart';
import 'package:ecommerce/features/settings/data/localization_extension.dart';
import 'package:ecommerce/app/theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  const DashboardPage({super.key, required this.email});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  String _currentQuery = "";
  String? _categoryFilter;
  String _sortMode = 'none';
  String userName = "";
  String userEmail = "";
  String? _webBase64;
  late TextEditingController _searchController;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ImageProvider? _buildProfileImage() {
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return 'Elektronik';
      case 'jewelery':
        return 'Perhiasan';
      case "men's clothing":
        return 'Pakaian Pria';
      case "women's clothing":
        return 'Pakaian Wanita';
      default:
        return category;
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? widget.email.split('@')[0];
      userEmail = prefs.getString('user_email') ?? widget.email;
      _webBase64 = prefs.getString('profile_picture_base64');
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _currentQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final q = _currentQuery.trim().toLowerCase();

    Iterable<Product> result = products;

    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      result = result.where(
        (p) => p.category.toLowerCase() == _categoryFilter!.toLowerCase(),
      );
    }

    if (q.isNotEmpty) {
      if (_categoryFilter == null) {
        result = result.where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              translateCategory(p.category).toLowerCase().contains(q),
        );
      } else {
        result = result.where((p) => p.title.toLowerCase().contains(q));
      }
    }

    if (_sortMode == 'price_asc') {
      final list = result.toList();
      list.sort((a, b) => a.price.compareTo(b.price));
      result = list;
    } else if (_sortMode == 'price_desc') {
      final list = result.toList();
      list.sort((a, b) => b.price.compareTo(a.price));
      result = list;
    }

    filteredProducts = result.toList();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('is_logged_in', false);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic scale biar ukuran pas di semua device
    double fontScale = screenWidth < 600
        ? 1.0
        : screenWidth < 1000
            ? 0.9
            : 0.8;

    double paddingScale = screenWidth < 600
        ? 1.0
        : screenWidth < 1000
            ? 0.8
            : 0.7;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(context.t('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Pesanan',
            onPressed: () => context.go('/order-history'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.go('/cart'),
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '${state.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
            ),
            onPressed: () =>
                themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          products = state.products;
          _applyFilters();

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              _searchProducts("");
              await context.read<ProductCubit>().fetchProducts();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h * paddingScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Responsive banner: use LayoutBuilder and Sizer so height
                    // adapts smoothly across device sizes without distortion.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        // Choose banner height based on available width, but
                        // expressed with Sizer (.h) so it scales with screen height.
                        double bannerHeight;
                        if (w < 600) {
                          bannerHeight = 20.h;
                        } else if (w < 1000) {
                          bannerHeight = 16.h;
                        } else {
                          bannerHeight = 12.h;
                        }

                        // Ensure a reasonable min/max pixel height to avoid
                        // extremely small or huge banners on edge cases.
                        if (bannerHeight < 120) bannerHeight = 120;
                        if (bannerHeight > 320) bannerHeight = 320;

                        return Container(
                          width: double.infinity,
                          height: bannerHeight,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                            child: Image.asset(
                              'assets/images/banner.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: bannerHeight,
                              alignment: Alignment.center,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 2.h * paddingScale),
                    _buildCategoryChips(),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: context.t('search'),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                          ),
                          suffixIcon: _currentQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchProducts('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) => _searchProducts(v),
                      ),
                    ),

                    // Sorting
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: DropdownButtonFormField<String>(
                        value:
                            (_sortMode == 'price_asc' ||
                                    _sortMode == 'price_desc')
                                ? _sortMode
                                : 'none',
                        decoration: InputDecoration(
                          labelText: context.t('urutkan'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'none',
                            child: Text(context.t('default')),
                          ),
                          DropdownMenuItem(
                            value: 'price_asc',
                            child: Text(context.t('Harga Terendah')),
                          ),
                          DropdownMenuItem(
                            value: 'price_desc',
                            child: Text(context.t('Harga Tertinggi')),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _sortMode = val ?? 'none';
                            _applyFilters();
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Grid
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 5.h),
                                child: Text(
                                  context.t('no_products'),
                                  style: TextStyle(fontSize: 12.sp * fontScale),
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = constraints.maxWidth < 600
                                    ? 2
                                    : constraints.maxWidth < 900
                                        ? 3
                                        : constraints.maxWidth < 1200
                                            ? 4
                                            : 5;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredProducts.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 2.w,
                                    crossAxisSpacing: 2.w,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemBuilder: (context, i) =>
                                      _buildProductCard(filteredProducts[i]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = products.map((p) => p.category).toSet().toList();
    // theme not needed here
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        children: [
          _buildCategoryChip("all", context.t('all')),
          ...cats.map((c) => _buildCategoryChip(c, translateCategory(c))),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final bool selected =
        _categoryFilter == value || (value == "all" && _categoryFilter == null);
    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Theme.of(context).cardColor,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          setState(() {
            if (value == "all") {
              _categoryFilter = null;
            } else {
              _categoryFilter = value;
            }
            _applyFilters();
          });
        },
      ),
    );
  }

  // >>> START OF MODIFIED _buildDrawer METHOD <<<
  Drawer _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header yang lebih kecil dan menarik (Small, appealing header)
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: 2.h, left: 3.w, bottom: 2.h),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 24, // Lebih kecil dari default UserAccountsDrawerHeader
                  backgroundColor: theme.cardColor,
                  backgroundImage: _buildProfileImage(),
                  child: _buildProfileImage() == null
                      ? Icon(Icons.person, size: 28, color: theme.primaryColor)
                      : null,
                ),
                SizedBox(width: 3.w),
                // Welcome Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // Menggunakan bodyLarge/titleMedium untuk ukuran font dashboard
                        context.t('welcome'),
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userName,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // >>> END OF MODIFIED _buildDrawer METHOD <<<
          ListTile(
            leading: Icon(Icons.home, color: theme.primaryColor),
            title: Text(context.t('home')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.primaryColor),
            title: Text(context.t('profile')),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.primaryColor),
            title: Text(context.t('settings')),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.primaryColor),
            title: const Text('Riwayat Pesanan'),
            onTap: () {
              Navigator.pop(context);
              context.go('/order-history');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.secondary),
            title: Text(
              context.t('logout'),
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/detail/${p.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  p.image,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: theme.hintColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                p.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Text(
                currencyFormat.format(p.price),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}