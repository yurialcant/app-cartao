# Script para gerar SQL completo com massa de dados para TODAS as jornadas

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot
$outputFile = Join-Path $script:RootPath "scripts\seed-database-complete-all-journeys.sql"

Write-Host "`n[GERAR SQL] Criando script SQL completo para todas as jornadas..." -ForegroundColor Cyan

$sql = @"
-- ============================================================
-- MASSA DE DADOS COMPLETA - TODAS AS JORNADAS E2E
-- ============================================================

-- Limpar dados existentes (cuidado em produção!)
TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE wallets CASCADE;
TRUNCATE TABLE charge_intents CASCADE;
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE refunds CASCADE;
TRUNCATE TABLE disputes CASCADE;
TRUNCATE TABLE tickets CASCADE;
TRUNCATE TABLE devices CASCADE;
TRUNCATE TABLE topup_batches CASCADE;
TRUNCATE TABLE settlements CASCADE;
TRUNCATE TABLE reconciliations CASCADE;
TRUNCATE TABLE kyc CASCADE;
TRUNCATE TABLE kyb CASCADE;
TRUNCATE TABLE audit_logs CASCADE;

-- ============================================================
-- TENANTS (Multi-Tenant)
-- ============================================================
INSERT INTO tenants (id, name, domain, status, created_at) VALUES
('tenant-001', 'Empresa A', 'empresa-a.benefits.test', 'ACTIVE', NOW()),
('tenant-002', 'Empresa B', 'empresa-b.benefits.test', 'ACTIVE', NOW()),
('default', 'Default Tenant', 'api.benefits.test', 'ACTIVE', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- USUÁRIOS E CARTEIRAS (Jornadas Beneficiário)
-- ============================================================
-- User 1 - Jornadas completas
INSERT INTO wallets (id, user_id, tenant_id, balance, currency, last_updated, version) VALUES
('wallet-user1-vr', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'default', 500.00, 'BRL', NOW(), 1),
('wallet-user1-va', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'default', 300.00, 'BRL', NOW(), 1)
ON CONFLICT DO NOTHING;

-- User 2 - Para testes de split tender
INSERT INTO wallets (id, user_id, tenant_id, balance, currency, last_updated, version) VALUES
('wallet-user2-vr', 'user2-id-001', 'default', 200.00, 'BRL', NOW(), 1)
ON CONFLICT DO NOTHING;

-- ============================================================
-- MERCHANTS E TERMINAIS (Jornadas Merchant)
-- ============================================================
INSERT INTO merchants (id, tenant_id, name, cnpj, status, category, mcc, created_at) VALUES
('merchant-001', 'default', 'Restaurante Teste', '12345678000190', 'ACTIVE', 'RESTAURANT', '5812', NOW()),
('merchant-002', 'default', 'Supermercado Teste', '98765432000110', 'ACTIVE', 'SUPERMARKET', '5411', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO terminals (id, merchant_id, tenant_id, name, status, created_at) VALUES
('terminal-001', 'merchant-001', 'default', 'Terminal Caixa 1', 'ACTIVE', NOW()),
('terminal-002', 'merchant-001', 'default', 'Terminal Caixa 2', 'ACTIVE', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO operators (id, merchant_id, tenant_id, username, role, status, created_at) VALUES
('operator-001', 'merchant-001', 'default', 'caixa1', 'OPERATOR', 'ACTIVE', NOW()),
('operator-002', 'merchant-001', 'default', 'supervisor1', 'SUPERVISOR', 'ACTIVE', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- TRANSAÇÕES (Todas as jornadas)
-- ============================================================
-- Transações para jornada de extrato
INSERT INTO transactions (id, tenant_id, user_id, wallet_id, type, amount, currency, status, merchant, description, created_at, metadata) VALUES
('txn-001', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'wallet-user1-vr', 'PAYMENT', 25.50, 'BRL', 'SETTLED', '{"name":"Restaurante Teste","id":"merchant-001"}'::jsonb, 'Almoço', NOW() - INTERVAL '2 days', '{}'::jsonb),
('txn-002', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'wallet-user1-va', 'PAYMENT', 15.00, 'BRL', 'SETTLED', '{"name":"Supermercado Teste","id":"merchant-002"}'::jsonb, 'Compra', NOW() - INTERVAL '1 day', '{}'::jsonb),
('txn-003', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'wallet-user1-vr', 'PAYMENT', 50.00, 'BRL', 'PENDING', '{"name":"Restaurante Teste","id":"merchant-001"}'::jsonb, 'Jantar', NOW(), '{}'::jsonb),
('txn-004', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'wallet-user1-vr', 'REFUND', 10.00, 'BRL', 'SETTLED', '{"name":"Restaurante Teste","id":"merchant-001"}'::jsonb, 'Reembolso', NOW() - INTERVAL '3 hours', '{}'::jsonb)
ON CONFLICT DO NOTHING;

-- ============================================================
-- CHARGE INTENTS (Jornada QR Payment)
-- ============================================================
INSERT INTO charge_intents (id, tenant_id, merchant_id, terminal_id, amount, currency, status, expires_at, created_at) VALUES
('charge-001', 'default', 'merchant-001', 'terminal-001', 25.50, 'BRL', 'PENDING', NOW() + INTERVAL '5 minutes', NOW()),
('charge-002', 'default', 'merchant-001', 'terminal-001', 50.00, 'BRL', 'COMPLETED', NOW() + INTERVAL '10 minutes', NOW() - INTERVAL '5 minutes')
ON CONFLICT DO NOTHING;

-- ============================================================
-- PAYMENTS (Jornada Payment Orchestration)
-- ============================================================
INSERT INTO payments (id, tenant_id, transaction_id, charge_intent_id, amount, currency, status, payment_method, created_at) VALUES
('payment-001', 'default', 'txn-001', 'charge-002', 25.50, 'BRL', 'CAPTURED', 'QR_CODE', NOW() - INTERVAL '5 minutes')
ON CONFLICT DO NOTHING;

-- ============================================================
-- DEVICES (Jornada Device Binding)
-- ============================================================
INSERT INTO devices (id, tenant_id, user_id, device_id, device_name, device_type, status, trusted, created_at) VALUES
('device-001', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'android-device-001', 'Samsung Galaxy', 'ANDROID', 'ACTIVE', true, NOW() - INTERVAL '30 days'),
('device-002', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'ios-device-001', 'iPhone 14', 'IOS', 'ACTIVE', false, NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TICKETS (Jornada Support)
-- ============================================================
INSERT INTO tickets (id, tenant_id, user_id, transaction_id, subject, status, priority, created_at) VALUES
('ticket-001', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'txn-001', 'Problema com compra', 'OPEN', 'MEDIUM', NOW() - INTERVAL '2 hours'),
('ticket-002', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'txn-002', 'Reembolso não recebido', 'RESOLVED', 'HIGH', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TOPUP BATCHES (Jornada Employer)
-- ============================================================
INSERT INTO topup_batches (id, tenant_id, employer_id, total_amount, currency, status, created_at, approved_at) VALUES
('topup-batch-001', 'default', 'employer-001', 10000.00, 'BRL', 'APPROVED', NOW() - INTERVAL '7 days', NOW() - INTERVAL '6 days'),
('topup-batch-002', 'default', 'employer-001', 5000.00, 'BRL', 'PENDING', NOW(), NULL)
ON CONFLICT DO NOTHING;

-- ============================================================
-- KYC/KYB (Jornadas Onboarding)
-- ============================================================
INSERT INTO kyc (id, tenant_id, user_id, status, level, created_at) VALUES
('kyc-001', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'APPROVED', 'BASIC', NOW() - INTERVAL '30 days')
ON CONFLICT DO NOTHING;

INSERT INTO kyb (id, tenant_id, merchant_id, status, created_at) VALUES
('kyb-001', 'default', 'merchant-001', 'APPROVED', NOW() - INTERVAL '60 days')
ON CONFLICT DO NOTHING;

-- ============================================================
-- SETTLEMENTS (Jornada Settlement)
-- ============================================================
INSERT INTO settlements (id, tenant_id, merchant_id, period_start, period_end, total_amount, status, created_at) VALUES
('settlement-001', 'default', 'merchant-001', NOW() - INTERVAL '7 days', NOW(), 5000.00, 'PROCESSED', NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- ============================================================
-- AUDIT LOGS (Jornada Auditoria)
-- ============================================================
INSERT INTO audit_logs (id, tenant_id, user_id, action, resource_type, resource_id, details, created_at) VALUES
('audit-001', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'LOGIN', 'USER', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', '{"ip":"192.168.1.1"}'::jsonb, NOW() - INTERVAL '1 hour'),
('audit-002', 'default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'PAYMENT', 'TRANSACTION', 'txn-001', '{"amount":25.50}'::jsonb, NOW() - INTERVAL '2 days')
ON CONFLICT DO NOTHING;

-- ============================================================
-- FIM DA MASSA DE DADOS
-- ============================================================
"@

$sql | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "✅ Script SQL completo gerado: $outputFile" -ForegroundColor Green
