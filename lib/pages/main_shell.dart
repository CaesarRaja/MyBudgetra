import 'package:flutter/material.dart';
import '../config/supabase.dart';
import '../config/theme.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/bottom_nav.dart';
import 'home_page.dart';
import 'transaction_page.dart';
import 'budget_page.dart';
import 'debt_page.dart';
import 'report_page.dart';
import 'login_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _homeKey = GlobalKey<HomePageState>();

  @override
  void initState() {
    super.initState();
    _seedCategories();
  }

  Future<void> _seedCategories() async {
    try {
      await TransactionRepository().seedDefaultCategories();
    } catch (_) {}
  }

  void _onTransactionAdded() {
    _homeKey.currentState?.refresh();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: BudgetraColors.error))),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseConfig.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final initials = (user?.email?[0] ?? 'U').toUpperCase();

    return Scaffold(
      backgroundColor: BudgetraColors.lightBg,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40, height: 40,
              decoration: BoxDecoration(color: BudgetraColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(initials, style: const TextStyle(color: BudgetraColors.primaryStrong, fontWeight: FontWeight.w700, fontSize: 14))),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(key: _homeKey),
          TransactionPage(onTransactionAdded: _onTransactionAdded),
          const BudgetPage(),
          const DebtPage(),
          const ReportPage(),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 0) _homeKey.currentState?.refresh();
        },
      ),
    );
  }
}
