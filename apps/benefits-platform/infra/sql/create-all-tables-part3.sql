-- ====================================
-- SQL SCHEMA COMPLETO - PARTE 3
-- Recon, Settlement, Privacy, Webhook
-- ====================================

-- ========== RECON-SERVICE ==========
CREATE TABLE IF NOT EXISTS reconciliation_batches (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    batch_number VARCHAR(100) NOT NULL UNIQUE,
    type VARCHAR(50) NOT NULL,
    period_start TIMESTAMP NOT NULL,
    period_end TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_transactions INT DEFAULT 0,
    matched_transactions INT DEFAULT 0,
    unmatched_transactions INT DEFAULT 0,
    discrepancies_count INT DEFAULT 0,
    total_amount DECIMAL(18,2) DEFAULT 0,
    matched_amount DECIMAL(18,2) DEFAULT 0,
    discrepancy_amount DECIMAL(18,2) DEFAULT 0,
    source_system VARCHAR(100),
    target_system VARCHAR(100),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    approved_by VARCHAR(255),
    approved_at TIMESTAMP,
    notes TEXT,
    metadata TEXT,
    INDEX idx_batch_type (type),
    INDEX idx_batch_status (status),
    INDEX idx_batch_period (period_start, period_end)
);

CREATE TABLE IF NOT EXISTS reconciliation_items (
    id VARCHAR(36) PRIMARY KEY,
    batch_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) NOT NULL,
    source_record_id VARCHAR(255),
    target_record_id VARCHAR(255),
    match_status VARCHAR(50) NOT NULL,
    source_amount DECIMAL(15,2),
    target_amount DECIMAL(15,2),
    difference_amount DECIMAL(15,2),
    source_date TIMESTAMP,
    target_date TIMESTAMP,
    match_confidence DECIMAL(5,2),
    match_criteria VARCHAR(100),
    discrepancy_type VARCHAR(100),
    discrepancy_reason TEXT,
    resolution_status VARCHAR(50),
    resolution_action TEXT,
    resolved_by VARCHAR(255),
    resolved_at TIMESTAMP,
    source_data TEXT,
    target_data TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL,
    INDEX idx_item_batch (batch_id),
    INDEX idx_item_transaction (transaction_id),
    INDEX idx_item_status (match_status)
);

-- ========== SETTLEMENT-SERVICE ==========
CREATE TABLE IF NOT EXISTS settlements (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    merchant_id VARCHAR(255) NOT NULL,
    settlement_number VARCHAR(100) NOT NULL UNIQUE,
    period_start TIMESTAMP NOT NULL,
    period_end TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_transactions INT DEFAULT 0,
    gross_amount DECIMAL(18,2) DEFAULT 0,
    mdr_fee DECIMAL(18,2) DEFAULT 0,
    gateway_fee DECIMAL(18,2) DEFAULT 0,
    chargeback_fee DECIMAL(18,2) DEFAULT 0,
    other_fees DECIMAL(18,2) DEFAULT 0,
    net_amount DECIMAL(18,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'BRL',
    bank_code VARCHAR(10),
    agency VARCHAR(20),
    account_number VARCHAR(30),
    account_type VARCHAR(20),
    pix_key VARCHAR(255),
    payment_method VARCHAR(50),
    scheduled_for TIMESTAMP,
    transferred_at TIMESTAMP,
    transfer_confirmation VARCHAR(255),
    bank_receipt TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    approved_by VARCHAR(255),
    approved_at TIMESTAMP,
    cancelled_by VARCHAR(255),
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    metadata TEXT,
    INDEX idx_settlement_merchant (merchant_id),
    INDEX idx_settlement_status (status),
    INDEX idx_settlement_period (period_start, period_end)
);

CREATE TABLE IF NOT EXISTS settlement_transactions (
    id VARCHAR(36) PRIMARY KEY,
    settlement_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    gross_amount DECIMAL(15,2) NOT NULL,
    mdr_rate DECIMAL(5,4),
    mdr_fee DECIMAL(15,2),
    gateway_fee DECIMAL(15,2),
    net_amount DECIMAL(15,2) NOT NULL,
    card_brand VARCHAR(50),
    installments INT,
    nsu VARCHAR(50),
    authorization_code VARCHAR(50),
    merchant_order_id VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    INDEX idx_settlement_txn_settlement (settlement_id),
    INDEX idx_settlement_txn_transaction (transaction_id),
    INDEX idx_settlement_txn_date (transaction_date)
);

-- ========== PRIVACY-SERVICE ==========
CREATE TABLE IF NOT EXISTS consent_records (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    consent_type VARCHAR(100) NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    granted BOOLEAN NOT NULL,
    version VARCHAR(20) NOT NULL,
    granted_at TIMESTAMP,
    revoked_at TIMESTAMP,
    expires_at TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT,
    channel VARCHAR(50),
    legal_basis VARCHAR(100),
    data_categories TEXT,
    third_party_sharing BOOLEAN DEFAULT FALSE,
    third_parties TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    INDEX idx_consent_user (user_id),
    INDEX idx_consent_type (consent_type),
    INDEX idx_consent_granted (granted)
);

CREATE TABLE IF NOT EXISTS data_retention_policies (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255),
    policy_name VARCHAR(255) NOT NULL,
    data_category VARCHAR(100) NOT NULL,
    retention_period_days INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    applies_to_deleted_accounts BOOLEAN DEFAULT TRUE,
    legal_basis VARCHAR(255),
    exceptions TEXT,
    last_executed_at TIMESTAMP,
    next_execution_at TIMESTAMP,
    records_processed_last_run INT,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    updated_by VARCHAR(255),
    updated_at TIMESTAMP,
    INDEX idx_policy_category (data_category),
    INDEX idx_policy_active (is_active)
);

