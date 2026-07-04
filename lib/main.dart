import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/supabase.dart';
import 'config/theme.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await initializeDateFormatting('id');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyBudgetra',
      debugShowCheckedModeBanner: false,
      theme: budgetraTheme(),
      home: const LoginPage(),
    );
  }
}
