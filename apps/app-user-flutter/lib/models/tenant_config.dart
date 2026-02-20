/// Tenant configuration model - loaded via /user/bootstrap
class TenantConfig {
  final Branding branding;
  final Modules modules;
  final UIComposition uiComposition;
  final List<WalletDefinition> walletDefinitions;
  final List<Policy> policies;

  const TenantConfig({
    required this.branding,
    required this.modules,
    required this.uiComposition,
    required this.walletDefinitions,
    required this.policies,
  });

  factory TenantConfig.defaultConfig() {
    return TenantConfig(
      branding: Branding.defaultBranding(),
      modules: Modules.defaultModules(),
      uiComposition: UIComposition.defaultComposition(),
      walletDefinitions: [],
      policies: [],
    );
  }

  factory TenantConfig.fromJson(Map<String, dynamic> json) {
    return TenantConfig(
      branding: Branding.fromJson(json['branding']),
      modules: Modules.fromJson(json['modules']),
      uiComposition: UIComposition.fromJson(json['uiComposition']),
      walletDefinitions: (json['walletDefinitions'] as List?)
          ?.map((e) => WalletDefinition.fromJson(e))
          .toList() ?? [],
      policies: (json['policies'] as List?)
          ?.map((e) => Policy.fromJson(e))
          .toList() ?? [],
    );
  }
}

/// Branding configuration
class Branding {
  final String appName;
  final String primaryColor;
  final String? secondaryColor;
  final String? logoUrl;
  final String? faviconUrl;
  final String? fontFamily;
  final String? supportEmail;
  final String? supportPhone;

  const Branding({
    required this.appName,
    required this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
    this.faviconUrl,
    this.fontFamily,
    this.supportEmail,
    this.supportPhone,
  });

  factory Branding.defaultBranding() {
    return const Branding(
      appName: 'Benefits App',
      primaryColor: '#1976d2',
      secondaryColor: '#424242',
      fontFamily: 'Roboto',
    );
  }

  factory Branding.fromJson(Map<String, dynamic> json) {
    return Branding(
      appName: json['appName'] ?? 'Benefits App',
      primaryColor: json['primaryColor'] ?? '#1976d2',
      secondaryColor: json['secondaryColor'],
      logoUrl: json['logoUrl'],
      faviconUrl: json['faviconUrl'],
      fontFamily: json['fontFamily'] ?? 'Roboto',
      supportEmail: json['supportEmail'],
      supportPhone: json['supportPhone'],
    );
  }
}

/// Module toggles
class Modules {
  final bool cards;
  final bool partners;
  final bool corporateRequests;
  final bool expenses;
  final bool notifications;
  final bool verificationCode;
  final bool support;
  final bool export;

  const Modules({
    required this.cards,
    required this.partners,
    required this.corporateRequests,
    required this.expenses,
    required this.notifications,
    required this.verificationCode,
    required this.support,
    required this.export,
  });

  factory Modules.defaultModules() {
    return const Modules(
      cards: true,
      partners: true,
      corporateRequests: true,
      expenses: true,
      notifications: true,
      verificationCode: true,
      support: true,
      export: true,
    );
  }

  factory Modules.fromJson(Map<String, dynamic> json) {
    return Modules(
      cards: json['cards'] ?? true,
      partners: json['partners'] ?? true,
      corporateRequests: json['corporateRequests'] ?? true,
      expenses: json['expenses'] ?? true,
      notifications: json['notifications'] ?? true,
      verificationCode: json['verificationCode'] ?? true,
      support: json['support'] ?? true,
      export: json['export'] ?? true,
    );
  }
}

/// UI Composition (home_json)
class UIComposition {
  final String schemaVersion;
  final List<HomeBlock> blocks;
  final Map<String, dynamic> navigationConfig;
  final Map<String, dynamic> featureFlags;

  const UIComposition({
    required this.schemaVersion,
    required this.blocks,
    required this.navigationConfig,
    required this.featureFlags,
  });

  factory UIComposition.defaultComposition() {
    return UIComposition(
      schemaVersion: '1.0',
      blocks: [
        HomeBlock(type: 'wallet_summary', config: {}),
        HomeBlock(type: 'quick_actions', config: {}),
        HomeBlock(type: 'notifications_preview', config: {}),
      ],
      navigationConfig: {},
      featureFlags: {},
    );
  }

  factory UIComposition.fromJson(Map<String, dynamic> json) {
    return UIComposition(
      schemaVersion: json['schemaVersion'] ?? '1.0',
      blocks: (json['blocks'] as List?)
          ?.map((e) => HomeBlock.fromJson(e))
          .toList() ?? [],
      navigationConfig: json['navigationConfig'] ?? {},
      featureFlags: json['featureFlags'] ?? {},
    );
  }
}

/// Home screen blocks
class HomeBlock {
  final String type;
  final Map<String, dynamic> config;

  const HomeBlock({
    required this.type,
    required this.config,
  });

  factory HomeBlock.fromJson(Map<String, dynamic> json) {
    return HomeBlock(
      type: json['type'] ?? 'unknown',
      config: json['config'] ?? {},
    );
  }
}

/// Wallet definitions
class WalletDefinition {
  final String walletType;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? color;
  final String category;
  final bool isDefault;

  const WalletDefinition({
    required this.walletType,
    required this.name,
    this.description,
    this.iconUrl,
    this.color,
    required this.category,
    required this.isDefault,
  });

  factory WalletDefinition.fromJson(Map<String, dynamic> json) {
    return WalletDefinition(
      walletType: json['walletType'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      color: json['color'],
      category: json['category'] ?? 'GENERAL',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

/// Policies
class Policy {
  final String policyType;
  final String name;
  final Map<String, dynamic> rules;

  const Policy({
    required this.policyType,
    required this.name,
    required this.rules,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      policyType: json['policyType'],
      name: json['name'],
      rules: json['rules'] ?? {},
    );
  }
}