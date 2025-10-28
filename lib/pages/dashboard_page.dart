import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart.dart';
import '../model/product.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'detail_page.dart';
import 'cart_page.dart'; // ✅ Tambahkan ini
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  const DashboardPage({super.key, required this.email});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = ApiService();

  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = "";

  String userName = "";
  String userEmail = "";

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchProducts();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? widget.email.split('@')[0];
      userEmail = prefs.getString('user_email') ?? widget.email;
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final productList = await _apiService.getProducts();
      setState(() {
        products = productList
            .map<Product>((json) => Product.fromJson(json))
            .toList();
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() => isLoading = false);
    }
  }

  void _searchProducts(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredProducts = products.where((p) {
        final title = p.title.toLowerCase();
        final category = p.category.toLowerCase();
        return title.contains(searchQuery) || category.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: _ProductSearchDelegate(
                  products: products,
                  onSearch: _searchProducts,
                ),
              );
              if (result != null && result.isNotEmpty) {
                _searchProducts(result);
              }
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // ✅ Sekarang tombol keranjang bisa dipencet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartPage()),
                  );
                },
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.items.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
          ? const Center(child: Text('Produk tidak ditemukan'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                return _buildProductCard(p, cart);
              },
            ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.purple),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.purple, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(name: userName, email: userEmail),
                ),
              ).then((_) => _loadUserInfo());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product p, CartModel cart) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(product: p)),
        );
      },
      child: GFCard(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        imageOverlay: Image.network(p.image, fit: BoxFit.cover).image,
        title: GFListTile(
          avatar: CircleAvatar(backgroundImage: NetworkImage(p.image)),
          titleText: p.title,
          subTitleText: p.category,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              currencyFormat.format(p.price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        buttonBar: GFButtonBar(
          children: [
            GFButton(
              onPressed: () {
                cart.add(p);
                GFToast.showToast(
                  "${p.title} ditambahkan ke keranjang",
                  context,
                  toastDuration: 3,
                  backgroundColor: GFColors.SUCCESS,
                  textStyle: const TextStyle(color: Colors.white),
                );
              },
              text: "Tambah",
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 18,
              ),
              color: GFColors.SUCCESS,
              size: GFSize.MEDIUM,
              shape: GFButtonShape.pills,
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

  _ProductSearchDelegate({required this.products, required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
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
      final title = p.title.toLowerCase();
      final category = p.category.toLowerCase();
      return title.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final p = results[index];
        return ListTile(
          title: Text(p.title),
          subtitle: Text(p.category),
          onTap: () {
            onSearch(p.title);
            close(context, p.title);
          },
        );
      },
    );
  }
}
