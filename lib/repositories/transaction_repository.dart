import 'package:intl/intl.dart';
import '../config/supabase.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class TransactionRepository {
  final _client = SupabaseConfig.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<CategoryModel>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('name');
    return (data as List).map((e) => CategoryModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<TransactionModel>> getTransactions({int? limit, int? month, int? year}) async {
    var query = _client
        .from('transactions')
        .select('*, categories(name)')
        .eq('user_id', _userId);

    if (month != null && year != null) {
      final start = DateTime(year, month, 1).toIso8601String().split('T')[0];
      final end = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];
      query = query.gte('date', start).lte('date', end);
    }

    var ordered = query.order('date', ascending: false).order('created_at', ascending: false);
    if (limit != null) ordered = ordered.limit(limit);

    final data = await ordered;
    return (data as List).map((e) => TransactionModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from('transactions').insert(transaction.toMap());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _client.from('transactions').update(transaction.toMap()).eq('id', transaction.id!);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> getDailySummary() async {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    final thirtyDaysAgo = today.subtract(const Duration(days: 30)).toIso8601String().split('T')[0];

    final todayData = await _client
        .from('transactions')
        .select('amount, type')
        .eq('user_id', _userId)
        .eq('date', todayStr);

    final monthlyData = await _client
        .from('transactions')
        .select('amount, type')
        .eq('user_id', _userId)
        .gte('date', thirtyDaysAgo)
        .lte('date', todayStr);

    int todayIncome = 0, todayExpense = 0;
    for (final t in todayData as List) {
      final m = t as Map;
      if (m['type'] == 'income') {
        todayIncome += (m['amount'] as int).abs();
      } else {
        todayExpense += (m['amount'] as int).abs();
      }
    }

    int monthlyTotal = 0, monthlyCount = 0;
    for (final t in monthlyData as List) {
      final m = t as Map;
      if (m['type'] == 'expense') {
        monthlyTotal += (m['amount'] as int).abs();
        monthlyCount++;
      }
    }

    final avg = monthlyCount > 0 ? monthlyTotal / monthlyCount : 0.0;

    return {
      'todayIncome': todayIncome,
      'todayExpense': todayExpense,
      'monthlyAvg': avg,
      'todayBalance': todayIncome - todayExpense,
    };
  }

  Future<Map<String, dynamic>> getMonthlyReport() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    final nextMonth = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];

    final data = await _client
        .from('transactions')
        .select('amount, type, category_id, date, categories(name)')
        .eq('user_id', _userId)
        .gte('date', monthStart)
        .lte('date', nextMonth);

    int income = 0, expense = 0;
    final Map<String, int> categoryExpense = {};
    int minDailyExpense = -1;
    String? minDay;
    final Map<String, int> dailyExpense = {};

    for (final t in data as List) {
      final m = t as Map;
      final amount = (m['amount'] as int).abs();
      if (m['type'] == 'income') {
        income += amount;
      } else {
        expense += amount;
        final catName = (m['categories'] as Map?)?['name'] as String? ?? 'Lainnya';
        categoryExpense[catName] = (categoryExpense[catName] ?? 0) + amount;
        final day = (m['date'] as String).substring(8);
        dailyExpense[day] = (dailyExpense[day] ?? 0) + amount;
      }
    }

    for (final entry in dailyExpense.entries) {
      if (minDailyExpense == -1 || entry.value < minDailyExpense) {
        minDailyExpense = entry.value;
        minDay = entry.key;
      }
    }

    final sortedCats = categoryExpense.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topCat = sortedCats.isNotEmpty ? sortedCats.first.key : '-';
    final topCatPct = expense > 0 && sortedCats.isNotEmpty ? (sortedCats.first.value / expense * 100).round() : 0;

    final dayNames = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final minDayName = minDay != null
        ? dayNames[DateTime(now.year, now.month, int.parse(minDay)).weekday % 7]
        : '-';

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'savingsRate': income > 0 ? ((income - expense) / income * 100).round() : 0,
      'topCategory': topCat,
      'topCategoryPct': topCatPct,
      'frugalDay': minDayName,
      'frugalAmount': minDailyExpense < 0 ? 0 : minDailyExpense,
      'categoryExpense': categoryExpense,
    };
  }

  Future<List<Map<String, dynamic>>> getMonthlyHistory({int months = 6}) async {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final start = date.toIso8601String().split('T')[0];
      final end = DateTime(date.year, date.month + 1, 0).toIso8601String().split('T')[0];
      final label = DateFormat('MMM', 'id').format(date);

      final data = await _client
          .from('transactions')
          .select('amount, type')
          .eq('user_id', _userId)
          .gte('date', start)
          .lte('date', end);

      int income = 0, expense = 0;
      for (final t in data as List) {
        final m = t as Map;
        final amount = (m['amount'] as int).abs();
        if (m['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      results.add({'label': label, 'income': income, 'expense': expense});
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getWeeklyExpense({int days = 7}) async {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];
    final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final dayLabel = dayNames[date.weekday % 7];

      final data = await _client
          .from('transactions')
          .select('amount')
          .eq('user_id', _userId)
          .eq('type', 'expense')
          .eq('date', dateStr);

      int total = 0;
      for (final t in data as List) {
        total += (t['amount'] as int).abs();
      }

      results.add({'label': dayLabel, 'amount': total});
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> getExpenseByCategory({int? month, int? year}) async {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;
    final start = DateTime(y, m, 1).toIso8601String().split('T')[0];
    final end = DateTime(y, m + 1, 0).toIso8601String().split('T')[0];

    final data = await _client
        .from('transactions')
        .select('amount, category_id, categories(name)')
        .eq('user_id', _userId)
        .eq('type', 'expense')
        .gte('date', start)
        .lte('date', end);

    final Map<String, int> catMap = {};
    for (final t in data as List) {
      final m2 = t as Map;
      final name = (m2['categories'] as Map?)?['name'] as String? ?? 'Lainnya';
      catMap[name] = (catMap[name] ?? 0) + (m2['amount'] as int).abs();
    }

    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => {'name': e.key, 'amount': e.value}).toList();
  }

  Future<void> addCategory(String name, String icon, String color, String type) async {
    await _client.from('categories').insert({
      'user_id': _userId,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'is_default': false,
    });
  }

  Future<void> updateCategory(String id, String name, String icon, String color) async {
    await _client.from('categories').update({'name': name, 'icon': icon, 'color': color}).eq('id', id);
  }

  Future<bool> deleteCategory(String id) async {
    final refs = await _client.from('transactions').select('id').eq('category_id', id).limit(1);
    if ((refs as List).isNotEmpty) return false;
    await _client.from('categories').delete().eq('id', id);
    return true;
  }
}