CREATE TABLE IF NOT EXISTS data_subject_requests (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    request_number VARCHAR(100) NOT NULL UNIQUE,
    user_id VARCHAR(255) NOT NULL,
    user_name VARCHAR(255),
    user_email VARCHAR(255),
    request_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    description TEXT,
    requested_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    verified_by VARCHAR(255),
    verification_method VARCHAR(100),
    deadline TIMESTAMP,
    completed_at TIMESTAMP,
    completed_by VARCHAR(255),
    data_package_url VARCHAR(500),
    deletion_confirmed BOOLEAN DEFAULT FALSE,
    deletion_log TEXT,
    rejection_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    INDEX idx_dsr_user (user_id),
    INDEX idx_dsr_type (request_type),
    INDEX idx_dsr_status (status)
);

-- ========== WEBHOOK-RECEIVER ==========
CREATE TABLE IF NOT EXISTS webhook_subscriptions (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    event_types TEXT NOT NULL,
    status VARCHAR(50) NOT NULL,
    secret VARCHAR(255) NOT NULL,
    signature_algorithm VARCHAR(50) DEFAULT 'HMAC-SHA256',
    custom_headers TEXT,
    retry_strategy VARCHAR(50) DEFAULT 'EXPONENTIAL',
    max_retries INT DEFAULT 5,
    timeout_seconds INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    updated_by VARCHAR(255),
    updated_at TIMESTAMP,
    last_triggered_at TIMESTAMP,
    total_deliveries INT DEFAULT 0,
    successful_deliveries INT DEFAULT 0,
    failed_deliveries INT DEFAULT 0,
    INDEX idx_subscription_tenant (tenant_id),
    INDEX idx_subscription_status (status)
);

CREATE TABLE IF NOT EXISTS webhook_deliveries (
    id VARCHAR(36) PRIMARY KEY,
    subscription_id VARCHAR(36) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    event_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload TEXT NOT NULL,
    status VARCHAR(50) NOT NULL,
    attempt_count INT DEFAULT 0,
    max_attempts INT DEFAULT 5,
    url VARCHAR(1000),
    http_method VARCHAR(10) DEFAULT 'POST',
    headers TEXT,
    signature VARCHAR(500),
    sent_at TIMESTAMP,
    next_retry_at TIMESTAMP,
    last_attempt_at TIMESTAMP,
    response_status INT,
    response_body TEXT,
    error_message TEXT,
    moved_to_dlq BOOLEAN DEFAULT FALSE,
    dlq_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    INDEX idx_delivery_subscription (subscription_id),
    INDEX idx_delivery_event (event_id),
    INDEX idx_delivery_status (status),
    INDEX idx_delivery_retry (next_retry_at)
);

