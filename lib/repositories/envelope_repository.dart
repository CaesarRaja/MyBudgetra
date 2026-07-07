import '../config/supabase.dart';
import '../models/envelope_model.dart';

class EnvelopeRepository {
  final _client = SupabaseConfig.client;

  String get _userId => _client.auth.currentUser!.id;

  String get _currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<List<EnvelopeModel>> getEnvelopes({String? month}) async {
    final m = month ?? _currentMonth;
    final data = await _client
        .from('envelopes')
        .select('*, categories(name)')
        .eq('user_id', _userId)
        .eq('month', m)
        .order('created_at');
    return (data as List).map((e) => EnvelopeModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<EnvelopeModel> createEnvelope(String name, int amount, {String? categoryId, String icon = 'wallet', String color = '#12B981'}) async {
    final data = {
      'user_id': _userId,
      'name': name,
      'amount': amount,
      'month': _currentMonth,
      'category_id': categoryId,
      'icon': icon,
      'color': color,
    };
    final res = await _client.from('envelopes').insert(data).select('*, categories(name)').single();
    return EnvelopeModel.fromMap(res);
  }

  Future<void> updateEnvelope(String id, {String? name, int? amount, String? icon, String? color, String? categoryId}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (amount != null) data['amount'] = amount;
    if (icon != null) data['icon'] = icon;
    if (color != null) data['color'] = color;
    if (categoryId != null) data['category_id'] = categoryId;
    if (data.isEmpty) return;
    await _client.from('envelopes').update(data).eq('id', id);
  }

  Future<void> deleteEnvelope(String id) async {
    await _client.from('envelopes').delete().eq('id', id);
  }

  Future<void> recalculateSpent(String month) async {
    final envelopes = await getEnvelopes(month: month);
    for (final e in envelopes) {
      if (e.categoryId == null) continue;
      final m = month.split('-');
      final year = int.parse(m[0]);
      final monthNum = int.parse(m[1]);
      final start = DateTime(year, monthNum, 1).toIso8601String().split('T')[0];
      final end = DateTime(year, monthNum + 1, 0).toIso8601String().split('T')[0];

      final data = await _client
          .from('transactions')
          .select('amount')
          .eq('user_id', _userId)
          .eq('type', 'expense')
          .eq('category_id', e.categoryId!)
          .gte('date', start)
          .lte('date', end);

      int total = 0;
      for (final t in data as List) {
        total += (t['amount'] as int).abs();
      }

      await _client.from('envelopes').update({'spent': total}).eq('id', e.id!);
    }
  }

  Future<void> markUsage(String id, int amount, {String? note}) async {
    final env = await _client.from('envelopes').select('spent').eq('id', id).single();
    final currentSpent = (env['spent'] as int? ?? 0) + amount;
    await _client.from('envelopes').update({'spent': currentSpent}).eq('id', id);
    if (note != null) {
      await _client.from('envelope_logs').insert({
        'envelope_id': id,
        'amount': amount,
        'note': note,
      });
    }
  }
}
