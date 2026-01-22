class PosTransaction {
  final String id;
  final String terminalId;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  PosTransaction({
    required this.id,
    required this.terminalId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory PosTransaction.fromJson(Map<String, dynamic> json) => PosTransaction(
        id: json['id'] as String,
        terminalId: json['terminalId'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
