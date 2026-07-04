import '../config/supabase.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final _client = SupabaseConfig.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<DebtModel>> getDebts() async {
    final data = await _client
        .from('debts')
        .select()
        .eq('user_id', _userId)
        .order('due_date', ascending: true)
        .order('created_at', ascending: false);
    return (data as List).map((e) => DebtModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    await _client.from('debts').insert(debt.toMap());
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _client.from('debts').update(debt.toMap()).eq('id', debt.id!);
  }

  Future<void> payDebt(String id, int amount) async {
    final debt = await _client.from('debts').select('paid_amount, amount').eq('id', id).single();
    final currentPaid = (debt['paid_amount'] as int? ?? 0);
    final total = debt['amount'] as int;
    final newPaid = currentPaid + amount;
    final isFull = newPaid >= total;
    await _client.from('debts').update({
      'paid_amount': newPaid,
      if (isFull) 'status': 'paid',
    }).eq('id', id);
  }

  Future<void> deleteDebt(String id) async {
    await _client.from('debts').delete().eq('id', id);
  }
}
