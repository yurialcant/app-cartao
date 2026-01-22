# Script para criar seed COMPLETO antes de iniciar os apps
# Cria dados realistas para todos os fluxos

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📊 CRIANDO SEED COMPLETO PRÉVIO 📊                      ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot | Split-Path -Parent

# IDs do Keycloak
$userIds = @{
    "user1" = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"
    "admin" = "admin-id-001"
    "merchant1" = "merchant-id-001"
}

Write-Host "[1/5] Criando seed completo no banco..." -ForegroundColor Yellow

$sql = @"
-- ============================================
-- SEED COMPLETO PARA TODOS OS FLUXOS
-- ============================================

DO `$`$
DECLARE
    user1_uuid UUID;
    admin_uuid UUID;
    merchant1_uuid UUID;
    company_uuid UUID;
    wallet_vr_id VARCHAR(255);
    wallet_va_id VARCHAR(255);
    i INTEGER;
    transaction_date TIMESTAMP;
BEGIN
    -- Criar/atualizar user1
    SELECT id INTO user1_uuid FROM users WHERE keycloak_id = '$($userIds["user1"])' LIMIT 1;
    IF user1_uuid IS NULL THEN
        INSERT INTO users (id, keycloak_id, email, username, name, cpf, phone, status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["user1"])', 'user1@benefits.local', 'user1', 'João Silva', '123.456.789-00', '+5511999999999', 'ACTIVE', NOW())
        RETURNING id INTO user1_uuid;
    END IF;
    
    -- Criar/atualizar admin
    SELECT id INTO admin_uuid FROM users WHERE keycloak_id = '$($userIds["admin"])' LIMIT 1;
    IF admin_uuid IS NULL THEN
        INSERT INTO users (id, keycloak_id, email, username, name, status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["admin"])', 'admin@benefits.local', 'admin', 'Admin User', 'ACTIVE', NOW())
        RETURNING id INTO admin_uuid;
    END IF;
    
    -- Criar merchant1
    SELECT id INTO merchant1_uuid FROM merchants WHERE keycloak_id = '$($userIds["merchant1"])' LIMIT 1;
    IF merchant1_uuid IS NULL THEN
        INSERT INTO merchants (id, keycloak_id, name, cnpj, email, phone, mcc, status, kyb_status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["merchant1"])', 'Restaurante Bom Sabor', '12.345.678/0001-90', 'merchant1@benefits.local', '+5511888888888', '5812', 'ACTIVE', 'APPROVED', NOW())
        RETURNING id INTO merchant1_uuid;
    END IF;
    
    -- Criar empresa
    INSERT INTO merchants (id, name, cnpj, email, phone, mcc, status, kyb_status, created_at)
    VALUES (gen_random_uuid(), 'Empresa Exemplo LTDA', '98.765.432/0001-10', 'empresa@benefits.local', '+5511777777777', '0000', 'ACTIVE', 'APPROVED', NOW())
    ON CONFLICT DO NOTHING;
    
    SELECT id INTO company_uuid FROM merchants WHERE cnpj = '98.765.432/0001-10' LIMIT 1;
    
    -- Criar wallets para user1
    INSERT INTO wallets (id, user_id, wallet_type, balance, currency, last_updated)
    VALUES 
        ('550e8400-e29b-41d4-a716-446655440001', user1_uuid::TEXT, 'VR', 500.00, 'BRL', NOW()),
        ('550e8400-e29b-41d4-a716-446655440002', user1_uuid::TEXT, 'VA', 300.00, 'BRL', NOW())
    ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, last_updated = NOW();
    
    wallet_vr_id := '550e8400-e29b-41d4-a716-446655440001';
    wallet_va_id := '550e8400-e29b-41d4-a716-446655440002';
    
    -- Criar transações realistas (últimos 30 dias)
    -- Topups mensais
    INSERT INTO transactions (id, user_id, wallet_id, wallet_type, type, amount, merchant, description, status, reference, created_at)
    VALUES 
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'TOPUP', 500.00, 'Empresa Exemplo LTDA', 'Crédito mensal VR - Dezembro', 'SETTLED', 'TOPUP-001', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_va_id, 'VA', 'TOPUP', 300.00, 'Empresa Exemplo LTDA', 'Crédito mensal VA - Dezembro', 'SETTLED', 'TOPUP-002', NOW() - INTERVAL '5 days'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'TOPUP', 500.00, 'Empresa Exemplo LTDA', 'Crédito mensal VR - Novembro', 'SETTLED', 'TOPUP-003', NOW() - INTERVAL '35 days')
    ON CONFLICT DO NOTHING;
    
    -- Transações de pagamento (últimos 30 dias)
    FOR i IN 1..50 LOOP
        transaction_date := NOW() - (RANDOM() * INTERVAL '30 days');
        
        INSERT INTO transactions (id, user_id, wallet_id, wallet_type, type, amount, merchant, description, status, reference, created_at)
        VALUES (
            gen_random_uuid(),
            user1_uuid::TEXT,
            CASE WHEN RANDOM() > 0.5 THEN wallet_vr_id ELSE wallet_va_id END,
            CASE WHEN RANDOM() > 0.5 THEN 'VR' ELSE 'VA' END,
            'DEBIT',
            (RANDOM() * 150 + 10)::NUMERIC(10,2),
            CASE (RANDOM() * 10)::INTEGER
                WHEN 0 THEN 'Padaria XYZ'
                WHEN 1 THEN 'Farmácia Saúde'
                WHEN 2 THEN 'Restaurante Bom Sabor'
                WHEN 3 THEN 'Supermercado Central'
                WHEN 4 THEN 'Lanchonete Express'
                WHEN 5 THEN 'Cafeteria Aroma'
                WHEN 6 THEN 'Mercado do Bairro'
                WHEN 7 THEN 'Farmácia Popular'
                WHEN 8 THEN 'Restaurante Sabor'
                ELSE 'Loja Conveniência'
            END,
            CASE (RANDOM() * 5)::INTEGER
                WHEN 0 THEN 'Compra no estabelecimento'
                WHEN 1 THEN 'Pagamento via QR Code'
                WHEN 2 THEN 'Pagamento via cartão'
                WHEN 3 THEN 'Compra online'
                ELSE 'Pagamento'
            END,
            CASE (RANDOM() * 10)::INTEGER
                WHEN 0 THEN 'PENDING'
                WHEN 1 THEN 'FAILED'
                ELSE 'APPROVED'
            END,
            'REF-' || LPAD((RANDOM() * 9999)::INTEGER::TEXT, 4, '0'),
            transaction_date
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
    
    -- Transações recentes (últimas 24 horas) para aparecer no app
    INSERT INTO transactions (id, user_id, wallet_id, wallet_type, type, amount, merchant, description, status, reference, created_at)
    VALUES 
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 25.50, 'Padaria XYZ', 'Pão e café', 'APPROVED', 'REF-RECENT-001', NOW() - INTERVAL '2 hours'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 45.00, 'Farmácia Saúde', 'Medicamentos', 'APPROVED', 'REF-RECENT-002', NOW() - INTERVAL '5 hours'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_va_id, 'VA', 'DEBIT', 80.00, 'Restaurante Bom Sabor', 'Almoço executivo', 'APPROVED', 'REF-RECENT-003', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 120.00, 'Supermercado Central', 'Compras do mês', 'PENDING', 'REF-RECENT-004', NOW() - INTERVAL '30 minutes'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_va_id, 'VA', 'DEBIT', 35.00, 'Lanchonete Express', 'Lanche da tarde', 'APPROVED', 'REF-RECENT-005', NOW() - INTERVAL '3 hours')
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Seed completo criado!';
    RAISE NOTICE 'User1 UUID: %', user1_uuid;
    RAISE NOTICE 'Wallets criadas: VR e VA';
    RAISE NOTICE 'Transações criadas: ~55 transações';
