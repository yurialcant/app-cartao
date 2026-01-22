class Terminal {
  final String id;
  final String terminalId;
  final String merchantId;
  final String locationName;
  final String? locationAddress;
  final String status;
  final DateTime? lastTransaction;
  final DateTime? lastPing;
  final List<String> capabilities;

  Terminal({
    required this.id,
    required this.terminalId,
    required this.merchantId,
    required this.locationName,
    this.locationAddress,
    required this.status,
    this.lastTransaction,
    this.lastPing,
    required this.capabilities,
  });

  factory Terminal.fromJson(Map<String, dynamic> json) {
    return Terminal(
      id: json['id'],
      terminalId: json['terminalId'],
      merchantId: json['merchantId'],
      locationName: json['locationName'],
      locationAddress: json['locationAddress'],
      status: json['status'],
      lastTransaction: json['lastTransaction'] != null ? DateTime.parse(json['lastTransaction']) : null,
      lastPing: json['lastPing'] != null ? DateTime.parse(json['lastPing']) : null,
      capabilities: List<String>.from(json['capabilities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terminalId': terminalId,
      'merchantId': merchantId,
      'locationName': locationName,
      'locationAddress': locationAddress,
      'status': status,
      'lastTransaction': lastTransaction?.toIso8601String(),
      'lastPing': lastPing?.toIso8601String(),
      'capabilities': capabilities,
    };
  }

  bool isActive() {
    return status == 'ACTIVE';
  }

  bool isOnline() {
    if (lastPing == null) return false;
    return lastPing!.isAfter(DateTime.now().subtract(const Duration(minutes: 5)));
  }

  bool hasCapability(String capability) {
    return capabilities.contains(capability);
  }
}