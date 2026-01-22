-- Script SQL para criar todas as tabelas do Core Service

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS uuid-ossp;

-- Tabela: users
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,\n    keycloakId VARCHAR(255) UNIQUE,\n    email VARCHAR(255),\n    name VARCHAR(255),\n    cpf VARCHAR(14),\n    phone VARCHAR(20),\n    status VARCHAR(50),\n    createdAt TIMESTAMP,\n    updatedAt TIMESTAMP
);

-- Índices para users
CREATE INDEX IF NOT EXISTS idx_users_keycloak_id ON users(keycloakId);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Tabela: merchants
CREATE TABLE IF NOT EXISTS merchants (
    id UUID PRIMARY KEY,\n    keycloakId VARCHAR(255) UNIQUE,\n    name VARCHAR(255),\n    cnpj VARCHAR(18),\n    email VARCHAR(255),\n    phone VARCHAR(20),\n    mcc VARCHAR(10),\n    status VARCHAR(50),\n    kybStatus VARCHAR(50),\n    createdAt TIMESTAMP,\n    updatedAt TIMESTAMP
);

-- Índices para merchants
CREATE INDEX IF NOT EXISTS idx_merchants_keycloak_id ON merchants(keycloakId);
CREATE INDEX IF NOT EXISTS idx_merchants_cnpj ON merchants(cnpj);

