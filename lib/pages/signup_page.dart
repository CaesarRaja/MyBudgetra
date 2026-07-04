import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/supabase.dart';
import '../config/theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _signup() async {
    setState(() => _loading = true);
    try {
      await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': _nameController.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor: BudgetraColors.success,
          ),
        );
        Navigator.pop(context);
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetraColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BudgetraColors.darkFg),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: BudgetraColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: BudgetraColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: BudgetraColors.darkFg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start managing your wealth.',
                  style: GoogleFonts.inter(
                    color: BudgetraColors.darkMutedFg,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),
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
                        controller: _nameController,
                        style: const TextStyle(color: BudgetraColors.darkFg),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: BudgetraColors.darkMutedFg),
                          prefixIcon: const Icon(Icons.person, color: BudgetraColors.darkMutedFg),
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
                        controller: _emailController,
                        style: const TextStyle(color: BudgetraColors.darkFg),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
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
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: BudgetraColors.darkFg),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: BudgetraColors.darkMutedFg),
                          prefixIcon: const Icon(Icons.lock, color: BudgetraColors.darkMutedFg),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: BudgetraColors.darkMutedFg,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
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
                              : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                      'Already have an account? ',
                      style: TextStyle(color: BudgetraColors.darkMutedFg),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
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
