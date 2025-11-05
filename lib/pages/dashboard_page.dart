// pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/product_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';
import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardPage extends StatefulWidget {
  final String email;
  const DashboardPage({super.key, required this.email});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String userName = "";
  String userEmail = "";
  String? _imagePath;
  String? _webBase64;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    // fetching handled by ProductCubit which is created in main
  }

  ImageProvider? _buildProfileImage() {
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }

    if (_imagePath != null && File(_imagePath!).existsSync()) {
      return FileImage(File(_imagePath!));
    }

    return null;
  }

  String translateCategory(String category) {
    switch (category.toLowerCase()) {
      case "electronics":
        return "Elektronik";
      case "jewelery":
        return "Perhiasan";
      case "men's clothing":
        return "Pakaian Pria";
      case "women's clothing":
        return "Pakaian Wanita";
      default:
        return category;
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? widget.email.split('@')[0];
      userEmail = prefs.getString('user_email') ?? widget.email;
      _imagePath = prefs.getString('profile_picture_path');
      _webBase64 = prefs.getString('profile_picture_base64');
    });
  }

  void _searchProducts(String query) {
    setState(() {
      final searchQuery = query.toLowerCase();
      filteredProducts = products.where((p) {
        return p.title.toLowerCase().contains(searchQuery) ||
            translateCategory(p.category).toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data user biar bersih

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(products, _searchProducts),
              );
            },
          ),

          // 🌟 Tambahkan Icon Keranjang (dengan badge jumlah item)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 6,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // 🌙 Tombol mode gelap / terang
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
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

          if (products.isEmpty) {
            products = state.products;
            filteredProducts = products;
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async => context.read<ProductCubit>().fetchProducts(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(filteredProducts[index]);
              },
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
            title: Text("Home", style: theme.textTheme.bodyLarge),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.person, color: theme.primaryColor),
            title: Text("Profile", style: theme.textTheme.bodyLarge),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              _loadUserInfo();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.primaryColor),
            title: Text("Settings", style: theme.textTheme.bodyLarge),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.secondary),
            title: Text(
              "Logout",
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
        onTap: () {
          // Arahkan ke halaman detail produk (tidak otomatis menambahkan ke keranjang)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPage(product: p)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  p.image,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.image,
                    size: 80,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                p.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 4,
                bottom: 8,
              ),
              child: Text(
                currencyFormat.format(p.price),
                style: TextStyle(
                  fontSize: 14,
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

class _ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  final Function(String) onSearch;
  _ProductSearchDelegate(this.products, this.onSearch);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = products.where((p) {
      final q = query.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            results[index].title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          onTap: () {
            query = results[index].title;
            showResults(context);
          },
        );
      },
    );
  }
}