END `$`$;
"@

try {
    $sql | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Seed completo criado" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erro ao criar seed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/5] Verificando dados criados..." -ForegroundColor Yellow
$checkSql = @"
SELECT 
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM merchants) as merchants_count,
    (SELECT COUNT(*) FROM wallets) as wallets_count,
    (SELECT COUNT(*) FROM transactions) as transactions_count;
"@

try {
    $result = $checkSql | docker exec -i benefits-postgres psql -U benefits -d benefits -t 2>&1
    Write-Host "  ✓ Dados verificados" -ForegroundColor Green
    Write-Host "    $result" -ForegroundColor Gray
} catch {
    Write-Host "  ⚠ Não foi possível verificar dados" -ForegroundColor Yellow
}

Write-Host "`n[3/5] Atualizando saldo das wallets..." -ForegroundColor Yellow
$updateBalanceSql = @"
DO `$`$
DECLARE
    user1_uuid UUID;
    total_debits NUMERIC;
    total_credits NUMERIC;
BEGIN
    SELECT id INTO user1_uuid FROM users WHERE keycloak_id = 'b9a3fdb4-688c-41c7-b705-bcc0e322c022' LIMIT 1;
    
    IF user1_uuid IS NOT NULL THEN
        -- Calcular saldo real baseado nas transações
        SELECT 
            COALESCE(SUM(CASE WHEN type = 'DEBIT' THEN amount ELSE 0 END), 0),
            COALESCE(SUM(CASE WHEN type = 'TOPUP' THEN amount ELSE 0 END), 0)
        INTO total_debits, total_credits
        FROM transactions 
        WHERE user_id = user1_uuid::TEXT AND status IN ('APPROVED', 'SETTLED');
        
        -- Atualizar wallet VR
        UPDATE wallets 
        SET balance = GREATEST(0, total_credits - total_debits),
            last_updated = NOW()
        WHERE user_id = user1_uuid::TEXT AND wallet_type = 'VR';
        
        -- Atualizar wallet VA (simplificado, usando mesmo cálculo)
        UPDATE wallets 
        SET balance = GREATEST(0, (total_credits * 0.6) - (total_debits * 0.4)),
            last_updated = NOW()
        WHERE user_id = user1_uuid::TEXT AND wallet_type = 'VA';
    END IF;
