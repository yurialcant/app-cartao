-- ============================================================================
-- BENEFITS-CORE Schema Initialization
-- ============================================================================
-- Multi-tenant wallet, ledger, and payment infrastructure
-- All tables must include tenant_id for isolation
-- ============================================================================

-- ============================================================================
-- WALLETS & BALANCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    wallet_type VARCHAR(50) NOT NULL DEFAULT 'FLEX',
    balance NUMERIC(19, 2) NOT NULL DEFAULT 0,
    daily_limit NUMERIC(19, 2),
    daily_spent NUMERIC(19, 2) NOT NULL DEFAULT 0,
    last_daily_reset TIMESTAMP DEFAULT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 0,
    CONSTRAINT uk_wallets_tenant_user UNIQUE(tenant_id, user_id)
);

CREATE INDEX idx_wallets_tenant_user ON wallets(tenant_id, user_id);
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_status ON wallets(status);

-- ============================================================================
-- LEDGER (Immutable transaction log - Source of Truth for balance)
-- ============================================================================

CREATE TABLE IF NOT EXISTS ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    entry_type VARCHAR(50) NOT NULL,
    amount NUMERIC(19, 2) NOT NULL,
    description TEXT,
    reference_id VARCHAR(255),
    reference_type VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'COMPLETED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ledger_tenant_wallet ON ledger_entries(tenant_id, wallet_id);
CREATE INDEX idx_ledger_wallet_id ON ledger_entries(wallet_id);
CREATE INDEX idx_ledger_reference ON ledger_entries(reference_id, reference_type);
CREATE INDEX idx_ledger_entry_type ON ledger_entries(entry_type);
CREATE INDEX idx_ledger_created_at ON ledger_entries(created_at);

-- ============================================================================
-- PAYMENTS (POS/Merchant transactions with state machine)
-- ============================================================================

CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    merchant_id VARCHAR(255),
    terminal_id VARCHAR(255),
    amount NUMERIC(19, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    type VARCHAR(50) NOT NULL DEFAULT 'SALE',
    authorization_code VARCHAR(50),
    response_code VARCHAR(10),
    idempotency_key VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 0,
    CONSTRAINT uk_payments_idempotency UNIQUE(tenant_id, idempotency_key)
);

CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_wallet_id ON payments(wallet_id);
CREATE INDEX idx_payments_merchant_id ON payments(merchant_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- ============================================================================
-- REFUNDS (Credit transactions)
-- ============================================================================

CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    payment_id UUID NOT NULL REFERENCES payments(id),
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    amount NUMERIC(19, 2) NOT NULL,
    reason VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'COMPLETED',
    idempotency_key VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_refunds_idempotency UNIQUE(tenant_id, idempotency_key)
);

CREATE INDEX idx_refunds_payment_id ON refunds(payment_id);
CREATE INDEX idx_refunds_wallet_id ON refunds(wallet_id);
CREATE INDEX idx_refunds_status ON refunds(status);

-- ============================================================================
-- CREDIT BATCHES (Employer bulk credits)
-- ============================================================================

CREATE TABLE IF NOT EXISTS credit_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    employer_id VARCHAR(255) NOT NULL,
    batch_name VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'PROCESSING',
    total_amount NUMERIC(19, 2) NOT NULL DEFAULT 0,
    total_items INT NOT NULL DEFAULT 0,
    successful_items INT NOT NULL DEFAULT 0,
    failed_items INT NOT NULL DEFAULT 0,
    filename VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_credit_batches_tenant ON credit_batches(tenant_id);
CREATE INDEX idx_credit_batches_employer ON credit_batches(employer_id);
CREATE INDEX idx_credit_batches_status ON credit_batches(status);

