# Script para popular banco de dados com massa de dados COMPLETA para todos os fluxos
Write-Host "=== Populando Banco de Dados com Massa de Dados COMPLETA ===" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Configurações
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "benefits"
$DB_USER = "benefits"
$DB_PASSWORD = "benefits123"

# Verificar se PostgreSQL está rodando
Write-Host "`n[1/4] Verificando PostgreSQL..." -ForegroundColor Yellow
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
Write-Host "`n[2/4] Lendo IDs dos usuários do Keycloak..." -ForegroundColor Yellow
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

# Criar SQL completo com massa de dados
Write-Host "`n[3/4] Criando massa de dados completa..." -ForegroundColor Yellow

$sqlContent = @"
-- ============================================
-- MASSA DE DADOS COMPLETA PARA TODOS OS FLUXOS
-- ============================================

-- Limpar dados existentes (opcional)
-- TRUNCATE TABLE transactions CASCADE;
-- TRUNCATE TABLE wallets CASCADE;

-- IDs dos usuários (substituir pelos IDs reais do Keycloak)
DO \$\$
DECLARE
    user1_id TEXT := '$($userIds["user1"])';
    admin_id TEXT := '$($userIds["admin"])';
    merchant1_id TEXT := '$($userIds["merchant1"])';
BEGIN
    -- ============================================
    -- WALLETS - Para todos os usuários
    -- ============================================
    
    -- Wallets para user1 (VR e VA)
    INSERT INTO wallets (id, "userId", type, balance, currency, "lastUpdated")
    VALUES 
        ('550e8400-e29b-41d4-a716-446655440001', user1_id, 'VR', 500.00, 'BRL', NOW()),
        ('550e8400-e29b-41d4-a716-446655440002', user1_id, 'VA', 300.00, 'BRL', NOW())
    ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, "lastUpdated" = NOW();
    
    -- Wallets para admin (se necessário)
    INSERT INTO wallets (id, "userId", type, balance, currency, "lastUpdated")
    VALUES 
        ('550e8400-e29b-41d4-a716-446655440003', admin_id, 'VR', 1000.00, 'BRL', NOW())
    ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, "lastUpdated" = NOW();
    
    -- Wallets para merchant1 (se necessário)
    INSERT INTO wallets (id, "userId", type, balance, currency, "lastUpdated")
    VALUES 
        ('550e8400-e29b-41d4-a716-446655440004', merchant1_id, 'MERCHANT', 5000.00, 'BRL', NOW())
    ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, "lastUpdated" = NOW();
    
    -- ============================================
    -- TRANSAÇÕES - Fluxo 1: Login + Home + Detalhe
    -- ============================================
    
    -- Transações aprovadas recentes (últimas 24h)
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 25.50, 'Padaria XYZ', 'Pão e café da manhã', NOW() - INTERVAL '2 hours', 'APPROVED', 'REF-001', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "food", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 45.00, 'Farmácia Saúde', 'Medicamentos', NOW() - INTERVAL '5 hours', 'APPROVED', 'REF-002', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "pharmacy", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 80.00, 'Restaurante Bom Sabor', 'Almoço', NOW() - INTERVAL '1 day', 'APPROVED', 'REF-003', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "restaurant", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 15.00, 'Padaria XYZ', 'Café', NOW() - INTERVAL '2 days', 'APPROVED', 'REF-009', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "food", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 35.00, 'Farmácia Saúde', 'Vitamina C', NOW() - INTERVAL '3 days', 'APPROVED', 'REF-010', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "pharmacy", "location": "São Paulo"}');
    
    -- Transação pendente (para testar status)
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 120.00, 'Supermercado Central', 'Compras do mês', NOW() - INTERVAL '30 minutes', 'PENDING', 'REF-004', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "supermarket", "location": "São Paulo"}');
    
    -- Transação negada (para testar fluxo de erro)
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 600.00, 'Loja de Eletrônicos', 'Produto caro', NOW() - INTERVAL '3 days', 'DECLINED', 'REF-005', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "electronics", "reason": "insufficient_balance"}');
    
    -- Transação reembolsada (para testar fluxo de refund)
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 50.00, 'Pet Shop', 'Ração para cachorro', NOW() - INTERVAL '7 days', 'REFUNDED', 'REF-006', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "petshop", "refund_reason": "product_return"}');
    
    -- Topups (créditos) - Fluxo 3: Carga/Top-up
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'TOPUP', 500.00, 'Empresa', 'Crédito mensal VR', NOW() - INTERVAL '10 days', 'SETTLED', 'REF-007', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "topup", "batch_id": "BATCH-001"}'),
        (gen_random_uuid(), user1_id, 'TOPUP', 300.00, 'Empresa', 'Crédito mensal VA', NOW() - INTERVAL '10 days', 'SETTLED', 'REF-008', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "topup", "batch_id": "BATCH-001"}');
    
    -- Mais transações para histórico completo
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 90.00, 'Restaurante Bom Sabor', 'Jantar', NOW() - INTERVAL '4 days', 'APPROVED', 'REF-011', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "restaurant", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 200.00, 'Supermercado Central', 'Compras semanais', NOW() - INTERVAL '5 days', 'APPROVED', 'REF-012', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "supermarket", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 12.00, 'Padaria XYZ', 'Pão de forma', NOW() - INTERVAL '6 days', 'APPROVED', 'REF-013', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "food", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 28.00, 'Farmácia Saúde', 'Analgésico', NOW() - INTERVAL '7 days', 'APPROVED', 'REF-014', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "pharmacy", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 65.00, 'Restaurante Bom Sabor', 'Almoço executivo', NOW() - INTERVAL '8 days', 'APPROVED', 'REF-015', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "restaurant", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 150.00, 'Posto de Gasolina', 'Combustível', NOW() - INTERVAL '9 days', 'APPROVED', 'REF-016', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "gas_station", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 75.00, 'Cinema', 'Ingressos', NOW() - INTERVAL '10 days', 'APPROVED', 'REF-017', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "entertainment", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 30.00, 'Farmácia Saúde', 'Suplementos', NOW() - INTERVAL '11 days', 'APPROVED', 'REF-018', '550e8400-e29b-41d4-a716-446655440002', 'VA', '{"category": "pharmacy", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 95.00, 'Restaurante Bom Sabor', 'Jantar com amigos', NOW() - INTERVAL '12 days', 'APPROVED', 'REF-019', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "restaurant", "location": "São Paulo"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 180.00, 'Supermercado Central', 'Compras mensais', NOW() - INTERVAL '13 days', 'APPROVED', 'REF-020', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"category": "supermarket", "location": "São Paulo"}');
    
    -- ============================================
    -- TRANSAÇÕES - Fluxo 5: Pagamento QR
    -- ============================================
    
    -- Transações QR para testar fluxo de pagamento
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 35.50, 'QR Merchant 1', 'Pagamento QR - Lanchonete', NOW() - INTERVAL '1 hour', 'APPROVED', 'QR-001', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "qr", "qr_code": "QR123456", "merchant_id": "MERCHANT-001"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 120.00, 'QR Merchant 2', 'Pagamento QR - Supermercado', NOW() - INTERVAL '6 hours', 'APPROVED', 'QR-002', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "qr", "qr_code": "QR789012", "merchant_id": "MERCHANT-002"}');
    
    -- ============================================
    -- TRANSAÇÕES - Fluxo 6: Pagamento Cartão
    -- ============================================
    
    -- Transações cartão para testar fluxo de adquirente
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 250.00, 'Card Merchant 1', 'Pagamento Cartão - Loja', NOW() - INTERVAL '2 days', 'APPROVED', 'CARD-001', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "card", "acquirer": "cielo", "acquirer_txn_id": "CIELO-123456", "card_last4": "1234"}'),
        (gen_random_uuid(), user1_id, 'DEBIT', 180.00, 'Card Merchant 2', 'Pagamento Cartão - Restaurante', NOW() - INTERVAL '3 days', 'APPROVED', 'CARD-002', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "card", "acquirer": "stone", "acquirer_txn_id": "STONE-789012", "card_last4": "5678"}');
    
    -- ============================================
    -- TRANSAÇÕES - Fluxo 7: Cancelamento/Refund
    -- ============================================
    
    -- Transação cancelada (void)
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 50.00, 'Merchant Cancelado', 'Transação cancelada', NOW() - INTERVAL '1 day', 'REVERSED', 'VOID-001', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "qr", "void_reason": "customer_request", "original_txn_id": "QR-001"}');
    
    -- ============================================
    -- TRANSAÇÕES - Fluxo 10: Disputa
    -- ============================================
    
    -- Transação em disputa
    INSERT INTO transactions (id, user_id, type, amount, merchant, description, created_at, status, reference, wallet_id, wallet_type, metadata)
    VALUES 
        (gen_random_uuid(), user1_id, 'DEBIT', 100.00, 'Merchant Disputado', 'Transação em disputa', NOW() - INTERVAL '5 days', 'DISPUTED', 'DISPUTE-001', '550e8400-e29b-41d4-a716-446655440001', 'VR', '{"payment_method": "card", "dispute_reason": "unauthorized", "dispute_status": "open"}');
    
    -- ============================================
    -- ATUALIZAR SALDOS DAS WALLETS
    -- ============================================
    
    UPDATE wallets 
    SET balance = (
        SELECT COALESCE(SUM(
            CASE 
                WHEN type = 'DEBIT' THEN -amount
                WHEN type IN ('CREDIT', 'TOPUP') THEN amount
                ELSE 0
            END
        ), 0)
        FROM transactions 
        WHERE transactions.user_id = wallets.user_id 
        AND transactions.wallet_id = wallets.id::text
        AND transactions.status IN ('APPROVED', 'SETTLED')
    ),
    last_updated = NOW()
    WHERE user_id IN (user1_id, admin_id, merchant1_id);
    
