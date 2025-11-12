import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:go_router/go_router.dart';
import 'theme_page.dart';
import '../services/localization_extension.dart';

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
      context.go('/dashboard', extra: adminEmail);
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
          SnackBar(
            content: Text(context.t('login_success')),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard', extra: email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('login_failed')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: SizedBox(
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
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        context.t('welcome') + ' ' + context.t('login_title'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: context.t('email'),
                          prefixIcon: Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.t('email_empty');
                          }
                          if (value != 'admin' &&
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return context.t('email_invalid');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: context.t('password'),
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
                          if (value == null || value.isEmpty) {
                            return context.t('password_empty');
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
                            context.t('login_button'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      GestureDetector(
                        onTap: () {
                          context.push('/register');
                        },
                        child: Text.rich(
                          TextSpan(
                            text: context.t('no_account') + ' ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: context.t('register'),
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
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
