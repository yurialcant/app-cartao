package com.benefits.userbff.dto;

import java.util.List;
import java.util.Map;

public class TenantConfigDto {
    private BrandingDto branding;
    private ModulesDto modules;
    private UICompositionDto uiComposition;
    private List<WalletDefinitionDto> walletDefinitions;
    private List<PolicyDto> policies;

    public TenantConfigDto() {}

    public TenantConfigDto(
        BrandingDto branding,
        ModulesDto modules,
        UICompositionDto uiComposition,
        List<WalletDefinitionDto> walletDefinitions,
        List<PolicyDto> policies
    ) {
        this.branding = branding;
        this.modules = modules;
        this.uiComposition = uiComposition;
        this.walletDefinitions = walletDefinitions;
        this.policies = policies;
    }

    // Getters and setters
    public BrandingDto getBranding() { return branding; }
    public void setBranding(BrandingDto branding) { this.branding = branding; }

    public ModulesDto getModules() { return modules; }
    public void setModules(ModulesDto modules) { this.modules = modules; }

    public UICompositionDto getUiComposition() { return uiComposition; }
    public void setUiComposition(UICompositionDto uiComposition) { this.uiComposition = uiComposition; }

    public List<WalletDefinitionDto> getWalletDefinitions() { return walletDefinitions; }
    public void setWalletDefinitions(List<WalletDefinitionDto> walletDefinitions) { this.walletDefinitions = walletDefinitions; }

    public List<PolicyDto> getPolicies() { return policies; }
    public void setPolicies(List<PolicyDto> policies) { this.policies = policies; }
}

class BrandingDto {
    private String appName;
    private String primaryColor;
    private String secondaryColor;
    private String logoUrl;
    private String fontFamily;
    private String supportEmail;
    private String supportPhone;

    // Getters and setters
    public String getAppName() { return appName; }
    public void setAppName(String appName) { this.appName = appName; }

    public String getPrimaryColor() { return primaryColor; }
    public void setPrimaryColor(String primaryColor) { this.primaryColor = primaryColor; }

    public String getSecondaryColor() { return secondaryColor; }
    public void setSecondaryColor(String secondaryColor) { this.secondaryColor = secondaryColor; }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getFontFamily() { return fontFamily; }
    public void setFontFamily(String fontFamily) { this.fontFamily = fontFamily; }

    public String getSupportEmail() { return supportEmail; }
    public void setSupportEmail(String supportEmail) { this.supportEmail = supportEmail; }

    public String getSupportPhone() { return supportPhone; }
    public void setSupportPhone(String supportPhone) { this.supportPhone = supportPhone; }
}

class ModulesDto {
    private boolean cards;
    private boolean partners;
    private boolean corporateRequests;
    private boolean expenses;
    private boolean notifications;
    private boolean verificationCode;
    private boolean support;
    private boolean export;

    // Getters and setters
    public boolean isCards() { return cards; }
    public void setCards(boolean cards) { this.cards = cards; }

    public boolean isPartners() { return partners; }
    public void setPartners(boolean partners) { this.partners = partners; }

    public boolean isCorporateRequests() { return corporateRequests; }
    public void setCorporateRequests(boolean corporateRequests) { this.corporateRequests = corporateRequests; }

    public boolean isExpenses() { return expenses; }
    public void setExpenses(boolean expenses) { this.expenses = expenses; }

    public boolean isNotifications() { return notifications; }
    public void setNotifications(boolean notifications) { this.notifications = notifications; }

    public boolean isVerificationCode() { return verificationCode; }
    public void setVerificationCode(boolean verificationCode) { this.verificationCode = verificationCode; }

    public boolean isSupport() { return support; }
    public void setSupport(boolean support) { this.support = support; }

    public boolean isExport() { return export; }
    public void setExport(boolean export) { this.export = export; }
}

class UICompositionDto {
    private String schemaVersion;
    private List<HomeBlockDto> blocks;
    private Map<String, Object> navigationConfig;
    private Map<String, Object> featureFlags;

    // Getters and setters
    public String getSchemaVersion() { return schemaVersion; }
    public void setSchemaVersion(String schemaVersion) { this.schemaVersion = schemaVersion; }

    public List<HomeBlockDto> getBlocks() { return blocks; }
    public void setBlocks(List<HomeBlockDto> blocks) { this.blocks = blocks; }

    public Map<String, Object> getNavigationConfig() { return navigationConfig; }
    public void setNavigationConfig(Map<String, Object> navigationConfig) { this.navigationConfig = navigationConfig; }

    public Map<String, Object> getFeatureFlags() { return featureFlags; }
    public void setFeatureFlags(Map<String, Object> featureFlags) { this.featureFlags = featureFlags; }
}

class HomeBlockDto {
    private String type;
    private Map<String, Object> config;

    // Getters and setters
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Map<String, Object> getConfig() { return config; }
    public void setConfig(Map<String, Object> config) { this.config = config; }
}

class WalletDefinitionDto {
    private String walletType;
    private String name;
    private String description;
    private String iconUrl;
    private String color;
    private String category;
    private boolean isDefault;

    // Getters and setters
    public String getWalletType() { return walletType; }
    public void setWalletType(String walletType) { this.walletType = walletType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public boolean isDefault() { return isDefault; }
    public void setDefault(boolean isDefault) { this.isDefault = isDefault; }
}

class PolicyDto {
    private String policyType;
    private String name;
    private Map<String, Object> rules;

    // Getters and setters
    public String getPolicyType() { return policyType; }
    public void setPolicyType(String policyType) { this.policyType = policyType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Map<String, Object> getRules() { return rules; }
    public void setRules(Map<String, Object> rules) { this.rules = rules; }
}