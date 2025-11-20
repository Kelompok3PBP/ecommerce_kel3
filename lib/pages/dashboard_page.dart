import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../bloc/cart_cubit.dart';
import '../bloc/product_cubit.dart';
import '../model/product.dart';
import 'theme_provider.dart';
import '../services/localization_extension.dart';

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

    // Apply category filter (strict match)
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      result = result.where(
        (p) => p.category.toLowerCase() == _categoryFilter!.toLowerCase(),
      );
    }

    // Apply search: if a category is active, search only in title (so empty result may show), otherwise search title + translated category
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

    // Apply sorting
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

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(context.t('dashboard')),
        actions: [
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
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${state.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
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
          if (state.loading)
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          if (state.error != null)
            return Center(child: Text('Error: ${state.error}'));

          products = state.products;
          _applyFilters();

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              _searchProducts("");
              await context.read<ProductCubit>().fetchProducts();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 6;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 4;
                    } else {
                      crossAxisCount = 3;
                    }

                    final cats = products
                        .map((p) => p.category)
                        .toSet()
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 2.w,
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
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _searchProducts('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              isDense: true,
                            ),
                            onChanged: (v) => _searchProducts(v),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.w,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value:
                                      (_sortMode == 'price_asc' ||
                                          _sortMode == 'price_desc')
                                      ? _sortMode
                                      : 'none',
                                  decoration: InputDecoration(
                                    labelText: context.t('urutkan'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    isDense: true,
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
                                      if (val == 'none') {
                                        _sortMode = 'none';
                                        _categoryFilter = null;
                                      } else {
                                        _sortMode = val ?? 'none';
                                        _categoryFilter = null;
                                      }
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _categoryFilter ?? 'all',
                                  decoration: InputDecoration(
                                    labelText: context.t('kategori'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    isDense: true,
                                  ),
                                  items:
                                      [
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text(context.t('default')),
                                        ),
                                      ] +
                                      cats
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(translateCategory(c)),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == null || val == 'all') {
                                        _categoryFilter = null;
                                        _sortMode = 'none';
                                      } else {
                                        _categoryFilter = val;
                                        _sortMode = 'category';
                                      }
                                      _applyFilters();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 1.h),

                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Center(child: Text(context.t('no_products')))
                              : GridView.builder(
                                  padding: EdgeInsets.all(3.w),
                                  itemCount: filteredProducts.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 3.w,
                                        mainAxisSpacing: 3.w,
                                        childAspectRatio: 0.6,
                                      ),
                                  itemBuilder: (context, index) {
                                    return _buildProductCard(
                                      filteredProducts[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.cardColor,
              backgroundImage: _buildProfileImage(),
              child: _buildProfileImage() == null
                  ? Icon(Icons.person, size: 40, color: theme.primaryColor)
                  : null,
            ),
            decoration: BoxDecoration(color: theme.primaryColor),
          ),
          ListTile(
            leading: Icon(Icons.home, color: theme.primaryColor),
            title: Text(context.t('home'), style: theme.textTheme.bodyLarge),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.primaryColor),
            title: Text(context.t('profile'), style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.primaryColor),
            title: Text(
              context.t('settings'),
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.secondary),
            title: Text(
              context.t('logout'),
              style: theme.textTheme.bodyLarge?.copyWith(
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/detail/${p.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Image.network(
                  p.image,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.image,
                    size: 20.w,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w),
              child: Text(
                p.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 2.5.w,
                right: 2.5.w,
                top: 0.5.h,
                bottom: 1.h,
              ),
              child: Text(
                currencyFormat.format(p.price),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
