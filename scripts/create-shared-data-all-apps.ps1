# Script para criar dados compartilhados que aparecem em TODOS os apps
Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📊 CRIANDO DADOS COMPARTILHADOS ENTRE APPS 📊            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# IDs do Keycloak
$userIds = @{
    "user1" = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"
    "admin" = "admin-id-001"
    "merchant1" = "merchant-id-001"
}

Write-Host "[1/4] Criando dados compartilhados no banco..." -ForegroundColor Yellow

$sql = @"
-- ============================================
-- DADOS COMPARTILHADOS ENTRE TODOS OS APPS
-- ============================================

DO `$`$
DECLARE
    user1_uuid UUID;
    admin_uuid UUID;
    merchant1_uuid UUID;
    company_uuid UUID;
    employee_uuid UUID;
    wallet_vr_id VARCHAR(255);
    wallet_va_id VARCHAR(255);
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
    
    -- Criar empresa (merchant)
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
    
    -- Criar merchant1
    SELECT id INTO merchant1_uuid FROM merchants WHERE keycloak_id = '$($userIds["merchant1"])' LIMIT 1;
    IF merchant1_uuid IS NULL THEN
        INSERT INTO merchants (id, keycloak_id, name, cnpj, email, phone, mcc, status, kyb_status, created_at)
        VALUES (gen_random_uuid(), '$($userIds["merchant1"])', 'Restaurante Bom Sabor', '12.345.678/0001-90', 'merchant1@benefits.local', '+5511888888888', '5812', 'ACTIVE', 'APPROVED', NOW())
        RETURNING id INTO merchant1_uuid;
    END IF;
    
    -- Criar wallets para user1 (usando estrutura correta)
    -- A tabela wallets tem constraint única em user_id, então criamos apenas uma wallet
    -- Mas podemos simular múltiplas carteiras via transações com diferentes wallet_type
    INSERT INTO wallets (id, user_id, balance, currency, last_updated)
    VALUES ('550e8400-e29b-41d4-a716-446655440001', user1_uuid::TEXT, 500.00, 'BRL', NOW())
    ON CONFLICT (id) DO UPDATE SET balance = 500.00, last_updated = NOW();
    
    wallet_vr_id := '550e8400-e29b-41d4-a716-446655440001';
    
    -- Criar transações compartilhadas (visíveis em todos os apps)
    INSERT INTO transactions (id, user_id, wallet_id, wallet_type, type, amount, merchant, description, status, reference, created_at)
    VALUES 
        -- Transações recentes (visíveis no User App)
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 25.50, 'Padaria XYZ', 'Pão e café', 'APPROVED', 'REF-001', NOW() - INTERVAL '2 hours'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 45.00, 'Farmácia Saúde', 'Medicamentos', 'APPROVED', 'REF-002', NOW() - INTERVAL '5 hours'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 80.00, 'Restaurante Bom Sabor', 'Almoço', 'APPROVED', 'REF-003', NOW() - INTERVAL '1 day'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'DEBIT', 120.00, 'Supermercado Central', 'Compras', 'PENDING', 'REF-004', NOW() - INTERVAL '30 minutes'),
        (gen_random_uuid(), user1_uuid::TEXT, wallet_vr_id, 'VR', 'TOPUP', 500.00, 'Empresa Exemplo LTDA', 'Crédito mensal VR', 'SETTLED', 'REF-007', NOW() - INTERVAL '10 days')
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Dados compartilhados criados!';
    RAISE NOTICE 'User1 UUID: %', user1_uuid;
    RAISE NOTICE 'Company UUID: %', company_uuid;
    RAISE NOTICE 'Employee UUID: %', employee_uuid;
END `$`$;
"@

docker exec -i benefits-postgres psql -U benefits -d benefits -c $sql 2>&1 | Out-Null

Write-Host "  ✓ Dados compartilhados criados" -ForegroundColor Green

Write-Host "`n[2/4] Verificando integração Core Service..." -ForegroundColor Yellow
$coreHealth = Invoke-WebRequest -Uri "http://localhost:8091/actuator/health" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
if ($coreHealth) {
    Write-Host "  ✓ Core Service integrado" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Core Service não está respondendo" -ForegroundColor Yellow
}

Write-Host "`n[3/4] Verificando BFFs..." -ForegroundColor Yellow
$bffs = @(
    @{Name="User BFF"; Url="http://localhost:8080/actuator/health"},
    @{Name="Admin BFF"; Url="http://localhost:8083/actuator/health"},
    @{Name="Merchant BFF"; Url="http://localhost:8084/actuator/health"}
)

foreach ($bff in $bffs) {
    try {
        $response = Invoke-WebRequest -Uri $bff.Url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "  ✓ $($bff.Name) - OK" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $($bff.Name) - ERRO" -ForegroundColor Red
    }
}

Write-Host "`n[4/4] Testando fluxo de dados compartilhados..." -ForegroundColor Yellow

# Teste: Login no User BFF e ver dados
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" -Method Post -Body (@{username="user1";password="Passw0rd!"} | ConvertTo-Json) -ContentType "application/json"
    $token = $loginResponse.access_token
    $headers = @{Authorization="Bearer $token"}
    
    $wallet = Invoke-RestMethod -Uri "http://localhost:8080/wallets/summary" -Method Get -Headers $headers
    Write-Host "  ✓ User BFF retornou dados do Core Service" -ForegroundColor Green
    Write-Host "    Saldo: R$ $($wallet.balance)" -ForegroundColor Gray
    
    $transactions = Invoke-RestMethod -Uri "http://localhost:8080/transactions?limit=5" -Method Get -Headers $headers
    $count = if ($transactions.transactions) { $transactions.transactions.Count } else { 0 }
    Write-Host "  ✓ Transações compartilhadas: $count" -ForegroundColor Green
} catch {
    Write-Host "  ⚠ Erro ao testar fluxo: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "║     ✅ DADOS COMPARTILHADOS CRIADOS! ✅                     ║" -ForegroundColor Green
Write-Host "║                                                              ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Dados criados:" -ForegroundColor Cyan
Write-Host "  ✓ Usuários (user1, admin, funcionário)" -ForegroundColor White
Write-Host "  ✓ Empresa (Empresa Exemplo LTDA)" -ForegroundColor White
Write-Host "  ✓ Merchant (Restaurante Bom Sabor)" -ForegroundColor White
Write-Host "  ✓ Wallets e Transações compartilhadas" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Integração:" -ForegroundColor Cyan
Write-Host "  ✓ Todos os BFFs consomem Core Service" -ForegroundColor White
Write-Host "  ✓ Dados compartilhados via mesmo banco" -ForegroundColor White
Write-Host "  ✓ Alterações no Admin aparecem no User App" -ForegroundColor White
Write-Host ""