-- ========== BENEFITS-CORE (Missing Tables) ==========
CREATE TABLE IF NOT EXISTS cards (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    card_number VARCHAR(255) NOT NULL,
    card_number_encrypted VARCHAR(500),
    card_number_last_four VARCHAR(4),
    card_type VARCHAR(20) NOT NULL,
    card_brand VARCHAR(50),
    cardholder_name VARCHAR(255),
    expiration_month INT NOT NULL,
    expiration_year INT NOT NULL,
    cvv_encrypted VARCHAR(255),
    card_status VARCHAR(50) NOT NULL,
    activation_status VARCHAR(50),
    activated_at TIMESTAMP,
    blocked_at TIMESTAMP,
    blocked_reason VARCHAR(255),
    cancelled_at TIMESTAMP,
    cancellation_reason VARCHAR(255),
    delivery_status VARCHAR(50),
    delivery_address TEXT,
    delivery_tracking VARCHAR(255),
    delivery_requested_at TIMESTAMP,
    delivery_shipped_at TIMESTAMP,
    delivery_delivered_at TIMESTAMP,
    is_default BOOLEAN DEFAULT FALSE,
    is_virtual BOOLEAN DEFAULT FALSE,
    bin VARCHAR(10),
    issuer VARCHAR(100),
    network VARCHAR(50),
    network_token VARCHAR(255),
    network_token_expiration TIMESTAMP,
    daily_limit DECIMAL(15,2),
    monthly_limit DECIMAL(15,2),
    daily_spent DECIMAL(15,2) DEFAULT 0,
    monthly_spent DECIMAL(15,2) DEFAULT 0,
    contactless_enabled BOOLEAN DEFAULT TRUE,
    online_purchases_enabled BOOLEAN DEFAULT TRUE,
    international_purchases_enabled BOOLEAN DEFAULT FALSE,
    atm_withdrawal_enabled BOOLEAN DEFAULT FALSE,
    pin_set BOOLEAN DEFAULT FALSE,
    pin_encrypted VARCHAR(255),
    pin_tries_remaining INT DEFAULT 3,
    pin_blocked BOOLEAN DEFAULT FALSE,
    replacement_for_card_id VARCHAR(36),
    replaced_by_card_id VARCHAR(36),
    replacement_reason VARCHAR(255),
    physical_order_id VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    INDEX idx_card_user (user_id),
    INDEX idx_card_number (card_number_last_four),
    INDEX idx_card_status (card_status)
);

CREATE TABLE IF NOT EXISTS beneficiaries (
    id VARCHAR(36) PRIMARY KEY,
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cpf VARCHAR(14),
    birth_date DATE,
    relationship VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    status VARCHAR(50) NOT NULL,
    approval_status VARCHAR(50),
    approved_by VARCHAR(255),
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    documents TEXT,
    card_requested BOOLEAN DEFAULT FALSE,
    card_id VARCHAR(36),
    spending_limit DECIMAL(15,2),
    allowed_merchant_categories TEXT,
    restrictions TEXT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    INDEX idx_beneficiary_user (user_id),
    INDEX idx_beneficiary_status (status),
    INDEX idx_beneficiary_cpf (cpf)
);

-- ========== INDEXES ADICIONAIS PARA PERFORMANCE ==========

-- User lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_cpf ON users(cpf);
CREATE INDEX idx_users_tenant ON users(tenant_id);

-- Transaction queries
CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date);
CREATE INDEX idx_transactions_merchant_date ON transactions(merchant_id, transaction_date);
CREATE INDEX idx_transactions_status_date ON transactions(status, transaction_date);

-- Wallet balance queries
CREATE INDEX idx_wallets_user_type ON wallets(user_id, wallet_type);
CREATE INDEX idx_wallets_status ON wallets(status);

-- Ledger entries for accounting
CREATE INDEX idx_ledger_wallet_date ON ledger_entries(wallet_id, created_at);
CREATE INDEX idx_ledger_transaction ON ledger_entries(transaction_id);

-- Event sourcing replay
CREATE INDEX idx_events_aggregate_version ON domain_events(aggregate_id, version);
CREATE INDEX idx_events_type_created ON domain_events(event_type, created_at);

COMMIT;