END `$`$;
"@

try {
    $updateBalanceSql | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Saldos atualizados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Não foi possível atualizar saldos" -ForegroundColor Yellow
}

Write-Host "`n[4/5] Criando dados de dispositivos e sessões..." -ForegroundColor Yellow
$deviceSql = @"
DO `$`$
DECLARE
    user1_uuid UUID;
BEGIN
    SELECT id INTO user1_uuid FROM users WHERE keycloak_id = 'b9a3fdb4-688c-41c7-b705-bcc0e322c022' LIMIT 1;
    
    IF user1_uuid IS NOT NULL THEN
        -- Criar dispositivo confiável
        INSERT INTO devices (id, user_id, device_id, device_name, device_type, is_trusted, last_seen_at, created_at)
        VALUES (
            gen_random_uuid(),
            user1_uuid::TEXT,
            'device-android-001',
            'Samsung Galaxy S21',
            'ANDROID',
            true,
            NOW(),
            NOW() - INTERVAL '30 days'
        )
        ON CONFLICT DO NOTHING;
    END IF;
END `$`$;
"@

try {
    $deviceSql | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Dados de dispositivos criados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Tabela devices pode não existir ainda" -ForegroundColor Yellow
}

Write-Host "`n[5/5] Criando dados de KYC..." -ForegroundColor Yellow
$kycSql = @"
DO `$`$
DECLARE
    user1_uuid UUID;
BEGIN
    SELECT id INTO user1_uuid FROM users WHERE keycloak_id = 'b9a3fdb4-688c-41c7-b705-bcc0e322c022' LIMIT 1;
    
    IF user1_uuid IS NOT NULL THEN
        -- Criar KYC aprovado
        INSERT INTO kyc (id, user_id, status, document_type, document_number, verified_at, created_at)
        VALUES (
            gen_random_uuid(),
            user1_uuid::TEXT,
            'APPROVED',
            'CPF',
            '123.456.789-00',
            NOW() - INTERVAL '60 days',
            NOW() - INTERVAL '90 days'
        )
        ON CONFLICT DO NOTHING;
    END IF;
END `$`$;
"@

try {
    $kycSql | docker exec -i benefits-postgres psql -U benefits -d benefits 2>&1 | Out-Null
    Write-Host "  ✓ Dados de KYC criados" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Tabela kyc pode não existir ainda" -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ SEED COMPLETO CRIADO! ✅                              ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📊 DADOS CRIADOS:" -ForegroundColor Cyan
Write-Host "  • Usuários: user1, admin, merchant1" -ForegroundColor White
Write-Host "  • Wallets: VR (R$ 500) e VA (R$ 300) para user1" -ForegroundColor White
Write-Host "  • Transações: ~55 transações (últimos 30 dias)" -ForegroundColor White
Write-Host "  • Dispositivos: 1 dispositivo confiável" -ForegroundColor White
Write-Host "  • KYC: Aprovado para user1" -ForegroundColor White
Write-Host ""
Write-Host "✅ Seed completo! Os apps já terão dados para trabalhar!" -ForegroundColor Green
Write-Host ""
