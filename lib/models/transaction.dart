class Transaction {
  final String? id;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime timestamp;
  final String? cardLastFour;
  final String? reference;

  Transaction({
    this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.cardLastFour,
    this.reference,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      cardLastFour: json['cardLastFour'],
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'cardLastFour': cardLastFour,
      'reference': reference,
    };
  }

  String getFormattedAmount() {
    return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  bool isApproved() {
    return status == 'APPROVED';
  }

  bool isPending() {
    return status == 'PENDING';
  }

  bool isDeclined() {
    return status == 'DECLINED';
  }
}