/// Statement entry model
class StatementEntry {
  final String id;
  final DateTime occurredAt;
  final String direction; // DEBIT, CREDIT, ADJUST, REVERSAL, RESERVE, RELEASE
  final int amountCents;
  final String currency;
  final String walletId;
  final String walletType;
  final String? merchantName;
  final String status; // POSTED, PENDING, VOIDED
  final String referenceType; // PAYMENT, CREDIT_BATCH, REFUND, ADJUST
  final String? referenceId;
  final String? categoryLabel;
  final String? description;
  final String? notes;

  const StatementEntry({
    required this.id,
    required this.occurredAt,
    required this.direction,
    required this.amountCents,
    required this.currency,
    required this.walletId,
    required this.walletType,
    this.merchantName,
    required this.status,
    required this.referenceType,
    this.referenceId,
    this.categoryLabel,
    this.description,
    this.notes,
  });

  factory StatementEntry.fromJson(Map<String, dynamic> json) {
    return StatementEntry(
      id: json['id'],
      occurredAt: DateTime.parse(json['occurredAt']),
      direction: json['direction'] ?? 'DEBIT',
      amountCents: json['amountCents'] ?? 0,
      currency: json['currency'] ?? 'BRL',
      walletId: json['walletId'],
      walletType: json['walletType'],
      merchantName: json['merchantName'],
      status: json['status'] ?? 'POSTED',
      referenceType: json['referenceType'] ?? 'PAYMENT',
      referenceId: json['referenceId'],
      categoryLabel: json['categoryLabel'],
      description: json['description'],
      notes: json['notes'],
    );
  }

  double get amount => amountCents / 100.0;
  bool get isDebit => direction == 'DEBIT';
  bool get isCredit => direction == 'CREDIT';
  bool get isPosted => status == 'POSTED';
  bool get isPending => status == 'PENDING';
  bool get isVoided => status == 'VOIDED';

  String get displayAmount {
    final sign = isDebit ? '-' : '+';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  String get displayDescription {
    if (merchantName != null) return merchantName!;
    if (description != null) return description!;
    return referenceType;
  }

  String get displayCategory {
    return categoryLabel ?? 'Outros';
  }
}

/// Export status for statement exports
class ExportStatus {
  final String jobId;
  final String status; // PENDING, PROCESSING, COMPLETED, FAILED
  final String? downloadUrl;
  final String? errorMessage;
  final DateTime? completedAt;

  const ExportStatus({
    required this.jobId,
    required this.status,
    this.downloadUrl,
    this.errorMessage,
    this.completedAt,
  });

  factory ExportStatus.fromJson(Map<String, dynamic> json) {
    return ExportStatus(
      jobId: json['jobId'],
      status: json['status'] ?? 'PENDING',
      downloadUrl: json['downloadUrl'],
      errorMessage: json['errorMessage'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isProcessing => status == 'PROCESSING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isReady => isCompleted && downloadUrl != null;
}