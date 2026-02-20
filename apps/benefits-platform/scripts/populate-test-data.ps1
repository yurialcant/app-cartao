# Script para popular banco de dados com dados de exemplo completos
# Autor: Sistema de Testes Automatizados
# Data: 2025-12-26

Write-Host "`n📊 POPULANDO BANCO DE DADOS COM DADOS DE EXEMPLO" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"

# Verificar se PostgreSQL está rodando
Write-Host "`n🔍 Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    $pgTest = docker exec benefits-postgres psql -U benefits -d benefits -c "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ❌ PostgreSQL não está acessível" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✅ PostgreSQL conectado" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Erro ao conectar no PostgreSQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Função para executar SQL
function Execute-SQL {
    param([string]$Sql)
    
    try {
        $result = docker exec benefits-postgres psql -U benefits -d benefits -c $Sql 2>&1
        return $result
    } catch {
        Write-Host "  ⚠️  Erro ao executar SQL: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

# ============================================
# 1. CRIAR USUÁRIOS DE EXEMPLO
# ============================================
Write-Host "`n📋 1. Criando usuários de exemplo..." -ForegroundColor Yellow

$users = @(
    @{ keycloak_id = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"; email = "user1@benefits.local"; username = "user1"; full_name = "Usuário Teste 1"; cpf = "12345678901"; status = "ACTIVE" },
    @{ keycloak_id = "lucas-maia-001"; email = "lucas@maia.com"; username = "lucas@maia.com"; full_name = "Lucas Maia"; cpf = "11111111111"; status = "ACTIVE" },
    @{ keycloak_id = "admin-id-001"; email = "admin@benefits.local"; username = "admin"; full_name = "Administrador"; cpf = "98765432100"; status = "ACTIVE" },
    @{ keycloak_id = "merchant-id-001"; email = "merchant1@benefits.local"; username = "merchant1"; full_name = "Merchant Teste"; cpf = "11122233344"; status = "ACTIVE" }
)

foreach ($user in $users) {
    $sql = "INSERT INTO users (id, tenant_id, keycloak_id, email, username, full_name, cpf, status, created_at) 
            VALUES (gen_random_uuid(), 'default', '$($user.keycloak_id)', '$($user.email)', '$($user.username)', '$($user.full_name)', '$($user.cpf)', '$($user.status)', NOW())
            ON CONFLICT (keycloak_id) DO NOTHING;"
    
    $result = Execute-SQL -Sql $sql
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Usuário $($user.username) criado/verificado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Usuário $($user.username) - $result" -ForegroundColor Yellow
    }
}

# ============================================
# 2. CRIAR MERCHANTS DE EXEMPLO
# ============================================
Write-Host "`n📋 2. Criando merchants de exemplo..." -ForegroundColor Yellow

$merchants = @(
    @{ name = "Supermercado Central"; cnpj = "12345678000190"; email = "contato@supercentral.com"; keycloak_id = "merchant-keycloak-1"; status = "ACTIVE" },
    @{ name = "Farmácia Saúde"; cnpj = "98765432000110"; email = "contato@farmaciasaude.com"; keycloak_id = "merchant-keycloak-2"; status = "ACTIVE" },
    @{ name = "Posto Shell"; cnpj = "11122233000155"; email = "contato@postoshell.com"; keycloak_id = "merchant-keycloak-3"; status = "ACTIVE" }
)

foreach ($merchant in $merchants) {
    $sql = "INSERT INTO merchants (id, tenant_id, name, cnpj, email, keycloak_id, status, created_at) 
            VALUES (gen_random_uuid(), 'default', '$($merchant.name)', '$($merchant.cnpj)', '$($merchant.email)', '$($merchant.keycloak_id)', '$($merchant.status)', NOW())
            ON CONFLICT (cnpj) DO NOTHING;"
    
    $result = Execute-SQL -Sql $sql
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Merchant $($merchant.name) criado/verificado" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Merchant $($merchant.name) - $result" -ForegroundColor Yellow
    }
}

# ============================================
# 3. CRIAR WALLETS DE EXEMPLO
# ============================================
Write-Host "`n📋 3. Criando wallets de exemplo..." -ForegroundColor Yellow

# Obter IDs dos usuários criados
$userId1 = docker exec benefits-postgres psql -U benefits -d benefits -t -c "SELECT id FROM users WHERE username = 'user1' LIMIT 1;" 2>&1 | ForEach-Object { $_.Trim() }
$adminId = docker exec benefits-postgres psql -U benefits -d benefits -t -c "SELECT id FROM users WHERE username = 'admin' LIMIT 1;" 2>&1 | ForEach-Object { $_.Trim() }

if ($userId1) {
    $wallets = @(
        @{ user_id = $userId1; type = "VR"; balance = 500.00 },
        @{ user_id = $userId1; type = "VA"; balance = 300.00 },
        @{ user_id = $adminId; type = "VR"; balance = 1000.00 }
    )
    
    foreach ($wallet in $wallets) {
        $sql = "INSERT INTO wallets (id, tenant_id, user_id, type, balance, created_at) 
                VALUES (gen_random_uuid(), 'default', '$($wallet.user_id)', '$($wallet.type)', $($wallet.balance), NOW())
                ON CONFLICT DO NOTHING;"
        
        $result = Execute-SQL -Sql $sql
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Wallet $($wallet.type) para usuário criado/verificado" -ForegroundColor Green
        }
    }
}

# ============================================
# RESUMO
# ============================================
Write-Host "`n✅ Dados de exemplo populados com sucesso!" -ForegroundColor Green
Write-Host "`n📊 Resumo:" -ForegroundColor Cyan
Write-Host "  - Usuários: $($users.Count)" -ForegroundColor White
Write-Host "  - Merchants: $($merchants.Count)" -ForegroundColor White
Write-Host "  - Wallets: 3" -ForegroundColor White