-- Tabela: terminals
CREATE TABLE IF NOT EXISTS terminals (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    terminalId VARCHAR(100) UNIQUE,\n    name VARCHAR(255),\n    location VARCHAR(255),\n    status VARCHAR(50),\n    boundAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para terminals

-- Tabela: operators
CREATE TABLE IF NOT EXISTS operators (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    terminalId UUID REFERENCES terminals(id),\n    keycloakId VARCHAR(255),\n    name VARCHAR(255),\n    pinHash VARCHAR(255),\n    role VARCHAR(50),\n    status VARCHAR(50),\n    createdAt TIMESTAMP
);

-- Índices para operators

-- Tabela: charge_intents
CREATE TABLE IF NOT EXISTS charge_intents (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    terminalId UUID REFERENCES terminals(id),\n    operatorId UUID REFERENCES operators(id),\n    amount DECIMAL(19,2),\n    currency VARCHAR(3),\n    paymentMethod VARCHAR(50),\n    qrCode TEXT,\n    expiresAt TIMESTAMP,\n    status VARCHAR(50),\n    createdAt TIMESTAMP
);

-- Índices para charge_intents

-- Tabela: payments
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY,\n    chargeIntentId UUID REFERENCES charge_intents(id),\n    transactionId UUID REFERENCES transactions(id),\n    userId VARCHAR(255),\n    merchantId UUID REFERENCES merchants(id),\n    amount DECIMAL(19,2),\n    currency VARCHAR(3),\n    paymentMethod VARCHAR(50),\n    status VARCHAR(50),\n    acquirerTxnId VARCHAR(255),\n    authCode VARCHAR(50),\n    processedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para payments

-- Tabela: refunds
CREATE TABLE IF NOT EXISTS refunds (
    id UUID PRIMARY KEY,\n    paymentId UUID REFERENCES payments(id),\n    transactionId UUID REFERENCES transactions(id),\n    amount DECIMAL(19,2),\n    reason VARCHAR(255),\n    status VARCHAR(50),\n    acquirerRefundId VARCHAR(255),\n    processedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para refunds

-- Tabela: disputes
CREATE TABLE IF NOT EXISTS disputes (
    id UUID PRIMARY KEY,\n    transactionId UUID REFERENCES transactions(id),\n    userId VARCHAR(255),\n    merchantId UUID REFERENCES merchants(id),\n    amount DECIMAL(19,2),\n    reason VARCHAR(255),\n    status VARCHAR(50),\n    acquirerDisputeId VARCHAR(255),\n    evidence TEXT,\n    resolvedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para disputes

-- Tabela: tickets
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY,\n    userId VARCHAR(255),\n    transactionId UUID REFERENCES transactions(id),\n    subject VARCHAR(255),\n    description TEXT,\n    status VARCHAR(50),\n    priority VARCHAR(50),\n    assignedTo VARCHAR(255),\n    resolvedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para tickets

-- Tabela: devices
CREATE TABLE IF NOT EXISTS devices (
    id UUID PRIMARY KEY,\n    userId VARCHAR(255),\n    deviceId VARCHAR(255) UNIQUE,\n    deviceName VARCHAR(255),\n    deviceType VARCHAR(50),\n    osVersion VARCHAR(50),\n    appVersion VARCHAR(50),\n    isTrusted BOOLEAN,\n    trustedAt TIMESTAMP,\n    lastSeenAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para devices
CREATE INDEX IF NOT EXISTS idx_devices_user_id ON devices(userId);
CREATE INDEX IF NOT EXISTS idx_devices_device_id ON devices(deviceId);

-- Tabela: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY,\n    userId VARCHAR(255),\n    action VARCHAR(100),\n    resourceType VARCHAR(50),\n    resourceId VARCHAR(255),\n    details TEXT,\n    ipAddress VARCHAR(45),\n    userAgent TEXT,\n    requestId VARCHAR(255),\n    createdAt TIMESTAMP
);

-- Índices para audit_logs
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(userId);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(createdAt DESC);

-- Tabela: settlements
CREATE TABLE IF NOT EXISTS settlements (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    periodStart DATE,\n    periodEnd DATE,\n    totalAmount DECIMAL(19,2),\n    fees DECIMAL(19,2),\n    netAmount DECIMAL(19,2),\n    status VARCHAR(50),\n    payoutDate DATE,\n    batchId VARCHAR(255),\n    createdAt TIMESTAMP
);

-- Índices para settlements

-- Tabela: reconciliations
CREATE TABLE IF NOT EXISTS reconciliations (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    acquirer VARCHAR(50),\n    periodStart DATE,\n    periodEnd DATE,\n    expectedAmount DECIMAL(19,2),\n    actualAmount DECIMAL(19,2),\n    difference DECIMAL(19,2),\n    status VARCHAR(50),\n    fileUrl VARCHAR(500),\n    processedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para reconciliations

-- Tabela: topup_batches
CREATE TABLE IF NOT EXISTS topup_batches (
    id UUID PRIMARY KEY,\n    employerId VARCHAR(255),\n    batchNumber VARCHAR(100) UNIQUE,\n    totalAmount DECIMAL(19,2),\n    totalUsers INTEGER,\n    status VARCHAR(50),\n    approvedBy VARCHAR(255),\n    approvedAt TIMESTAMP,\n    executedAt TIMESTAMP,\n    createdAt TIMESTAMP
);

-- Índices para topup_batches

-- Tabela: kyc
CREATE TABLE IF NOT EXISTS kyc (
    id UUID PRIMARY KEY,\n    userId VARCHAR(255),\n    status VARCHAR(50),\n    documentType VARCHAR(50),\n    documentNumber VARCHAR(100),\n    documentUrl VARCHAR(500),\n    selfieUrl VARCHAR(500),\n    verifiedAt TIMESTAMP,\n    rejectedReason TEXT,\n    createdAt TIMESTAMP
);

-- Índices para kyc

-- Tabela: kyb
CREATE TABLE IF NOT EXISTS kyb (
    id UUID PRIMARY KEY,\n    merchantId UUID REFERENCES merchants(id),\n    status VARCHAR(50),\n    documentType VARCHAR(50),\n    documentNumber VARCHAR(100),\n    documentUrl VARCHAR(500),\n    verifiedAt TIMESTAMP,\n    rejectedReason TEXT,\n    createdAt TIMESTAMP
);

-- Índices para kyb


