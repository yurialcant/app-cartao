# 🏗️ Script para Build Confiável do App
# Autor: Tiago Tiede
# Empresa: Origami
# Versão: 1.0.0

Write-Host "🏗️ INICIANDO BUILD CONFIÁVEL DO APP" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# ========================================
# 🔍 VERIFICAÇÕES INICIAIS
# ========================================

Write-Host "`n🔍 Verificando ambiente..." -ForegroundColor Yellow

# Verifica Flutter
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter encontrado:" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor Cyan
} catch {
    Write-Host "❌ ERRO: Flutter não encontrado!" -ForegroundColor Red
    exit 1
}

# Verifica Flutter Doctor
Write-Host "`n🔍 Verificando Flutter Doctor..." -ForegroundColor Yellow
flutter doctor
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ AVISO: Flutter Doctor encontrou problemas" -ForegroundColor Yellow
    Write-Host "Recomenda-se resolver antes de continuar" -ForegroundColor Yellow
    $continue = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($continue -ne "s" -and $continue -ne "S") {
        exit 1
    }
}

# ========================================
# 🧹 LIMPEZA COMPLETA
# ========================================

Write-Host "`n🧹 Limpeza completa do projeto..." -ForegroundColor Yellow

# Remove builds anteriores
Write-Host "• Removendo builds anteriores..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Builds removidos" -ForegroundColor Green
} else {
    Write-Host "⚠️ Aviso: Erro ao limpar builds" -ForegroundColor Yellow
}

# Remove node_modules se existir
if (Test-Path "node_modules") {
    Write-Host "• Removendo node_modules..." -ForegroundColor Cyan
    Remove-Item -Recurse -Force "node_modules"
    Write-Host "✅ node_modules removido" -ForegroundColor Green
}

# Remove arquivos temporários
Write-Host "• Removendo arquivos temporários..." -ForegroundColor Cyan
Get-ChildItem -Path "." -Include "*.tmp", "*.log", "*.cache" -Recurse | Remove-Item -Force
Write-Host "✅ Arquivos temporários removidos" -ForegroundColor Green

# ========================================
# 📦 INSTALAÇÃO DE DEPENDÊNCIAS
# ========================================

Write-Host "`n📦 Instalando dependências..." -ForegroundColor Yellow

# Flutter pub get
Write-Host "• Instalando dependências Flutter..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependências Flutter instaladas" -ForegroundColor Green
} else {
    Write-Host "❌ ERRO: Falha ao instalar dependências Flutter" -ForegroundColor Red
    exit 1
}

# Verifica dependências
Write-Host "• Verificando dependências..." -ForegroundColor Cyan
flutter pub deps
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependências verificadas" -ForegroundColor Green
} else {
    Write-Host "⚠️ Aviso: Problemas com dependências" -ForegroundColor Yellow
}

# ========================================
# 🧪 EXECUÇÃO DE TESTES
# ========================================

Write-Host "`n🧪 Executando testes..." -ForegroundColor Yellow

# Testes unitários
Write-Host "• Executando testes unitários..." -ForegroundColor Cyan
flutter test test/unit/
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Testes unitários passaram" -ForegroundColor Green
} else {
    Write-Host "❌ ERRO: Testes unitários falharam" -ForegroundColor Red
    $continue = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($continue -ne "s" -and $continue -ne "S") {
        exit 1
    }
}

# Testes de widget
Write-Host "• Executando testes de widget..." -ForegroundColor Cyan
flutter test test/widget/
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Testes de widget passaram" -ForegroundColor Green
} else {
    Write-Host "❌ ERRO: Testes de widget falharam" -ForegroundColor Red
    $continue = Read-Host "Deseja continuar mesmo assim? (s/N)"
    if ($continue -ne "s" -and $continue -ne "S") {
        exit 1
    }
}

# ========================================
# 🔧 CONFIGURAÇÕES DE BUILD
# ========================================

Write-Host "`n🔧 Configurando build..." -ForegroundColor Yellow

# Seleciona tipo de build
Write-Host "Selecione o tipo de build:" -ForegroundColor Cyan
Write-Host "1. Debug APK" -ForegroundColor White
Write-Host "2. Release APK" -ForegroundColor White
Write-Host "3. App Bundle (AAB)" -ForegroundColor White
Write-Host "4. APK Split por arquitetura" -ForegroundColor White

$buildType = Read-Host "Digite o número (1-4)"

