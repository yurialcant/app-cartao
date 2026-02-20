/// Wallet model
class Wallet {
  final String id;
  final String walletType;
  final String displayName;
  final String iconKey;
  final int availableCents;
  final String currency;
  final String status;
  final List<String> ruleTags;

  const Wallet({
    required this.id,
    required this.walletType,
    required this.displayName,
    required this.iconKey,
    required this.availableCents,
    required this.currency,
    required this.status,
    required this.ruleTags,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      walletType: json['walletType'],
      displayName: json['displayName'] ?? json['walletType'],
      iconKey: json['iconKey'] ?? 'wallet',
      availableCents: json['availableCents'] ?? 0,
      currency: json['currency'] ?? 'BRL',
      status: json['status'] ?? 'ACTIVE',
      ruleTags: List<String>.from(json['ruleTags'] ?? []),
    );
  }

  double get availableAmount => availableCents / 100.0;
  bool get isActive => status == 'ACTIVE';
  bool get isLocked => status == 'LOCKED';
  bool get isSuspended => status == 'SUSPENDED';
}

/// Wallet detail with policies and rules
class WalletDetail {
  final String id;
  final String description;
  final WalletCycle cycle;
  final int dailySuggestedCents;
  final WalletPolicy policy;

  const WalletDetail({
    required this.id,
    required this.description,
    required this.cycle,
    required this.dailySuggestedCents,
    required this.policy,
  });

  factory WalletDetail.fromJson(Map<String, dynamic> json) {
    return WalletDetail(
      id: json['id'],
      description: json['description'] ?? '',
      cycle: WalletCycle.fromJson(json['cycle'] ?? {}),
      dailySuggestedCents: json['dailySuggestedCents'] ?? 0,
      policy: WalletPolicy.fromJson(json['policy'] ?? {}),
    );
  }

  double get dailySuggestedAmount => dailySuggestedCents / 100.0;
}

/// Wallet cycle information
class WalletCycle {
  final int cycleStartDay;
  final int cycleEndDay;
  final String timezone;

  const WalletCycle({
    required this.cycleStartDay,
    required this.cycleEndDay,
    required this.timezone,
  });

  factory WalletCycle.fromJson(Map<String, dynamic> json) {
    return WalletCycle(
      cycleStartDay: json['startDay'] ?? 1,
      cycleEndDay: json['endDay'] ?? 30,
      timezone: json['timezone'] ?? 'America/Sao_Paulo',
    );
  }
}

/// Wallet policy snapshot
class WalletPolicy {
  final List<String> mccAllow;
  final List<String> mccDeny;
  final int transactionLimitCents;
  final int dailyLimitCents;
  final List<String> channelsAllowed;

  const WalletPolicy({
    required this.mccAllow,
    required this.mccDeny,
    required this.transactionLimitCents,
    required this.dailyLimitCents,
    required this.channelsAllowed,
  });

  factory WalletPolicy.fromJson(Map<String, dynamic> json) {
    return WalletPolicy(
      mccAllow: List<String>.from(json['mccAllow'] ?? []),
      mccDeny: List<String>.from(json['mccDeny'] ?? []),
      transactionLimitCents: json['transactionLimitCents'] ?? 0,
      dailyLimitCents: json['dailyLimitCents'] ?? 0,
      channelsAllowed: List<String>.from(json['channelsAllowed'] ?? ['POS', 'ONLINE']),
    );
  }

  double get transactionLimitAmount => transactionLimitCents / 100.0;
  double get dailyLimitAmount => dailyLimitCents / 100.0;
}