// pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'theme_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text;

    // ▼▼▼ BAGIAN YANG DIUBAH: LOGIKA ADMIN TANPA PASSWORD ▼▼▼
    // Langsung cek apakah input adalah 'admin'.
    // Jika ya, langsung login tanpa validasi form atau password.
    if (email == 'admin') {
      final prefs = await SharedPreferences.getInstance();
      const adminEmail = 'admin@mail.com'; // Email default untuk sesi admin

      await prefs.setString('current_user', adminEmail);
      await prefs.setString(
        'user_name',
        'admin',
      ); // Tampilkan 'admin' sebagai nama
      await prefs.setString('user_email', adminEmail);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(email: adminEmail),
          ),
        );
      }
      return; // Penting: Hentikan eksekusi fungsi di sini agar tidak lanjut ke validasi user biasa.
    }
    // ▲▲▲ BATAS PERUBAHAN ▲▲▲

    // --- Logika untuk Pengguna Biasa (tetap sama) ---
    // Kode di bawah ini hanya akan berjalan jika email yang dimasukkan BUKAN 'admin'.
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final password = _passwordController.text;
      bool isAuthenticated = false;

      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      for (var user in registeredUsers) {
        final parts = user.split(':');
        if (parts.length == 2 && parts[0] == email && parts[1] == password) {
          isAuthenticated = true;
          break;
        }
      }

      if (isAuthenticated) {
        await prefs.setString('current_user', email);
        await prefs.setString('user_name', email.split('@')[0]);
        await prefs.setString('user_email', email);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(email: email),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email atau password salah!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      height: 120,
                      width: 120,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.shopping_bag,
                        size: 100,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Selamat Datang di belanja.in",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email atau Username',
                        prefixIcon: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Field ini tidak boleh kosong';
                        }
                        // Jika input BUKAN 'admin', maka validasi sebagai email
                        if (value != 'admin' &&
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Masukkan email yang valid';
                        }
                        return null; // Lolos validasi
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password', // Hint diubah
                        prefixIcon: Icon(
                          Icons.lock,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        // Validasi password ini sekarang hanya berlaku untuk user biasa,
                        // karena admin sudah ditangani di awal fungsi _login.
                        if (_emailController.text != 'admin' &&
                            (value == null || value.isEmpty)) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: theme.elevatedButtonTheme.style?.copyWith(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Belum punya akun? ",
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: "Register",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
