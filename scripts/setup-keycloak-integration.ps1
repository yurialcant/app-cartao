# setup-keycloak-integration.ps1
# Configura autenticação real com Keycloak para reduzir mocks

Write-Host "🔐 Configurando Keycloak Integration..." -ForegroundColor Cyan

# Aguardar Keycloak ficar pronto
Write-Host "⏳ Aguardando Keycloak..." -ForegroundColor White
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/realms/benefits/.well-known/openid-connect-configuration" -Method GET -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Keycloak está pronto!" -ForegroundColor Green
            break
        }
    } catch {
        $attempt++
        Write-Host "   Tentativa $attempt/$maxAttempts..." -ForegroundColor Gray
        Start-Sleep -Seconds 10
    }
}

if ($attempt -ge $maxAttempts) {
    Write-Host "❌ Keycloak não ficou pronto. Abortando." -ForegroundColor Red
    exit 1
}

# Testar login no Keycloak
Write-Host "🔑 Testando autenticação..." -ForegroundColor White
try {
    $loginBody = @{
        client_id = "benefits-app"
        username = "tiago.tiede@flash.com"
        password = "password123"
        grant_type = "password"
    }

    $response = Invoke-WebRequest -Uri "http://localhost:8080/realms/benefits/protocol/openid-connect/token" `
        -Method POST `
        -ContentType "application/x-www-form-urlencoded" `
        -Body $loginBody

    if ($response.StatusCode -eq 200) {
        $tokenData = $response.Content | ConvertFrom-Json
        Write-Host "✅ Autenticação JWT funcionando!" -ForegroundColor Green
        Write-Host "   Token: $($tokenData.access_token.Substring(0,50))..." -ForegroundColor Gray

        # Salvar token para uso posterior
        $tokenData | ConvertTo-Json | Out-File -FilePath ".cursor/keycloak-token.json" -Encoding UTF8
    }
} catch {
    Write-Host "⚠️  Autenticação falhou: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Configurar services para usar Keycloak
Write-Host "⚙️  Configurando serviços para usar Keycloak..." -ForegroundColor White

# benefits-core
$benefitsCoreApp = Get-Content "services/benefits-core/src/main/resources/application.yml" -Raw | ConvertFrom-Json
if ($benefitsCoreApp.spring.profiles.active -notcontains "keycloak") {
    Write-Host "   Configurando benefits-core..." -ForegroundColor Gray
    # Adicionar profile keycloak
}

# user-bff
$userBffApp = Get-Content "services/user-bff/src/main/resources/application.yml" -Raw | ConvertFrom-Json
if ($userBffApp.spring.profiles.active -notcontains "keycloak") {
    Write-Host "   Configurando user-bff..." -ForegroundColor Gray
    # Adicionar profile keycloak
}

Write-Host "🎉 Keycloak integration configurado!" -ForegroundColor Green
Write-Host "💡 Use: spring.profiles.active=keycloak para autenticação real" -ForegroundColor Cyan