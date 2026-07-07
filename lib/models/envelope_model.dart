class EnvelopeModel {
  final String? id;
  final String userId;
  final String name;
  final int amount;
  final int spent;
  final String month;
  final String? categoryId;
  final String icon;
  final String color;
  final DateTime? createdAt;
  final String? categoryName;

  EnvelopeModel({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    this.spent = 0,
    required this.month,
    this.categoryId,
    this.icon = 'wallet',
    this.color = '#12B981',
    this.createdAt,
    this.categoryName,
  });

  int get remaining => amount - spent;
  double get progress => amount > 0 ? (spent / amount).clamp(0, 1) : 0.0;
  bool get isOverSpent => spent > amount;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'spent': spent,
      'month': month,
      'category_id': categoryId,
      'icon': icon,
      'color': color,
    };
  }

  factory EnvelopeModel.fromMap(Map<String, dynamic> map) {
    final cat = map['categories'] as Map<String, dynamic>?;
    return EnvelopeModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      amount: map['amount'] as int,
      spent: map['spent'] as int? ?? 0,
      month: map['month'] as String,
      categoryId: map['category_id'] as String?,
      icon: map['icon'] as String? ?? 'wallet',
      color: map['color'] as String? ?? '#12B981',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      categoryName: cat?['name'] as String?,
    );
  }
}
