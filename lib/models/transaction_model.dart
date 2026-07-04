class TransactionModel {
  final String? id;
  final String userId;
  final String? categoryId;
  final String? categoryName;
  final int amount;
  final String description;
  final String type; // expense / income
  final DateTime date;
  final String? merchant;
  final bool isRecurring;
  final DateTime? createdAt;

  TransactionModel({
    this.id,
    required this.userId,
    this.categoryId,
    this.categoryName,
    required this.amount,
    required this.description,
    this.type = 'expense',
    required this.date,
    this.merchant,
    this.isRecurring = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'description': description,
      'type': type,
      'date': date.toIso8601String().split('T')[0],
      'merchant': merchant,
      'is_recurring': isRecurring,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: map['categories'] != null
          ? (map['categories'] as Map)['name'] as String?
          : null,
      amount: map['amount'] as int,
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'expense',
      date: DateTime.parse(map['date'] as String),
      merchant: map['merchant'] as String?,
      isRecurring: map['is_recurring'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  String get formattedAmount {
    final n = amount.abs();
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(1)} M';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)} jt';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)} rb';
    return n.toString();
  }

  bool get isExpense => type == 'expense';
}
