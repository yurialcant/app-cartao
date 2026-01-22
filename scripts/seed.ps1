# seed.ps1 - Aplicar Seeds no Banco de Dados
# Executar: .\scripts\seed.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$SeedDir = "$ProjectRoot\infra\postgres\seeds"

Write-Host "🌱 [SEED] Aplicando seeds no banco de dados..." -ForegroundColor Cyan

# Verificar se Postgres está rodando
Write-Host "`n🔍 [SEED] Verificando Postgres..." -ForegroundColor Yellow
$pgRunning = docker ps --filter "name=benefits-postgres" --filter "status=running" --format "{{.Names}}"

if (-not $pgRunning) {
    Write-Host "   ❌ Postgres não está rodando. Execute .\scripts\up.ps1 primeiro" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Postgres está rodando" -ForegroundColor Green

# Configurações de conexão
$env:PGPASSWORD = "benefits123"
$PSQL = "docker exec -i benefits-postgres psql -U benefits -d benefits"

# Aplicar seeds em ordem
$seedFiles = @(
    "01-tenant-origami.sql",
    "02-users-wallets.sql",
    "03-merchants-terminals.sql"
)

foreach ($seedFile in $seedFiles) {
    $seedPath = Join-Path $SeedDir $seedFile
    
    if (-not (Test-Path $seedPath)) {
        Write-Host "   ⚠️  Seed não encontrado: $seedFile (pulando)" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`n📄 [SEED] Aplicando $seedFile..." -ForegroundColor Yellow
    
    try {
        Get-Content $seedPath | docker exec -i benefits-postgres psql -U benefits -d benefits
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ $seedFile aplicado com sucesso" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Erro ao aplicar $seedFile" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "   ❌ Exceção ao aplicar $seedFile : $_" -ForegroundColor Red
        exit 1
    }
}

# Verificação final
Write-Host "`n📊 [SEED] Verificando dados..." -ForegroundColor Yellow

$verification = @"
SELECT 'Tenants' as tabela, COUNT(*) as total FROM tenants
UNION ALL
SELECT 'Users' as tabela, COUNT(*) as total FROM users
UNION ALL
SELECT 'Wallets' as tabela, COUNT(*) as total FROM wallets
UNION ALL
SELECT 'Ledger Entries' as tabela, COUNT(*) as total FROM ledger_entries
ORDER BY tabela;
"@

Write-Host $verification | docker exec -i benefits-postgres psql -U benefits -d benefits -t

Write-Host "`n✅ [SEED] Seeds aplicados com sucesso!" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Cyan
Write-Host "  1. Rodar smoke tests: .\scripts\smoke.ps1" -ForegroundColor Gray
Write-Host "  2. Iniciar user-bff e testar endpoints" -ForegroundColor Gray
