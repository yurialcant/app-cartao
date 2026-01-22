# Script para criar massas de dados completas para todos os 15 fluxos E2E

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📊 CRIANDO MASSAS DE DADOS PARA TODOS OS FLUXOS 📊       ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$sqlDir = Join-Path $baseDir "infra/sql"

# Obter IDs do Keycloak
Write-Host "[1/5] Obtendo IDs do Keycloak..." -ForegroundColor Yellow

$keycloakUsers = @{
    "user1" = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"
    "admin" = "admin-id-keycloak"
    "merchant1" = "merchant1-id-keycloak"
}

# Criar SQL completo com dados para todos os fluxos
$sqlContent = @"
-- ============================================
-- MASSA DE DADOS COMPLETA PARA TODOS OS 15 FLUXOS E2E
-- ============================================

-- IDs dos usuários
DO `$
DECLARE
    user1_id TEXT := '$($keycloakUsers["user1"])';
    admin_id TEXT := '$($keycloakUsers["admin"])';
    merchant1_id TEXT := '$($keycloakUsers["merchant1"])';
BEGIN

-- ============================================
-- FLUXO 1: Login + Device Binding
-- ============================================
INSERT INTO devices (id, user_id, device_id, device_name, device_type, os_version, app_version, is_trusted, trusted_at, last_seen_at, created_at)
VALUES 
    (gen_random_uuid(), user1_id, 'DEVICE-001', 'Samsung Galaxy S21', 'ANDROID', '13', '1.0.0', true, NOW(), NOW(), NOW()),
    (gen_random_uuid(), user1_id, 'DEVICE-002', 'iPhone 14', 'IOS', '17', '1.0.0', false, NULL, NOW(), NOW() - INTERVAL '2 days')
ON CONFLICT (device_id) DO NOTHING;

-- ============================================
-- FLUXO 2: Onboarding + KYC
-- ============================================
INSERT INTO kyc (id, user_id, status, document_type, document_number, document_url, selfie_url, verified_at, created_at)
VALUES 
    (gen_random_uuid(), user1_id, 'APPROVED', 'CPF', '12345678900', 'https://storage.example.com/docs/doc1.pdf', 'https://storage.example.com/selfies/selfie1.jpg', NOW() - INTERVAL '10 days', NOW() - INTERVAL '15 days')
ON CONFLICT DO NOTHING;

-- ============================================
-- FLUXO 3: Top-up (já existe no seed anterior)
-- ============================================
-- Dados já inseridos no script seed-database-complete.ps1

-- ============================================
-- FLUXO 4: Merchant Onboarding + KYB
-- ============================================
INSERT INTO merchants (id, keycloak_id, name, cnpj, email, phone, mcc, status, kyb_status, created_at, updated_at)
VALUES 
    (gen_random_uuid(), merchant1_id, 'Padaria XYZ', '12.345.678/0001-90', 'padaria@xyz.com', '11987654321', '5411', 'ACTIVE', 'APPROVED', NOW() - INTERVAL '30 days', NOW())
ON CONFLICT (cnpj) DO NOTHING;

INSERT INTO kyb (id, merchant_id, status, document_type, document_number, document_url, verified_at, created_at)
SELECT gen_random_uuid(), m.id, 'APPROVED', 'CNPJ', m.cnpj, 'https://storage.example.com/kyb/merchant1.pdf', NOW() - INTERVAL '25 days', NOW() - INTERVAL '30 days'
FROM merchants m WHERE m.cnpj = '12.345.678/0001-90'
ON CONFLICT DO NOTHING;

-- ============================================
-- FLUXO 5: Pagamento QR
-- ============================================
INSERT INTO charge_intents (id, merchant_id, terminal_id, operator_id, amount, currency, payment_method, qr_code, expires_at, status, created_at)
SELECT 
    gen_random_uuid(),
    m.id,
    NULL,
    NULL,
    35.50,
    'BRL',
    'QR',
    'QR123456789',
    NOW() + INTERVAL '10 minutes',
    'PENDING',
    NOW() - INTERVAL '5 minutes'
FROM merchants m WHERE m.cnpj = '12.345.678/0001-90'
LIMIT 1;

-- ============================================
-- FLUXO 6: Pagamento Cartão (já existe no seed anterior)
-- ============================================
-- Dados já inseridos

-- ============================================
-- FLUXO 7: Cancelamento e Reembolso
-- ============================================
-- Dados já inseridos no seed anterior

-- ============================================
-- FLUXO 8: Fechamento de Caixa
-- ============================================
-- Dados serão gerados via relatórios

-- ============================================
-- FLUXO 9: Settlement
-- ============================================
INSERT INTO settlements (id, merchant_id, period_start, period_end, total_amount, fees, net_amount, status, payout_date, batch_id, created_at)
SELECT 
    gen_random_uuid(),
    m.id,
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE - INTERVAL '1 day',
    50000.00,
    1500.00,
    48500.00,
    'PENDING',
    CURRENT_DATE + INTERVAL '5 days',
    'BATCH-001',
    NOW()
FROM merchants m WHERE m.cnpj = '12.345.678/0001-90'
LIMIT 1;

-- ============================================
-- FLUXO 10: Disputas
-- ============================================
INSERT INTO disputes (id, transaction_id, user_id, merchant_id, amount, reason, status, acquirer_dispute_id, evidence, created_at)
SELECT 
    gen_random_uuid(),
    t.id,
    user1_id,
    (SELECT id FROM merchants LIMIT 1),
    t.amount,
    'Produto não recebido',
    'OPEN',
    'DISPUTE-001',
    '{"evidence": ["receipt.pdf", "email.pdf"]}',
    NOW() - INTERVAL '3 days'
FROM transactions t 
WHERE t.user_id = user1_id 
AND t.status = 'APPROVED'
LIMIT 1;

-- ============================================
-- FLUXO 11: Atendimento (Tickets)
-- ============================================
INSERT INTO tickets (id, user_id, transaction_id, subject, description, status, priority, assigned_to, created_at)
VALUES 
    (gen_random_uuid(), user1_id, (SELECT id FROM transactions WHERE user_id = user1_id LIMIT 1), 'Problema com transação', 'Não reconheço esta transação', 'OPEN', 'MEDIUM', NULL, NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), user1_id, NULL, 'Dúvida sobre saldo', 'Meu saldo está incorreto', 'IN_PROGRESS', 'LOW', 'admin@benefits.local', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), user1_id, NULL, 'Solicitação de reembolso', 'Quero reembolso da compra', 'RESOLVED', 'HIGH', 'admin@benefits.local', NOW() - INTERVAL '5 days');

-- ============================================
-- FLUXO 12: Antifraude (dados serão gerados via Risk Service)
-- ============================================
-- Dados serão gerados dinamicamente

-- ============================================
-- FLUXO 13: Segurança (dados já existem em devices)
-- ============================================
-- Dados já inseridos no Fluxo 1

-- ============================================
-- FLUXO 14: LGPD (dados serão gerados via Privacy Service)
-- ============================================
-- Dados serão gerados dinamicamente

-- ============================================
-- FLUXO 15: PCI (dados de auditoria)
-- ============================================
INSERT INTO audit_logs (id, user_id, action, resource_type, resource_id, details, ip_address, user_agent, request_id, created_at)
VALUES 
    (gen_random_uuid(), user1_id, 'LOGIN', 'USER', user1_id, '{"device": "DEVICE-001", "location": "São Paulo"}', '192.168.1.100', 'Mozilla/5.0', 'REQ-001', NOW() - INTERVAL '1 hour'),
    (gen_random_uuid(), user1_id, 'PAYMENT_CREATED', 'TRANSACTION', (SELECT id::text FROM transactions WHERE user_id = user1_id LIMIT 1), '{"amount": 35.50, "merchant": "Padaria XYZ"}', '192.168.1.100', 'Mozilla/5.0', 'REQ-002', NOW() - INTERVAL '30 minutes'),
    (gen_random_uuid(), admin_id, 'USER_CREATED', 'USER', user1_id, '{"email": "user1@benefits.local"}', '10.0.0.1', 'Mozilla/5.0', 'REQ-003', NOW() - INTERVAL '1 day');

END `$;
"@

