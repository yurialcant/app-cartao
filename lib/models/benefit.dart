class Benefit {
  final String id;
  final String name;
  final String description;
  final String category;
  final double amount;
  final String currency;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validTo;

  Benefit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.amount,
    required this.currency,
    required this.isActive,
    this.validFrom,
    this.validTo,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      isActive: json['isActive'] ?? true,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom']) : null,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'amount': amount,
      'currency': currency,
      'isActive': isActive,
      'validFrom': validFrom?.toIso8601String(),
      'validTo': validTo?.toIso8601String(),
    };
  }

  bool isValid() {
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return isActive;
  }

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(2)} $currency';
  }
}