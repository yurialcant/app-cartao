# Script Completo - Setup + Teste E2E do App Flutter
Write-Host "`n=== 🚀 SETUP COMPLETO + TESTE E2E APP FLUTTER ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Docker
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "  Por favor, inicie o Docker Desktop e tente novamente." -ForegroundColor Yellow
    exit 1
}

# 2. Buildar todos os serviços
Write-Host "`n[2/5] Buildando todos os serviços..." -ForegroundColor Yellow
try {
    & "$PSScriptRoot\build-all-services.ps1"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ✗ Erro ao buildar serviços" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✓ Serviços buildados" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3. Subir Docker Compose
Write-Host "`n[3/5] Subindo Docker Compose..." -ForegroundColor Yellow
Push-Location "$PSScriptRoot\..\infra"
try {
    Write-Host "  Parando containers existentes..." -ForegroundColor Gray
    docker-compose down 2>&1 | Out-Null
    
    Write-Host "  Construindo e iniciando todos os serviços..." -ForegroundColor Gray
    docker-compose up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Serviços iniciados" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Erro ao iniciar serviços" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
    Pop-Location
    exit 1
} finally {
    Pop-Location
}

# 4. Aguardar serviços iniciarem
Write-Host "`n[4/5] Aguardando serviços iniciarem (180 segundos)..." -ForegroundColor Yellow
Write-Host "  (Keycloak pode levar até 60s, serviços Spring até 40s cada)" -ForegroundColor Gray
Write-Host "  Aguardando..." -ForegroundColor Gray

$elapsed = 0
$interval = 10
while ($elapsed -lt 180) {
    Start-Sleep -Seconds $interval
    $elapsed += $interval
    $remaining = 180 - $elapsed
    Write-Host "  $elapsed/180 segundos ($remaining restantes)..." -ForegroundColor Gray
}

Write-Host "  ✓ Tempo de espera concluído" -ForegroundColor Green

# 5. Executar teste E2E do App Flutter
Write-Host "`n[5/5] Executando teste E2E do App Flutter..." -ForegroundColor Yellow
Write-Host ""

try {
    & "$PSScriptRoot\test-flutter-app-e2e.ps1"
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "`n✅ TESTE E2E COMPLETO CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
        Write-Host "`n🎉 O app Flutter pode consumir todos os serviços corretamente!" -ForegroundColor Green
        Write-Host "`n📱 Próximos passos:" -ForegroundColor Cyan
        Write-Host "   1. Execute o app Flutter:" -ForegroundColor White
        Write-Host "      cd apps/user_app_flutter" -ForegroundColor Gray
        Write-Host "      flutter run" -ForegroundColor Gray
        Write-Host "`n   2. Use as credenciais de teste:" -ForegroundColor White
        Write-Host "      Username: user1" -ForegroundColor Gray
        Write-Host "      Password: Passw0rd!" -ForegroundColor Gray
        Write-Host "`n   3. O app deve conseguir:" -ForegroundColor White
        Write-Host "      • Fazer login" -ForegroundColor Gray
        Write-Host "      • Ver saldo da carteira" -ForegroundColor Gray
        Write-Host "      • Listar transações" -ForegroundColor Gray
        Write-Host "      • Ver detalhes de transações" -ForegroundColor Gray
        exit 0
    } else {
        Write-Host "`n✗ TESTE E2E FALHOU" -ForegroundColor Red
        Write-Host "`nVerifique os logs:" -ForegroundColor Yellow
        Write-Host "   docker-compose -f infra/docker-compose.yml logs" -ForegroundColor Gray
        exit 1
    }
} catch {
    Write-Host "  ✗ Erro ao executar teste E2E: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