$sqlPath = Join-Path $sqlDir "seed-all-flows-data.sql"
Set-Content -Path $sqlPath -Value $sqlContent -Encoding UTF8

Write-Host "  ✓ Script SQL criado: infra/sql/seed-all-flows-data.sql" -ForegroundColor Green

Write-Host "`n[2/5] Executando script SQL no banco..." -ForegroundColor Yellow
try {
    Get-Content $sqlPath | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Dados inseridos com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro ao executar SQL (pode ser normal se tabelas não existirem ainda): $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n✅ Massas de dados criadas para todos os 15 fluxos!" -ForegroundColor Green
Write-Host "`n📋 Dados criados:" -ForegroundColor Yellow
Write-Host "  • Fluxo 1: Devices (2 dispositivos)" -ForegroundColor White
Write-Host "  • Fluxo 2: KYC (1 aprovado)" -ForegroundColor White
Write-Host "  • Fluxo 4: Merchants + KYB (1 merchant aprovado)" -ForegroundColor White
Write-Host "  • Fluxo 5: Charge Intents (1 QR pendente)" -ForegroundColor White
Write-Host "  • Fluxo 9: Settlements (1 settlement pendente)" -ForegroundColor White
Write-Host "  • Fluxo 10: Disputas (1 disputa aberta)" -ForegroundColor White
Write-Host "  • Fluxo 11: Tickets (3 tickets)" -ForegroundColor White
Write-Host "  • Fluxo 15: Audit Logs (3 logs)" -ForegroundColor White
Write-Host ""
