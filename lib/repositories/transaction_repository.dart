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
        .or('user_id.eq.$_userId,is_default.eq.true')
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
        todayIncome += m['amount'] as int;
      } else {
        todayExpense += m['amount'] as int;
      }
    }

    int monthlyTotal = 0, monthlyCount = 0;
    for (final t in monthlyData as List) {
      final m = t as Map;
      if (m['type'] == 'expense') {
        monthlyTotal += m['amount'] as int;
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

  Future<void> seedDefaultCategories() async {
    await _client
        .from('categories')
        .delete()
        .eq('is_default', true)
        .eq('user_id', _userId);
      final defaults = [
        // Pengeluaran (18)
        {'name': 'Makan & Minum', 'icon': 'restaurant', 'color': '#12B981', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Transportasi', 'icon': 'car', 'color': '#3B82F6', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Tagihan', 'icon': 'receipt', 'color': '#F59E0B', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Belanja', 'icon': 'bag', 'color': '#EF4444', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Hiburan', 'icon': 'gamepad', 'color': '#8B5CF6', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Kesehatan', 'icon': 'heart', 'color': '#EC4899', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Pendidikan', 'icon': 'school', 'color': '#06B6D4', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Kebutuhan Rumah', 'icon': 'home', 'color': '#14B8A6', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Internet & Pulsa', 'icon': 'wifi', 'color': '#0EA5E9', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Paket Langganan', 'icon': 'subscriptions', 'color': '#F43F5E', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Asuransi', 'icon': 'health_and_safety', 'color': '#EC4899', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Donasi & Zakat', 'icon': 'volunteer_activism', 'color': '#F97316', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Pakaian', 'icon': 'checkroom', 'color': '#A855F7', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Perawatan Diri', 'icon': 'spa', 'color': '#F472B6', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Olahraga', 'icon': 'fitness_center', 'color': '#22C55E', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Liburan & Travel', 'icon': 'flight', 'color': '#06B6D4', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Hewan Peliharaan', 'icon': 'pets', 'color': '#FB923C', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        {'name': 'Lainnya', 'icon': 'more_horiz', 'color': '#94A3B8', 'type': 'expense', 'is_default': true, 'user_id': _userId},
        // Pemasukan (7)
        {'name': 'Gaji', 'icon': 'account_balance_wallet', 'color': '#12B981', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Freelance', 'icon': 'laptop', 'color': '#F97316', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Investasi', 'icon': 'trending_up', 'color': '#06B6D4', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Bonus & THR', 'icon': 'card_giftcard', 'color': '#EF4444', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Bisnis', 'icon': 'analytics', 'color': '#6366F1', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Hadiah', 'icon': 'redeem', 'color': '#EC4899', 'type': 'income', 'is_default': true, 'user_id': _userId},
        {'name': 'Pendapatan Lain', 'icon': 'attach_money', 'color': '#94A3B8', 'type': 'income', 'is_default': true, 'user_id': _userId},
      ];
      await _client.from('categories').insert(defaults);
  }
}
