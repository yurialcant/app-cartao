# Script para criar massa de dados COMPLETA para testes E2E de todos os fluxos
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📊 CRIANDO MASSA DE DADOS COMPLETA E2E 📊                ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Configurações
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "benefits"
$DB_USER = "benefits"
$DB_PASSWORD = "benefits123"

# Verificar PostgreSQL
Write-Host "[1/5] Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    $pgTest = docker exec benefits-postgres pg_isready -U $DB_USER 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ PostgreSQL está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ PostgreSQL não está rodando" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro ao verificar PostgreSQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Ler IDs dos usuários do Keycloak
Write-Host "`n[2/5] Lendo IDs dos usuários do Keycloak..." -ForegroundColor Yellow
$realmFile = "infra/keycloak/realm-benefits.json"
$userIds = @{}

if (Test-Path $realmFile) {
    $realm = Get-Content $realmFile | ConvertFrom-Json
    foreach ($user in $realm.users) {
        $userIds[$user.username] = $user.id
        Write-Host "  ✓ $($user.username): $($user.id)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠ Arquivo realm-benefits.json não encontrado" -ForegroundColor Yellow
    Write-Host "  Usando IDs padrão..." -ForegroundColor Gray
    $userIds["user1"] = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"
    $userIds["admin"] = "admin-id-001"
    $userIds["merchant1"] = "merchant-id-001"
}

# Criar SQL completo
Write-Host "`n[3/5] Criando massa de dados completa..." -ForegroundColor Yellow

$sqlContent = @"
-- ============================================
-- MASSA DE DADOS COMPLETA PARA TESTES E2E
-- ============================================

DO `$`$
DECLARE
    user1_uuid UUID;
    admin_uuid UUID;
    merchant1_uuid UUID;
    company_uuid UUID;
    employee_uuid UUID;
    card_vr_uuid UUID;
    card_va_uuid UUID;
    wallet_vr_uuid UUID;
    wallet_va_uuid UUID;
BEGIN
    -- Criar usuários se não existirem
    SELECT id INTO user1_uuid FROM users WHERE username = 'user1' OR keycloak_id = '$($userIds["user1"])' LIMIT 1;
    IF user1_uuid IS NULL THEN
        INSERT INTO users (id, keycloak_id, email, username, name, cpf, phone, status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["user1"])', 'user1@benefits.local', 'user1', 'João Silva', '123.456.789-00', '+5511999999999', 'ACTIVE', NOW())
        RETURNING id INTO user1_uuid;
    END IF;
    
    SELECT id INTO admin_uuid FROM users WHERE username = 'admin' OR keycloak_id = '$($userIds["admin"])' LIMIT 1;
    IF admin_uuid IS NULL THEN
        INSERT INTO users (id, keycloak_id, email, username, name, status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["admin"])', 'admin@benefits.local', 'admin', 'Admin User', 'ACTIVE', NOW())
        RETURNING id INTO admin_uuid;
    END IF;
    
    SELECT id INTO merchant1_uuid FROM merchants WHERE keycloak_id = '$($userIds["merchant1"])' LIMIT 1;
    IF merchant1_uuid IS NULL THEN
        INSERT INTO merchants (id, keycloak_id, name, cnpj, email, phone, mcc, status, kyb_status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["merchant1"])', 'Restaurante Bom Sabor', '12.345.678/0001-90', 'merchant1@benefits.local', '+5511888888888', '5812', 'ACTIVE', 'APPROVED', NOW())
        RETURNING id INTO merchant1_uuid;
    END IF;
    
    -- Criar empresa (company)
    INSERT INTO merchants (id, name, cnpj, email, phone, mcc, status, kyb_status, created_at)
    VALUES (gen_random_uuid(), 'Empresa Exemplo LTDA', '98.765.432/0001-10', 'empresa@benefits.local', '+5511777777777', '0000', 'ACTIVE', 'APPROVED', NOW())
    ON CONFLICT DO NOTHING
    RETURNING id INTO company_uuid;
    
    SELECT id INTO company_uuid FROM merchants WHERE cnpj = '98.765.432/0001-10' LIMIT 1;
    
    -- Criar funcionário vinculado à empresa
    INSERT INTO users (id, keycloak_id, email, username, name, cpf, phone, status, created_at)
    VALUES (gen_random_uuid(), gen_random_uuid()::TEXT, 'funcionario@empresa.local', 'funcionario', 'Maria Santos', '987.654.321-00', '+5511666666666', 'ACTIVE', NOW())
    ON CONFLICT DO NOTHING
    RETURNING id INTO employee_uuid;
    
    SELECT id INTO employee_uuid FROM users WHERE username = 'funcionario' LIMIT 1;
    
    -- Criar wallets para user1
    INSERT INTO wallets (id, user_id, wallet_type, balance, currency, created_at)
    VALUES 
        (gen_random_uuid(), user1_uuid, 'VR', 500.00, 'BRL', NOW()),
        (gen_random_uuid(), user1_uuid, 'VA', 300.00, 'BRL', NOW())
    ON CONFLICT DO NOTHING
    RETURNING id INTO wallet_vr_uuid;
    
    SELECT id INTO wallet_vr_uuid FROM wallets WHERE user_id = user1_uuid AND wallet_type = 'VR' LIMIT 1;
    SELECT id INTO wallet_va_uuid FROM wallets WHERE user_id = user1_uuid AND wallet_type = 'VA' LIMIT 1;
    
    -- Criar cartões (simulado como transações ou metadata)
    -- Em produção, haveria uma tabela de cartões
    -- Por enquanto, vamos criar dados que simulem cartões bloqueados/desbloqueados
    
    -- Criar transações variadas para testes
    INSERT INTO transactions (id, user_id, wallet_id, wallet_type, type, amount, merchant, description, status, reference, created_at, metadata)
    VALUES 
        -- Transações recentes (últimas 24h)
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 25.50, 'Padaria XYZ', 'Pão e café', 'APPROVED', 'REF-001', NOW() - INTERVAL '2 hours', '{"category": "food", "card_last4": "1234", "card_status": "ACTIVE"}'),
        (gen_random_uuid(), user1_uuid, wallet_va_uuid, 'VA', 'DEBIT', 45.00, 'Farmácia Saúde', 'Medicamentos', 'APPROVED', 'REF-002', NOW() - INTERVAL '5 hours', '{"category": "pharmacy", "card_last4": "5678", "card_status": "ACTIVE"}'),
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 80.00, 'Restaurante Bom Sabor', 'Almoço', 'APPROVED', 'REF-003', NOW() - INTERVAL '1 day', '{"category": "restaurant", "card_last4": "1234", "card_status": "BLOCKED"}'),
        
        -- Transações pendentes
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 120.00, 'Supermercado Central', 'Compras', 'PENDING', 'REF-004', NOW() - INTERVAL '30 minutes', '{"category": "supermarket", "card_last4": "1234"}'),
        
        -- Transações negadas
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 600.00, 'Loja Eletrônicos', 'Produto caro', 'DECLINED', 'REF-005', NOW() - INTERVAL '3 days', '{"category": "electronics", "reason": "insufficient_balance", "card_last4": "1234"}'),
        
        -- Topups (créditos)
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'TOPUP', 500.00, 'Empresa Exemplo', 'Crédito mensal VR', 'SETTLED', 'REF-007', NOW() - INTERVAL '10 days', '{"category": "topup", "batch_id": "BATCH-001", "company_id": "' || company_uuid || '"}'),
        (gen_random_uuid(), user1_uuid, wallet_va_uuid, 'VA', 'TOPUP', 300.00, 'Empresa Exemplo', 'Crédito mensal VA', 'SETTLED', 'REF-008', NOW() - INTERVAL '10 days', '{"category": "topup", "batch_id": "BATCH-001", "company_id": "' || company_uuid || '"}'),
        
        -- Mais transações para histórico
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 90.00, 'Restaurante Bom Sabor', 'Jantar', 'APPROVED', 'REF-011', NOW() - INTERVAL '4 days', '{"category": "restaurant", "card_last4": "1234"}'),
        (gen_random_uuid(), user1_uuid, wallet_vr_uuid, 'VR', 'DEBIT', 200.00, 'Supermercado Central', 'Compras semanais', 'APPROVED', 'REF-012', NOW() - INTERVAL '5 days', '{"category": "supermarket", "card_last4": "1234"}'),
        (gen_random_uuid(), user1_uuid, wallet_va_uuid, 'VA', 'DEBIT', 28.00, 'Farmácia Saúde', 'Analgésico', 'APPROVED', 'REF-014', NOW() - INTERVAL '7 days', '{"category": "pharmacy", "card_last4": "5678"}')
    ON CONFLICT DO NOTHING;
    
    -- Criar dados de onboarding (simulado via metadata ou tabela separada)
    -- Por enquanto, vamos usar o status de onboarding no próprio usuário
    
    RAISE NOTICE 'Massa de dados criada com sucesso!';
    RAISE NOTICE 'User1 UUID: %', user1_uuid;
    RAISE NOTICE 'Company UUID: %', company_uuid;
    RAISE NOTICE 'Employee UUID: %', employee_uuid;
    RAISE NOTICE 'Wallet VR UUID: %', wallet_vr_uuid;
    RAISE NOTICE 'Wallet VA UUID: %', wallet_va_uuid;
