# Script para buildar todos os serviços
Write-Host "=== Buildando Todos os Serviços ===" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"
$allPassed = $true

function Build-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath
    )
    
    Write-Host "`n[BUILD] $ServiceName..." -ForegroundColor Yellow
    Write-Host "  Caminho: $ServicePath" -ForegroundColor Gray
    
    Push-Location $ServicePath
    
    try {
        mvn clean package -DskipTests
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $ServiceName buildado com sucesso" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ✗ Erro ao buildar $ServiceName" -ForegroundColor Red
            return $false
        }
    } catch {
        $errorMsg = $_.Exception.Message
        Write-Host "  ✗ Erro ao buildar $ServiceName : $errorMsg" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

# Verificar se Maven está instalado
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Maven não está instalado!" -ForegroundColor Red
    Write-Host "  Instale o Maven: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Maven encontrado" -ForegroundColor Green

# Buildar serviços
$services = @(
    @{Name="Core Service"; Path="services/benefits-core"},
    @{Name="User BFF"; Path="services/user-bff"},
    @{Name="Admin BFF"; Path="services/admin-bff"},
    @{Name="Merchant BFF"; Path="services/merchant-bff"},
    @{Name="Merchant Portal BFF"; Path="services/merchant-portal-bff"}
)

foreach ($service in $services) {
    if (-not (Build-Service -ServiceName $service.Name -ServicePath $service.Path)) {
        $allPassed = $false
    }
}

# Resumo
Write-Host "`n=== Resumo ===" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ Todos os serviços foram buildados com sucesso!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Alguns serviços falharam no build" -ForegroundColor Red
    exit 1
}
