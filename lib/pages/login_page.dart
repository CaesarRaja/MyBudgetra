import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase.dart';
import '../config/theme.dart';
import 'signup_page.dart';
import 'main_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    if (SupabaseConfig.client.auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await SupabaseConfig.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: BudgetraColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetraColors.darkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: BudgetraColors.darkCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: BudgetraColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'MyBudgetra',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: BudgetraColors.primary,
                    letterSpacing: -0.03,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Please enter your details.',
                  style: GoogleFonts.inter(
                    color: BudgetraColors.darkMutedFg,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BudgetraColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: BudgetraColors.darkFg),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: BudgetraColors.darkMutedFg),
                          prefixIcon: const Icon(Icons.mail, color: BudgetraColors.darkMutedFg),
                          filled: true,
                          fillColor: BudgetraColors.darkSurfaceLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: BudgetraColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: BudgetraColors.darkFg),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: BudgetraColors.darkMutedFg),
                          prefixIcon: const Icon(Icons.lock, color: BudgetraColors.darkMutedFg),
                          filled: true,
                          fillColor: BudgetraColors.darkSurfaceLow,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: BudgetraColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: BudgetraColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BudgetraColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: BudgetraColors.darkMutedFg),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: BudgetraColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
