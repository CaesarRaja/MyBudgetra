class BudgetModel {
  final String? id;
  final String userId;
  final String categoryId;
  final int amount;
  final String month;
  final DateTime? createdAt;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  BudgetModel({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.month,
    this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    final cat = map['categories'] as Map<String, dynamic>?;
    return BudgetModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      amount: map['amount'] as int,
      month: map['month'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      categoryName: cat?['name'] as String?,
      categoryIcon: cat?['icon'] as String?,
      categoryColor: cat?['color'] as String?,
    );
  }
}
