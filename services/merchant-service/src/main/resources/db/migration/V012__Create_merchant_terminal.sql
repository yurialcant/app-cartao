-- V012__Create_merchant_terminal.sql
-- Create merchant and terminal management tables

CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    merchant_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    business_name VARCHAR(255),
    document VARCHAR(50), -- CNPJ
    email VARCHAR(255),
    phone VARCHAR(50),
    address_street VARCHAR(255),
    address_number VARCHAR(20),
    address_complement VARCHAR(100),
    address_city VARCHAR(100),
    address_state VARCHAR(50),
    address_zip VARCHAR(20),
    address_country VARCHAR(50) DEFAULT 'Brazil',
    category VARCHAR(100), -- Restaurant, Retail, Services, etc.
    mcc_code VARCHAR(10), -- Merchant Category Code
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    risk_level VARCHAR(10) DEFAULT 'LOW' CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE terminals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    merchant_id UUID NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    terminal_id VARCHAR(50) UNIQUE NOT NULL,
    serial_number VARCHAR(100),
    model VARCHAR(100),
    firmware_version VARCHAR(20),
    location_name VARCHAR(255), -- Restaurant name, store location, etc.
    location_address VARCHAR(500),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    timezone VARCHAR(50) DEFAULT 'America/Sao_Paulo',
    currency VARCHAR(3) NOT NULL DEFAULT 'BRL',
    capabilities TEXT[], -- Array of supported capabilities
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED')),
    last_ping TIMESTAMP WITH TIME ZONE,
    last_transaction TIMESTAMP WITH TIME ZONE,
    configuration JSONB, -- Terminal-specific configuration
    credentials JSONB, -- Encrypted credentials for payment processing
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE terminal_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    terminal_id UUID NOT NULL REFERENCES terminals(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_merchants_tenant_id ON merchants(tenant_id);
CREATE INDEX idx_merchants_merchant_id ON merchants(merchant_id);
CREATE INDEX idx_merchants_document ON merchants(document);
CREATE INDEX idx_merchants_status ON merchants(status);

CREATE INDEX idx_terminals_tenant_id ON terminals(tenant_id);
CREATE INDEX idx_terminals_merchant_id ON terminals(merchant_id);
CREATE INDEX idx_terminals_terminal_id ON terminals(terminal_id);
CREATE INDEX idx_terminals_status ON terminals(status);
CREATE INDEX idx_terminals_last_ping ON terminals(last_ping);
CREATE INDEX idx_terminals_last_transaction ON terminals(last_transaction);

CREATE INDEX idx_terminal_logs_tenant_id ON terminal_logs(tenant_id);
CREATE INDEX idx_terminal_logs_terminal_id ON terminal_logs(terminal_id);
CREATE INDEX idx_terminal_logs_event_type ON terminal_logs(event_type);
CREATE INDEX idx_terminal_logs_created_at ON terminal_logs(created_at);

-- Constraints
ALTER TABLE merchants ADD CONSTRAINT chk_merchants_email_format
    CHECK (email IS NULL OR email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- Create some sample data
INSERT INTO merchants (tenant_id, merchant_id, name, business_name, document, email, category, mcc_code, status) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'MERC001', 'Restaurante Sabor', 'Sabor Ltda', '12345678000123', 'contato@sabor.com', 'Restaurant', '5812', 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', 'MERC002', 'Loja Center', 'Center Comercio Ltda', '98765432000156', 'vendas@center.com', 'Retail', '5411', 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', 'MERC003', 'Posto Gas', 'Gasolina Express Ltda', '45678912000178', 'posto@gas.com', 'Fuel', '5541', 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', 'MERC004', 'Hotel Comfort', 'Comfort Hospedagem Ltda', '32165498000190', 'reservas@comfort.com', 'Hospitality', '7011', 'ACTIVE');

INSERT INTO terminals (tenant_id, merchant_id, terminal_id, serial_number, model, location_name, location_address, capabilities, status) VALUES
('550e8400-e29b-41d4-a716-446655440000', (SELECT id FROM merchants WHERE merchant_id = 'MERC001'), 'TERM001', 'SN123456789', 'POS-2000', 'Restaurante Sabor - Matriz', 'Rua das Flores, 123, Centro, São Paulo', ARRAY['CONTACTLESS', 'CHIP', 'MAGSTRIPE', 'NFC'], 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', (SELECT id FROM merchants WHERE merchant_id = 'MERC001'), 'TERM002', 'SN123456790', 'POS-2000', 'Restaurante Sabor - Filial', 'Av. Paulista, 456, São Paulo', ARRAY['CONTACTLESS', 'CHIP', 'MAGSTRIPE'], 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', (SELECT id FROM merchants WHERE merchant_id = 'MERC002'), 'TERM003', 'SN123456791', 'POS-3000', 'Loja Center - Shopping', 'Shopping Center, Loja 25, Rio de Janeiro', ARRAY['CONTACTLESS', 'CHIP', 'MAGSTRIPE', 'NFC', 'QR_CODE'], 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', (SELECT id FROM merchants WHERE merchant_id = 'MERC003'), 'TERM004', 'SN123456792', 'POS-FUEL', 'Posto Gas - Estrada', 'BR-101, Km 45, Santos', ARRAY['CONTACTLESS', 'CHIP', 'FUEL_PUMP'], 'ACTIVE'),
('550e8400-e29b-41d4-a716-446655440000', (SELECT id FROM merchants WHERE merchant_id = 'MERC004'), 'TERM005', 'SN123456793', 'POS-HOTEL', 'Hotel Comfort - Recepção', 'Rua dos Hotéis, 789, Porto Alegre', ARRAY['CONTACTLESS', 'CHIP', 'MAGSTRIPE', 'ROOM_CHARGE'], 'ACTIVE');