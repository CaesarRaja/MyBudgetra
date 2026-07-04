class DebtModel {
  final String? id;
  final String userId;
  final String debtorName;
  final int amount;
  final int paidAmount;
  final String? description;
  final DateTime dueDate;
  final String status; // active / overdue / paid
  final bool reminderSent;
  final DateTime? createdAt;

  DebtModel({
    this.id,
    required this.userId,
    required this.debtorName,
    required this.amount,
    this.paidAmount = 0,
    this.description,
    required this.dueDate,
    this.status = 'active',
    this.reminderSent = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'debtor_name': debtorName,
      'amount': amount,
      'paid_amount': paidAmount,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'status': status,
      'reminder_sent': reminderSent,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      debtorName: map['debtor_name'] as String,
      amount: map['amount'] as int,
      paidAmount: map['paid_amount'] as int? ?? 0,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['due_date'] as String),
      status: map['status'] as String? ?? 'active',
      reminderSent: map['reminder_sent'] as bool? ?? false,
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

  int get remainingAmount => amount - paidAmount;
  double get progress => amount > 0 ? paidAmount / amount : 0.0;
  bool get isFullyPaid => paidAmount >= amount;

  int get daysOverdue {
    if (isFullyPaid) return 0;
    final diff = DateTime.now().difference(dueDate).inDays;
    return diff > 0 ? diff : 0;
  }

  bool get isOverdue => !isFullyPaid && daysOverdue > 0;
  bool get isDueSoon => !isOverdue && !isFullyPaid && daysOverdue <= 0 && DateTime.now().difference(dueDate).inDays.abs() <= 3;
  bool get isPaid => status == 'paid' || isFullyPaid;
}
