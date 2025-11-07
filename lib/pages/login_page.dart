import 'package:flutter/material.dart'; // <--- FIKS
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

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
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();

    if (email == 'admin' && password == 'admin') {
      const adminEmail = 'admin@mail.com';
      await prefs.setString('current_user', adminEmail);
      await prefs.setString('user_name', 'Admin');
      await prefs.setString('user_email', adminEmail);
      await prefs.setBool('is_logged_in', true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(email: adminEmail)),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final registeredUsers = prefs.getStringList('registered_users') ?? [];
      bool isAuthenticated = false;
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
        await prefs.setBool('is_logged_in', true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage(email: email)),
        );
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

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final email = prefs.getString('user_email') ?? '';
    if (isLoggedIn && email.isNotEmpty) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage(email: email)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: SizedBox( // <-- PERBAIKAN ADAPTIF
            width: 450, 
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        height: 18.h,
                        width: 18.h,
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.shopping_bag,
                            size: 25.w,
                            color: theme.colorScheme.primary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "Selamat Datang di belanja.in",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email atau Username',
                          prefixIcon: Icon(Icons.person,
                              color: theme.colorScheme.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field ini tidak boleh kosong';
                          }
                          if (value != 'admin' &&
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon:
                              Icon(Icons.lock, color: theme.colorScheme.primary),
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
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Belum punya akun? ",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 11.sp),
                            children: [
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 11.sp
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
      ),
    );
  }
}