END;
$$;
"@

# Executar SQL
Write-Host "`n[4/4] Executando SQL..." -ForegroundColor Yellow
try {
    Write-Host "  Executando script SQL completo..." -ForegroundColor Gray
    $sqlContent | docker exec -i benefits-postgres psql -U $DB_USER -d $DB_NAME
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Dados inseridos com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro ao executar SQL" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro ao executar SQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Banco de Dados Populado com Massa de Dados COMPLETA! ===" -ForegroundColor Green
Write-Host "`nDados criados:" -ForegroundColor Yellow
Write-Host "  - 4 wallets (VR, VA, Admin, Merchant)" -ForegroundColor White
Write-Host "  - 30+ transações com diferentes estados" -ForegroundColor White
Write-Host "  - Transações QR (Fluxo 5)" -ForegroundColor White
Write-Host "  - Transações Cartão (Fluxo 6)" -ForegroundColor White
Write-Host "  - Transações Canceladas/Refund (Fluxo 7)" -ForegroundColor White
Write-Host "  - Transações em Disputa (Fluxo 10)" -ForegroundColor White
Write-Host "  - Topups (Fluxo 3)" -ForegroundColor White
Write-Host "  - Saldos atualizados automaticamente" -ForegroundColor White
Write-Host "`nAgora você pode testar todos os fluxos!" -ForegroundColor Cyan
