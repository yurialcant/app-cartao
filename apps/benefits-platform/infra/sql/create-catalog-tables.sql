-- =====================================================
-- CATÁLOGO DE PRODUTOS - TABELAS DO TENANT SERVICE
-- =====================================================
-- Execute este script após create-all-tables.sql

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABELA: tenants (se não existir)
-- =====================================================
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    domain VARCHAR(255),
    active BOOLEAN DEFAULT true,
    program_type VARCHAR(50),
    feature_flags JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TABELA: tenant_brandings
-- =====================================================
CREATE TABLE IF NOT EXISTS tenant_brandings (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    tenant_id VARCHAR(255) NOT NULL REFERENCES tenants(id),
    primary_color VARCHAR(20),
    secondary_color VARCHAR(20),
    logo_url VARCHAR(500),
    favicon_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id)
);

-- =====================================================
-- TABELA: plans
-- =====================================================
CREATE TABLE IF NOT EXISTS plans (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    price_monthly DECIMAL(19,2),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    eligibility JSONB,
    limits JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_plans_status ON plans(status);

-- =====================================================
-- TABELA: plan_modules
-- =====================================================
CREATE TABLE IF NOT EXISTS plan_modules (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    plan_id VARCHAR(255) NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    module_type VARCHAR(50) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    icon_name VARCHAR(100),
    display_order INTEGER DEFAULT 0,
    show_badge BOOLEAN DEFAULT false,
    badge_text VARCHAR(50),
    enabled BOOLEAN DEFAULT true,
    routes JSONB,
    config JSONB,
    ui_hints JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_plan_modules_plan ON plan_modules(plan_id);

-- =====================================================
-- TABELA: wallet_definitions
-- =====================================================
CREATE TABLE IF NOT EXISTS wallet_definitions (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    plan_id VARCHAR(255) NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    wallet_type VARCHAR(50) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    currency VARCHAR(3) DEFAULT 'BRL',
    icon_name VARCHAR(100),
    color_hex VARCHAR(20),
    display_order INTEGER DEFAULT 0,
    visible_in_home BOOLEAN DEFAULT true,
    spend_rules JSONB,
    mcc_allowed JSONB,
    mcc_blocked JSONB,
    time_windows JSONB,
    daily_limit DECIMAL(19,2),
    monthly_limit DECIMAL(19,2),
    per_transaction_limit DECIMAL(19,2),
    daily_suggested_spend_enabled BOOLEAN DEFAULT true,
    balance_expiration_days INTEGER,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_wallet_definitions_plan ON wallet_definitions(plan_id);

-- =====================================================
-- TABELA: card_programs
-- =====================================================
CREATE TABLE IF NOT EXISTS card_programs (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    plan_id VARCHAR(255) NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    card_type VARCHAR(50) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    card_brand VARCHAR(50),
    user_can_create BOOLEAN DEFAULT false,
    max_cards_per_user INTEGER DEFAULT 1,
    default_daily_limit DECIMAL(19,2),
    default_monthly_limit DECIMAL(19,2),
    default_per_transaction_limit DECIMAL(19,2),
    max_daily_limit DECIMAL(19,2),
    max_monthly_limit DECIMAL(19,2),
    features JSONB,
    config JSONB,
    linked_wallet_types JSONB,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_card_programs_plan ON card_programs(plan_id);

-- =====================================================
-- TABELA: partner_catalogs
-- =====================================================
CREATE TABLE IF NOT EXISTS partner_catalogs (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    tenant_id VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    short_description VARCHAR(255),
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    partner_type VARCHAR(50),
    category VARCHAR(100),
    redirect_url VARCHAR(500),
    tracking_params JSONB,
    tags JSONB,
    regions JSONB,
    offer_info JSONB,
    cta_text VARCHAR(100),
    cta_url VARCHAR(500),
    display_order INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_partner_catalogs_tenant ON partner_catalogs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_partner_catalogs_category ON partner_catalogs(category);

-- =====================================================
-- TABELA: feature_flags
-- =====================================================
CREATE TABLE IF NOT EXISTS feature_flags (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    key VARCHAR(255) NOT NULL,
    value BOOLEAN NOT NULL,
    scope VARCHAR(50) NOT NULL,
    scope_id VARCHAR(255),
    description VARCHAR(500),
    rollout_percentage INTEGER DEFAULT 100,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(key, scope, scope_id)
);

CREATE INDEX IF NOT EXISTS idx_feature_flags_key ON feature_flags(key);
CREATE INDEX IF NOT EXISTS idx_feature_flags_scope ON feature_flags(scope, scope_id);

-- =====================================================
-- TABELA: plan_assignments
-- =====================================================
CREATE TABLE IF NOT EXISTS plan_assignments (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    plan_id VARCHAR(255) NOT NULL REFERENCES plans(id),
    tenant_id VARCHAR(255) NOT NULL,
    employer_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    assigned_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_plan_assignments_tenant ON plan_assignments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_plan_assignments_plan ON plan_assignments(plan_id);

-- =====================================================
-- TABELA: ledger_entries (para benefits-core)
-- =====================================================
CREATE TABLE IF NOT EXISTS ledger_entries (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    wallet_id VARCHAR(255) NOT NULL,
    amount DECIMAL(19,4) NOT NULL,
    entry_type VARCHAR(50) NOT NULL, -- CREDIT, DEBIT, RESERVE, RELEASE
    reference_type VARCHAR(50), -- TOPUP, PAYMENT, ADJUSTMENT, REFUND
    reference_id VARCHAR(255),
    description VARCHAR(500),
    metadata JSONB,
    balance_after DECIMAL(19,4),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    -- Nota: ledger é append-only, sem updated_at
);

CREATE INDEX IF NOT EXISTS idx_ledger_entries_wallet ON ledger_entries(wallet_id);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_created ON ledger_entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ledger_entries_reference ON ledger_entries(reference_type, reference_id);

-- =====================================================
-- TABELA: outbox_events (para Outbox Pattern)
-- =====================================================
CREATE TABLE IF NOT EXISTS outbox_events (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    aggregate_type VARCHAR(100) NOT NULL, -- Ex: 'Wallet', 'Payment', 'Card'
    aggregate_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL, -- Ex: 'wallet.credited.v1'
    payload JSONB NOT NULL,
    metadata JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, PUBLISHED, FAILED
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_outbox_events_status ON outbox_events(status, created_at);
CREATE INDEX IF NOT EXISTS idx_outbox_events_aggregate ON outbox_events(aggregate_type, aggregate_id);

-- =====================================================
-- TABELA: corporate_requests (para support-service)
-- =====================================================
CREATE TABLE IF NOT EXISTS corporate_requests (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    employer_id VARCHAR(255),
    request_type VARCHAR(50) NOT NULL, -- BALANCE_REQUEST, LIMIT_INCREASE
    amount DECIMAL(19,2),
    reason VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    reviewed_by VARCHAR(255),
    reviewed_at TIMESTAMP,
    rejection_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_corporate_requests_user ON corporate_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_corporate_requests_status ON corporate_requests(status);

-- =====================================================
-- TABELA: expenses (para support-service)
-- =====================================================
CREATE TABLE IF NOT EXISTS expenses (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255),
    amount DECIMAL(19,2) NOT NULL,
    category VARCHAR(100),
    cost_center VARCHAR(100),
    project VARCHAR(100),
    description VARCHAR(500),
    receipt_url VARCHAR(500),
    receipt_uploaded_at TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'DRAFT', -- DRAFT, SUBMITTED, APPROVED, REJECTED
    submitted_at TIMESTAMP,
    reviewed_by VARCHAR(255),
    reviewed_at TIMESTAMP,
    rejection_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_expenses_user ON expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_status ON expenses(status);

-- =====================================================
-- TABELA: verification_codes (para auth)
-- =====================================================
CREATE TABLE IF NOT EXISTS verification_codes (
    id VARCHAR(255) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
    user_id VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
    purpose VARCHAR(50) NOT NULL, -- WEB_LOGIN, DEVICE_VERIFICATION
    session_id VARCHAR(255),
    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_verification_codes_user ON verification_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_codes_code ON verification_codes(code);

COMMIT;
