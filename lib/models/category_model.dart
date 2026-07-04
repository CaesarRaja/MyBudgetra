class CategoryModel {
  final String id;
  final String? userId;
  final String name;
  final String? icon;
  final String? color;
  final String type;
  final bool isDefault;

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    this.icon,
    this.color,
    this.type = 'expense',
    this.isDefault = false,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      type: map['type'] as String? ?? 'expense',
      isDefault: map['is_default'] as bool? ?? false,
    );
  }
}