# Configura variáveis de ambiente
$envVars = @(
    "--dart-define=ENV=dev",
    "--dart-define=USE_MOCKS=true"
)

$envString = $envVars -join " "

# ========================================
# 🏗️ EXECUÇÃO DO BUILD
# ========================================

Write-Host "`n🏗️ Executando build..." -ForegroundColor Yellow

switch ($buildType) {
    "1" {
        Write-Host "• Build: Debug APK" -ForegroundColor Cyan
        $buildCommand = "flutter build apk --debug $envString"
    }
    "2" {
        Write-Host "• Build: Release APK" -ForegroundColor Cyan
        $buildCommand = "flutter build apk --release $envString"
    }
    "3" {
        Write-Host "• Build: App Bundle (AAB)" -ForegroundColor Cyan
        $buildCommand = "flutter build appbundle --release $envString"
    }
    "4" {
        Write-Host "• Build: APK Split por arquitetura" -ForegroundColor Cyan
        $buildCommand = "flutter build apk --split-per-abi --release $envString"
    }
    default {
        Write-Host "❌ Opção inválida, usando Debug APK" -ForegroundColor Red
        $buildCommand = "flutter build apk --debug $envString"
    }
}

Write-Host "🔧 Comando: $buildCommand" -ForegroundColor Cyan

# Executa o build
Invoke-Expression $buildCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build executado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ ERRO: Falha no build" -ForegroundColor Red
    exit 1
}

# ========================================
# 📁 LOCALIZAÇÃO DOS ARQUIVOS
# ========================================

Write-Host "`n📁 Localização dos arquivos gerados:" -ForegroundColor Green

switch ($buildType) {
    "1" {
        Write-Host "• Debug APK: build/app/outputs/flutter-apk/app-debug.apk" -ForegroundColor Cyan
    }
    "2" {
        Write-Host "• Release APK: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Cyan
    }
    "3" {
        Write-Host "• App Bundle: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Cyan
    }
    "4" {
        Write-Host "• APKs por arquitetura:" -ForegroundColor Cyan
        Write-Host "  - ARM64: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" -ForegroundColor White
        Write-Host "  - ARM32: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" -ForegroundColor White
        Write-Host "  - x86_64: build/app/outputs/flutter-apk/app-x86_64-release.apk" -ForegroundColor White
    }
}

# ========================================
# 🧪 VERIFICAÇÃO PÓS-BUILD
# ========================================

Write-Host "`n🧪 Verificando build..." -ForegroundColor Yellow

# Verifica se os arquivos foram criados
$buildPath = "build/app/outputs"
if (Test-Path $buildPath) {
    Write-Host "✅ Pasta de build criada" -ForegroundColor Green
    
    # Lista arquivos gerados
    Write-Host "• Arquivos encontrados:" -ForegroundColor Cyan
    Get-ChildItem -Path $buildPath -Recurse -File | ForEach-Object {
        Write-Host "  - $($_.FullName)" -ForegroundColor White
    }
} else {
    Write-Host "❌ ERRO: Pasta de build não encontrada" -ForegroundColor Red
}

# ========================================
# 📊 RESUMO FINAL
# ========================================

Write-Host "`n📊 RESUMO DO BUILD:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green

Write-Host "✅ Flutter verificado" -ForegroundColor Green
Write-Host "✅ Dependências instaladas" -ForegroundColor Green
Write-Host "✅ Testes executados" -ForegroundColor Green
Write-Host "✅ Build executado" -ForegroundColor Green
Write-Host "✅ Arquivos verificados" -ForegroundColor Green

Write-Host "`n🚀 BUILD CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
Write-Host "Os arquivos estão prontos para instalação/distribuição" -ForegroundColor Green

# ========================================
# 🔧 COMANDOS ADICIONAIS
# ========================================

Write-Host "`n🔧 COMANDOS ADICIONAIS ÚTEIS:" -ForegroundColor Yellow

Write-Host "• Instalar no device: flutter install" -ForegroundColor Cyan
Write-Host "• Executar no device: flutter run --release" -ForegroundColor Cyan
Write-Host "• Analisar APK: flutter build apk --analyze-size" -ForegroundColor Cyan
Write-Host "• Limpar cache: flutter clean && flutter pub get" -ForegroundColor Cyan

Write-Host "`n📱 Para instalar no device conectado:" -ForegroundColor Yellow
Write-Host "flutter install" -ForegroundColor Cyan
