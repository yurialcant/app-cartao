class Expense {
  final String? id;
  final String personId;
  final String employerId;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final DateTime expenseDate;
  final String status;
  final List<String>? receiptUrls;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? reimbursedAt;

  Expense({
    this.id,
    required this.personId,
    required this.employerId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.category,
    required this.expenseDate,
    this.status = 'PENDING',
    this.receiptUrls,
    this.submittedAt,
    this.approvedAt,
    this.reimbursedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      personId: json['personId'],
      employerId: json['employerId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      description: json['description'],
      category: json['category'],
      expenseDate: DateTime.parse(json['expenseDate']),
      status: json['status'] ?? 'PENDING',
      receiptUrls: json['receiptUrls'] != null ? List<String>.from(json['receiptUrls']) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      reimbursedAt: json['reimbursedAt'] != null ? DateTime.parse(json['reimbursedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'employerId': employerId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'category': category,
      'expenseDate': expenseDate.toIso8601String(),
      'status': status,
      'receiptUrls': receiptUrls,
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'reimbursedAt': reimbursedAt?.toIso8601String(),
    };
  }

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  bool isPending() {
    return status == 'PENDING';
  }

  bool isApproved() {
    return status == 'APPROVED';
  }

  bool isRejected() {
    return status == 'REJECTED';
  }

  bool isReimbursed() {
    return status == 'REIMBURSED';
  }
}