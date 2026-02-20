# Script para iniciar todos os frontends Angular
# Autor: Sistema de Testes Automatizados
# Data: 2025-12-26

Write-Host "`n🚀 INICIANDO FRONTENDS ANGULAR" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$rootPath = Split-Path -Parent $PSScriptRoot

# Verificar se Node.js está instalado
Write-Host "`n🔍 Verificando Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "  ✅ Node.js $nodeVersion instalado" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Node.js não está instalado" -ForegroundColor Red
    Write-Host "  💡 Instale Node.js de https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Verificar se npm está instalado
Write-Host "`n🔍 Verificando npm..." -ForegroundColor Yellow
try {
    $npmVersion = npm --version
    Write-Host "  ✅ npm $npmVersion instalado" -ForegroundColor Green
} catch {
    Write-Host "  ❌ npm não está instalado" -ForegroundColor Red
    exit 1
}

# ============================================
# 1. ADMIN ANGULAR
# ============================================
Write-Host "`n📋 1. Preparando Admin Angular..." -ForegroundColor Yellow

$adminPath = Join-Path $rootPath "apps\admin_angular"
if (Test-Path $adminPath) {
    Push-Location $adminPath
    
    # Instalar dependências se necessário
    if (-not (Test-Path "node_modules")) {
        Write-Host "  📦 Instalando dependências..." -ForegroundColor Cyan
        npm install 2>&1 | Out-Null
    }
    
    # Verificar se já está rodando
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4200" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  ✅ Admin Angular já está rodando na porta 4200" -ForegroundColor Green
    } catch {
        Write-Host "  🚀 Iniciando Admin Angular na porta 4200..." -ForegroundColor Cyan
        Write-Host "  💡 Abra http://localhost:4200 em outro terminal" -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$adminPath'; npm start"
        Start-Sleep -Seconds 5
    }
    
    Pop-Location
} else {
    Write-Host "  ⚠️  Admin Angular não encontrado em $adminPath" -ForegroundColor Yellow
}

# ============================================
# 2. MERCHANT PORTAL ANGULAR
# ============================================
Write-Host "`n📋 2. Preparando Merchant Portal Angular..." -ForegroundColor Yellow

$merchantPath = Join-Path $rootPath "apps\merchant_portal_angular"
if (Test-Path $merchantPath) {
    Push-Location $merchantPath
    
    # Instalar dependências se necessário
    if (-not (Test-Path "node_modules")) {
        Write-Host "  📦 Instalando dependências..." -ForegroundColor Cyan
        npm install 2>&1 | Out-Null
    }
    
    # Verificar se já está rodando
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4201" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host "  ✅ Merchant Portal Angular já está rodando na porta 4201" -ForegroundColor Green
    } catch {
        Write-Host "  🚀 Iniciando Merchant Portal Angular na porta 4201..." -ForegroundColor Cyan
        Write-Host "  💡 Abra http://localhost:4201 em outro terminal" -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$merchantPath'; npm start"
        Start-Sleep -Seconds 5
    }
    
    Pop-Location
} else {
    Write-Host "  ⚠️  Merchant Portal Angular não encontrado em $merchantPath" -ForegroundColor Yellow
}

# ============================================
# RESUMO
# ============================================
Write-Host "`n✅ Frontends iniciados!" -ForegroundColor Green
Write-Host "`n📊 URLs:" -ForegroundColor Cyan
Write-Host "  - Admin Angular: http://localhost:4200" -ForegroundColor White
Write-Host "  - Merchant Portal Angular: http://localhost:4201" -ForegroundColor White
Write-Host "`n💡 Credenciais:" -ForegroundColor Cyan
Write-Host "  - Admin: admin / admin123" -ForegroundColor White
Write-Host "  - Merchant: merchant1 / merchant123" -ForegroundColor White

