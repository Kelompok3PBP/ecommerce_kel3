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
  List<Product> _filteredProducts = [];
  String userName = "";
  String userEmail = "";
  String? _webBase64;

  String _selectedSort = 'default';
  String? _selectedCategoryFilter;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    context.read<ProductCubit>().fetchProducts();
  }

  ImageProvider? _buildProfileImage() {
    if (kIsWeb && _webBase64 != null) {
      try {
        return MemoryImage(base64Decode(_webBase64!));
      } catch (_) {
        return null;
      }
    }

    if (!kIsWeb && _webBase64 != null) {
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
    if (mounted) {
      setState(() {
        userName = prefs.getString('user_name') ?? widget.email.split('@')[0];
        userEmail = prefs.getString('user_email') ?? widget.email;
        _webBase64 = prefs.getString('profile_picture_base64');
      });
    }
  }

  void _searchProducts(String query) {
    final allProducts = context.read<ProductCubit>().state.products;
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = allProducts;
      } else {
        final searchQuery = query.toLowerCase();
        _filteredProducts = allProducts.where((p) {
          return p.title.toLowerCase().contains(searchQuery) ||
              translateCategory(p.category).toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  void _applySortAndFilter() {
    final allProducts = context.read<ProductCubit>().state.products;

    List<Product> filtered = allProducts;
    if (_selectedCategoryFilter != null &&
        _selectedCategoryFilter!.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => translateCategory(p.category) == _selectedCategoryFilter,
          )
          .toList();
    }

    if (_selectedSort == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
      await prefs.setBool('is_logged_in', false);
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      print("Error saat logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(context.t('dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final allProducts = context.read<ProductCubit>().state.products;
              final String? query = await showSearch<String?>(
                context: context,
                delegate: _ProductSearchDelegate(allProducts),
              );
              if (query != null) {
                _searchProducts(query);
              }
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                onPressed: () {
                  context.push('/cart');
                },
              ),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          '${state.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (!state.loading && state.error == null) {
            setState(() {
              _filteredProducts = state.products;
            });
          }
        },
        builder: (context, state) {
          if (state.loading && state.products.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state.error != null) {
            return Center(child: Text('${context.t('error')}: ${state.error}'));
          }

          return RefreshIndicator(
            color: Theme.of(context).primaryColor,
            onRefresh: () async {
              _searchProducts("");
              await context.read<ProductCubit>().fetchProducts();
            },
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedSort,
                            items: const [
                              DropdownMenuItem(
                                value: 'default',
                                child: Text('Default'),
                              ),
                              DropdownMenuItem(
                                value: 'price_asc',
                                child: Text('Harga: Termurah'),
                              ),
                              DropdownMenuItem(
                                value: 'price_desc',
                                child: Text('Harga: Termahal'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value!;
                              });
                              _applySortAndFilter();
                            },
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Kategori'),
                            value: _selectedCategoryFilter,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Semua Kategori'),
                              ),
                              ...context
                                  .read<ProductCubit>()
                                  .state
                                  .products
                                  .map((p) => translateCategory(p.category))
                                  .toSet()
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryFilter = (value == ''
                                    ? null
                                    : value);
                              });
                              _applySortAndFilter();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
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

                          return GridView.builder(
                            padding: EdgeInsets.all(3.w),
                            itemCount: _filteredProducts.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 3.w,
                                  mainAxisSpacing: 3.w,
                                  childAspectRatio: 0.6,
                                ),
                            itemBuilder: (context, index) {
                              return _buildProductCard(
                                _filteredProducts[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
              context.push('/profile').then((_) => _loadUserInfo());
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
              context.push('/settings');
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
        onTap: () {
          context.push('/detail/${p.id}');
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

class _ProductSearchDelegate extends SearchDelegate<String?> {
  final List<Product> products;
  _ProductSearchDelegate(this.products);

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
        hintStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color,
          fontSize: 16,
        ),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
      onPressed: () {
        query = '';
        showSuggestions(context);
      },
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
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
              fontSize: 15,
            ),
          ),
          onTap: () {
            query = results[index].title;
            close(context, query);
          },
        );
      },
    );
  }
}
