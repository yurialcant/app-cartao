# Script para popular banco de dados com dados de teste
Write-Host "=== Populando Banco de Dados com Dados de Teste ===" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Configurações
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "benefits"
$DB_USER = "benefits"
$DB_PASSWORD = "benefits123"

# Verificar se PostgreSQL está rodando
Write-Host "`n[1/3] Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    $pgTest = docker exec benefits-postgres pg_isready -U $DB_USER 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ PostgreSQL está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ PostgreSQL não está rodando" -ForegroundColor Red
        Write-Host "  Execute: docker-compose up -d postgres" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro ao verificar PostgreSQL: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Ler o ID do user1 do realm-benefits.json
Write-Host "`n[2/3] Lendo ID do usuário do Keycloak..." -ForegroundColor Yellow
$realmFile = "infra/keycloak/realm-benefits.json"
if (Test-Path $realmFile) {
    $realm = Get-Content $realmFile | ConvertFrom-Json
    $user1Id = $realm.users[0].id
    Write-Host "  ✓ ID do user1: $user1Id" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Arquivo realm-benefits.json não encontrado" -ForegroundColor Yellow
    Write-Host "  Usando ID padrão..." -ForegroundColor Gray
    $user1Id = "b9a3fdb4-688c-41c7-b705-bcc0e322c022"
}

# Substituir o ID do usuário no SQL
Write-Host "`n[3/3] Executando script SQL..." -ForegroundColor Yellow
$sqlFile = "infra/sql/seed-data.sql"
$sqlContent = Get-Content $sqlFile -Raw

# Substituir o ID do usuário se necessário
if ($sqlContent -match "b9a3fdb4-688c-41c7-b705-bcc0e322c022") {
    $sqlContent = $sqlContent -replace "b9a3fdb4-688c-41c7-b705-bcc0e322c022", $user1Id
    Write-Host "  ✓ ID do usuário atualizado no SQL" -ForegroundColor Green
}

# Executar SQL via docker exec
try {
    Write-Host "  Executando SQL..." -ForegroundColor Gray
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

Write-Host "`n=== Banco de Dados Populado com Sucesso! ===" -ForegroundColor Green
Write-Host "`nDados criados:" -ForegroundColor Yellow
Write-Host "  - 2 wallets (VR e VA)" -ForegroundColor White
Write-Host "  - 15 transações com diferentes estados" -ForegroundColor White
Write-Host "  - Saldos atualizados automaticamente" -ForegroundColor White
Write-Host "`nAgora você pode testar o app Flutter!" -ForegroundColor Cyan