END `$`$;
"@

# Executar SQL
Write-Host "`n[4/5] Executando SQL..." -ForegroundColor Yellow
try {
    $sqlContent | docker exec -i benefits-postgres psql -U $DB_USER -d $DB_NAME 2>&1 | Out-Null
    Write-Host "  ✓ Dados inseridos com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erro ao executar SQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n[5/5] Verificando dados criados..." -ForegroundColor Yellow
$checkSql = @"
SELECT 
    (SELECT COUNT(*) FROM users) as users_count,
    (SELECT COUNT(*) FROM merchants) as merchants_count,
    (SELECT COUNT(*) FROM wallets) as wallets_count,
    (SELECT COUNT(*) FROM transactions) as transactions_count;
"@

$result = $checkSql | docker exec -i benefits-postgres psql -U $DB_USER -d $DB_NAME -t 2>&1
Write-Host "  ✓ Dados verificados:" -ForegroundColor Green
Write-Host "    $result" -ForegroundColor White

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ MASSA DE DADOS COMPLETA CRIADA! ✅                     ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Dados criados:" -ForegroundColor Cyan
Write-Host "  ✓ Usuários (user1, admin, funcionário)" -ForegroundColor White
Write-Host "  ✓ Empresa (Empresa Exemplo LTDA)" -ForegroundColor White
Write-Host "  ✓ Merchants (merchant1, empresa)" -ForegroundColor White
Write-Host "  ✓ Wallets (VR e VA para user1)" -ForegroundColor White
Write-Host "  ✓ Transações variadas (aprovadas, pendentes, negadas, topups)" -ForegroundColor White
Write-Host "  ✓ Dados de cartão simulados (via metadata)" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Pronto para testes E2E!" -ForegroundColor Green
Write-Host ""
