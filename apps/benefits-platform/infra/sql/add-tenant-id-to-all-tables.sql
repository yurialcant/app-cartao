-- Script SQL para adicionar tenant_id em todas as tabelas existentes

-- Adicionar tenant_id em wallets
ALTER TABLE wallets ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
CREATE INDEX IF NOT EXISTS idx_wallets_tenant_user ON wallets(tenant_id, user_id);

-- Adicionar tenant_id em transactions
ALTER TABLE transactions ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
CREATE INDEX IF NOT EXISTS idx_transactions_tenant_user ON transactions(tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_tenant_created ON transactions(tenant_id, created_at DESC);

-- Adicionar tenant_id em users (se tabela existir)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users') THEN
        ALTER TABLE users ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS keycloak_id VARCHAR(255);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(255);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(255);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS cpf VARCHAR(11);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
        ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';
    END IF;
END $$;

-- Adicionar tenant_id em merchants
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'merchants') THEN
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS name VARCHAR(255);
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS cnpj VARCHAR(18) UNIQUE;
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS email VARCHAR(255);
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS mcc VARCHAR(10);
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS category VARCHAR(50);
        ALTER TABLE merchants ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
    END IF;
END $$;

-- Adicionar tenant_id em charge_intents
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'charge_intents') THEN
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS merchant_id UUID;
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS terminal_id UUID;
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS operator_id UUID;
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS amount NUMERIC(19,2);
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'BRL';
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS qr_code VARCHAR(500);
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP;
        ALTER TABLE charge_intents ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
    END IF;
END $$;

-- Adicionar tenant_id em payments
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'payments') THEN
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS transaction_id UUID;
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS charge_intent_id UUID;
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS amount NUMERIC(19,2);
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'BRL';
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50);
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS acquirer_reference VARCHAR(100);
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS authorization_code VARCHAR(50);
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS captured_at TIMESTAMP;
        ALTER TABLE payments ADD COLUMN IF NOT EXISTS settled_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em refunds
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'refunds') THEN
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS transaction_id UUID;
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS payment_id UUID;
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS amount NUMERIC(19,2);
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'BRL';
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS refund_type VARCHAR(50);
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS reason VARCHAR(500);
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS requested_by VARCHAR(255);
        ALTER TABLE refunds ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em disputes
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'disputes') THEN
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS transaction_id UUID;
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS reason VARCHAR(500);
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'OPEN';
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS dispute_type VARCHAR(50);
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS opened_at TIMESTAMP DEFAULT NOW();
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMP;
        ALTER TABLE disputes ADD COLUMN IF NOT EXISTS resolution VARCHAR(1000);
    END IF;
END $$;

-- Adicionar tenant_id em devices
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'devices') THEN
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS device_id VARCHAR(200) UNIQUE;
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS device_name VARCHAR(200);
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS device_type VARCHAR(50);
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS os_version VARCHAR(50);
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS app_version VARCHAR(50);
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS is_trusted BOOLEAN DEFAULT false;
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS trusted_at TIMESTAMP;
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMP;
        ALTER TABLE devices ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';
    END IF;
END $$;

-- Adicionar tenant_id em tickets
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'tickets') THEN
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS transaction_id UUID;
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS subject VARCHAR(500);
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS description TEXT;
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'OPEN';
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS priority VARCHAR(50) DEFAULT 'MEDIUM';
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS assigned_to VARCHAR(255);
        ALTER TABLE tickets ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em topup_batches
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'topup_batches') THEN
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS employer_id VARCHAR(255);
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS batch_number VARCHAR(50) UNIQUE;
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS total_amount NUMERIC(19,2);
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS total_users INTEGER DEFAULT 0;
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'BRL';
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS approved_by VARCHAR(255);
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP;
        ALTER TABLE topup_batches ADD COLUMN IF NOT EXISTS executed_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em settlements
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'settlements') THEN
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS merchant_id UUID;
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS period_start TIMESTAMP;
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS period_end TIMESTAMP;
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS total_amount NUMERIC(19,2);
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS fee_amount NUMERIC(19,2);
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS net_amount NUMERIC(19,2);
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'BRL';
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP;
        ALTER TABLE settlements ADD COLUMN IF NOT EXISTS payout_reference VARCHAR(100);
    END IF;
END $$;

-- Adicionar tenant_id em reconciliations
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'reconciliations') THEN
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS reconciliation_date TIMESTAMP;
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS source VARCHAR(50);
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS file_name VARCHAR(500);
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS total_transactions INTEGER DEFAULT 0;
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS matched_transactions INTEGER DEFAULT 0;
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS unmatched_transactions INTEGER DEFAULT 0;
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE reconciliations ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em kyc
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'kyc') THEN
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS kyc_level VARCHAR(50) DEFAULT 'BASIC';
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS document_type VARCHAR(50);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS document_number VARCHAR(50);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS document_url VARCHAR(500);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS selfie_url VARCHAR(500);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP;
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS verified_by VARCHAR(255);
        ALTER TABLE kyc ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(1000);
    END IF;
END $$;

-- Adicionar tenant_id em kyb
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'kyb') THEN
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS merchant_id UUID;
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'PENDING';
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS document_type VARCHAR(50);
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS document_number VARCHAR(50);
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS document_url VARCHAR(500);
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP;
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS verified_by VARCHAR(255);
        ALTER TABLE kyb ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(1000);
    END IF;
END $$;

-- Adicionar tenant_id em audit_logs
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'audit_logs') THEN
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS action VARCHAR(100);
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS resource_type VARCHAR(100);
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS resource_id VARCHAR(100);
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS details JSONB;
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS ip_address VARCHAR(50);
        ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS user_agent VARCHAR(500);
    END IF;
END $$;

-- Adicionar tenant_id em terminals
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'terminals') THEN
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS merchant_id UUID;
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS name VARCHAR(200);
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS terminal_id VARCHAR(100) UNIQUE;
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';
        ALTER TABLE terminals ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMP;
    END IF;
END $$;

-- Adicionar tenant_id em operators
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'operators') THEN
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS tenant_id VARCHAR(100) NOT NULL DEFAULT 'default';
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS merchant_id UUID;
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS username VARCHAR(100) UNIQUE;
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS full_name VARCHAR(255);
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'OPERATOR';
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'ACTIVE';
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS pin_hash VARCHAR(255);
        ALTER TABLE operators ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP;
    END IF;
END $$;

-- Criar tabela de tenants (se não existir)
CREATE TABLE IF NOT EXISTS tenants (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP
);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_wallets_tenant ON wallets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_transactions_tenant ON transactions(tenant_id);
CREATE INDEX IF NOT EXISTS idx_merchants_tenant ON merchants(tenant_id);
CREATE INDEX IF NOT EXISTS idx_devices_tenant ON devices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tickets_tenant ON tickets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_topup_batches_tenant ON topup_batches(tenant_id);