CREATE TABLE IF NOT EXISTS credit_batch_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES credit_batches(id),
    user_id VARCHAR(255) NOT NULL,
    amount NUMERIC(19, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_batch_items_batch_id ON credit_batch_items(batch_id);
CREATE INDEX idx_batch_items_user_id ON credit_batch_items(user_id);
CREATE INDEX idx_batch_items_status ON credit_batch_items(status);

-- ============================================================================
-- OUTBOX PATTERN (Event sourcing - for async backbone)
-- ============================================================================

CREATE TABLE IF NOT EXISTS outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(100) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    version INT NOT NULL
);

CREATE INDEX idx_outbox_tenant ON outbox_events(tenant_id);
CREATE INDEX idx_outbox_aggregate ON outbox_events(aggregate_id, aggregate_type);
CREATE INDEX idx_outbox_processed ON outbox_events(processed_at);
CREATE INDEX idx_outbox_created_at ON outbox_events(created_at);

-- ============================================================================
-- IDEMPOTENCY CACHE (Redis-backed, this is for reference/audit)
-- ============================================================================

CREATE TABLE IF NOT EXISTS idempotency_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    idempotency_key VARCHAR(255) NOT NULL,
    request_hash VARCHAR(255),
    response_payload JSONB NOT NULL,
    status_code INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    CONSTRAINT uk_idempotency_key UNIQUE(tenant_id, idempotency_key)
);

CREATE INDEX idx_idempotency_key ON idempotency_records(idempotency_key);
CREATE INDEX idx_idempotency_expires ON idempotency_records(expires_at);

-- ============================================================================
-- USERS (Basic user registry for benefits platform)
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    external_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_users_tenant_external UNIQUE(tenant_id, external_id)
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_external_id ON users(external_id);
CREATE INDEX idx_users_email ON users(email);

-- ============================================================================
-- MERCHANTS (POS terminal owners)
-- ============================================================================

CREATE TABLE IF NOT EXISTS merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    merchant_name VARCHAR(255) NOT NULL,
    merchant_code VARCHAR(50),
    mcc VARCHAR(4),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_merchants_tenant_code UNIQUE(tenant_id, merchant_code)
);

CREATE INDEX idx_merchants_tenant ON merchants(tenant_id);
CREATE INDEX idx_merchants_mcc ON merchants(mcc);

-- ============================================================================
-- TERMINALS (POS devices)
-- ============================================================================

CREATE TABLE IF NOT EXISTS terminals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    merchant_id UUID NOT NULL REFERENCES merchants(id),
    terminal_id VARCHAR(50),
    serial_number VARCHAR(50),
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_terminals_tenant_id UNIQUE(tenant_id, terminal_id)
);

CREATE INDEX idx_terminals_merchant_id ON terminals(merchant_id);
CREATE INDEX idx_terminals_serial ON terminals(serial_number);

-- ============================================================================
-- TRANSACTIONS (Query table - denormalized from ledger for performance)
-- ============================================================================

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    ledger_entry_id UUID NOT NULL REFERENCES ledger_entries(id),
    amount NUMERIC(19, 2) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_wallet_created ON transactions(wallet_id, created_at DESC);
CREATE INDEX idx_transactions_tenant ON transactions(tenant_id);

-- ============================================================================
-- DEVICE REGISTRY (User devices for push notifications)
-- ============================================================================

CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    device_id VARCHAR(255) NOT NULL,
    device_type VARCHAR(50),
    push_token TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP
);

CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_devices_push_token ON devices(push_token);

-- ============================================================================
-- AUDIT LOG (Timeline of all operations for admin)
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    actor_id VARCHAR(255),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_tenant_timestamp ON audit_logs(tenant_id, timestamp DESC);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);

-- ============================================================================
-- CHARGE INTENTS (Pre-authorization holds before payment)
-- ============================================================================

CREATE TABLE IF NOT EXISTS charge_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id VARCHAR(255) NOT NULL,
    wallet_id UUID NOT NULL REFERENCES wallets(id),
    amount NUMERIC(19, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'INITIATED',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_charge_intents_wallet ON charge_intents(wallet_id);
CREATE INDEX idx_charge_intents_status ON charge_intents(status);

