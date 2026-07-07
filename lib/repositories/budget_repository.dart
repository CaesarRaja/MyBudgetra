import '../config/supabase.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _client = SupabaseConfig.client;

  String get _userId => _client.auth.currentUser!.id;

  String get _currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<List<BudgetModel>> getBudgets({String? month}) async {
    final m = month ?? _currentMonth;
    final data = await _client
        .from('budgets')
        .select('*, categories(name, icon, color)')
        .eq('user_id', _userId)
        .eq('month', m);
    return (data as List).map((e) => BudgetModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> upsertBudget(String categoryId, int amount, {String? month}) async {
    final m = month ?? _currentMonth;
    final existing = await _client
        .from('budgets')
        .select('id')
        .eq('user_id', _userId)
        .eq('category_id', categoryId)
        .eq('month', m)
        .maybeSingle();

    final data = {
      'user_id': _userId,
      'category_id': categoryId,
      'amount': amount,
      'month': m,
    };

    if (existing != null) {
      await _client.from('budgets').update(data).eq('id', existing['id'] as String);
    } else {
      await _client.from('budgets').insert(data);
    }
  }

  Future<Map<String, int>> getRealisasi({String? month}) async {
    final m = month ?? _currentMonth;
    final year = int.parse(m.split('-')[0]);
    final monthNum = int.parse(m.split('-')[1]);
    final start = DateTime(year, monthNum, 1).toIso8601String().split('T')[0];
    final end = DateTime(year, monthNum + 1, 0).toIso8601String().split('T')[0];

    final data = await _client
        .from('transactions')
        .select('category_id, amount')
        .eq('user_id', _userId)
        .eq('type', 'expense')
        .gte('date', start)
        .lte('date', end);

    final Map<String, int> result = {};
    for (final t in data as List) {
      final m = t as Map;
      final catId = m['category_id'] as String;
      result[catId] = (result[catId] ?? 0) + (m['amount'] as int);
    }
    return result;
  }
}
