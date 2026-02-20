/// Card model
class Card {
  final String id;
  final String type; // PHYSICAL, VIRTUAL
  final String status; // ACTIVE, FROZEN, CANCELLED, PENDING
  final String brand;
  final String maskedPan;
  final String? holderName;
  final DateTime? createdAt;
  final String? walletBinding;

  const Card({
    required this.id,
    required this.type,
    required this.status,
    required this.brand,
    required this.maskedPan,
    this.holderName,
    this.createdAt,
    this.walletBinding,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      type: json['type'] ?? 'VIRTUAL',
      status: json['status'] ?? 'ACTIVE',
      brand: json['brand'] ?? 'UNKNOWN',
      maskedPan: json['maskedPan'] ?? '**** **** **** ****',
      holderName: json['holderName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      walletBinding: json['walletBinding'],
    );
  }

  Card copyWith({
    String? id,
    String? type,
    String? status,
    String? brand,
    String? maskedPan,
    String? holderName,
    DateTime? createdAt,
    String? walletBinding,
  }) {
    return Card(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      brand: brand ?? this.brand,
      maskedPan: maskedPan ?? this.maskedPan,
      holderName: holderName ?? this.holderName,
      createdAt: createdAt ?? this.createdAt,
      walletBinding: walletBinding ?? this.walletBinding,
    );
  }

  bool get isPhysical => type == 'PHYSICAL';
  bool get isVirtual => type == 'VIRTUAL';
  bool get isActive => status == 'ACTIVE';
  bool get isFrozen => status == 'FROZEN';
  bool get isCancelled => status == 'CANCELLED';
  bool get isPending => status == 'PENDING';

  String get displayStatus {
    switch (status) {
      case 'ACTIVE':
        return 'Ativo';
      case 'FROZEN':
        return 'Bloqueado';
      case 'CANCELLED':
        return 'Cancelado';
      case 'PENDING':
        return 'Pendente';
      default:
        return status;
    }
  }

  String get cardTypeDisplay {
    return isPhysical ? 'Físico' : 'Virtual';
  }
}