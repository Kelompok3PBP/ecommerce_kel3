import 'package:flutter/material.dart'; // <--- FIKS
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/product_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';
// import 'dart:io' show File; <-- HAPUS (FIKS Web Error)
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
  // String? _imagePath; <-- HAPUS (FIKS Web Error)
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
  }

  ImageProvider? _buildProfileImage() {
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }
    // if (_imagePath != null && File(_imagePath!).existsSync()) { // <-- HAPUS (FIKS Web Error)
    //   return FileImage(File(_imagePath!));
    // }
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
      // _imagePath = prefs.getString('profile_picture_path'); <-- HAPUS (FIKS Web Error)
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
    print("--- TOMBOL LOGOUT DITEKAN ---");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("--- SharedPreferences DIBERSIHKAN ---");
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        print("--- NAVIGASI KE /login ---");
      }
    } catch (e) {
      print("--- !!! ERROR SAAT LOGOUT: $e ---");
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
                      padding: EdgeInsets.all(1.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${state.items.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
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
            
            child: Center( // <-- PERBAIKAN ADAPTIF
              child: ConstrainedBox( // <-- PERBAIKAN ADAPTIF
                constraints: const BoxConstraints(
                  maxWidth: 1400, // <-- Batasi lebar grid
                ),
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

                    return GridView.builder(
                      padding: EdgeInsets.all(3.w),
                      itemCount: filteredProducts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 3.w,
                        mainAxisSpacing: 3.w,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (context, index) {
                        return _buildProductCard(filteredProducts[index]);
                      },
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
                  ? Icon(Icons.person,
                      size: 30.sp, // <-- PERBAIKAN .dp KE .sp
                      color: theme.primaryColor)
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
                  fontSize: 10.sp,
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
                  fontSize: 12.sp,
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
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13.sp),
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
              fontSize: 12.sp,
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