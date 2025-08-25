# 🚀 Script para Executar App no Device com Mocks
# Autor: Tiago Tiede
# Empresa: Origami
# Versão: 1.0.0

Write-Host "🚀 INICIANDO EXECUÇÃO DO APP NO DEVICE COM MOCKS" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# ========================================
# 🔍 VERIFICAÇÕES INICIAIS
# ========================================

Write-Host "`n🔍 Verificando Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter encontrado:" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor Cyan
} catch {
    Write-Host "❌ ERRO: Flutter não encontrado!" -ForegroundColor Red
    Write-Host "Instale o Flutter em: https://flutter.dev/docs/get-started/install" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔍 Verificando dispositivos conectados..." -ForegroundColor Yellow
$devices = flutter devices
Write-Host $devices -ForegroundColor Cyan

# ========================================
# 🧹 LIMPEZA E PREPARAÇÃO
# ========================================

Write-Host "`n🧹 Limpando build anterior..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build limpo com sucesso" -ForegroundColor Green
} else {
    Write-Host "⚠️ Aviso: Erro ao limpar build" -ForegroundColor Yellow
}

Write-Host "`n📦 Instalando dependências..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependências instaladas" -ForegroundColor Green
} else {
    Write-Host "❌ ERRO: Falha ao instalar dependências" -ForegroundColor Red
    exit 1
}

# ========================================
# 🔧 CONFIGURAÇÕES DE MOCK
# ========================================

Write-Host "`n🔧 Configurando ambiente com mocks..." -ForegroundColor Yellow

# Variáveis de ambiente para mocks
$envVars = @(
    "--dart-define=ENV=dev",
    "--dart-define=USE_MOCKS=true",
    "--dart-define=TEST_MODE=true"
)

$envString = $envVars -join " "
Write-Host "🔧 Variáveis de ambiente: $envString" -ForegroundColor Cyan

# ========================================
# 📱 EXECUÇÃO NO DEVICE
# ========================================

Write-Host "`n📱 Executando app no device..." -ForegroundColor Yellow
Write-Host "🔧 Comando: flutter run --debug $envString" -ForegroundColor Cyan

# Executa o app
flutter run --debug $envString

# ========================================
# 📊 INFORMAÇÕES ADICIONAIS
# ========================================

Write-Host "`n📊 INFORMAÇÕES IMPORTANTES:" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

Write-Host "`n🔐 DADOS DE TESTE DISPONÍVEIS:" -ForegroundColor Yellow
Write-Host "• CPF Primeiro Acesso: 111.444.777-35" -ForegroundColor Cyan
Write-Host "• CPF Usuário Existente: 946.919.070-09" -ForegroundColor Cyan
Write-Host "• Senha: Test123!" -ForegroundColor Cyan
Write-Host "• Token: 1234" -ForegroundColor Cyan

Write-Host "`n🧪 COMANDOS ÚTEIS:" -ForegroundColor Yellow
Write-Host "• Executar testes: flutter test" -ForegroundColor Cyan
Write-Host "• Build APK: flutter build apk --debug" -ForegroundColor Cyan
Write-Host "• Hot Reload: r (no terminal do app)" -ForegroundColor Cyan
Write-Host "• Hot Restart: R (no terminal do app)" -ForegroundColor Cyan
Write-Host "• Sair: q (no terminal do app)" -ForegroundColor Cyan

Write-Host "`n🔧 CONFIGURAÇÕES DE MOCK:" -ForegroundColor Yellow
Write-Host "• Ambiente: Desenvolvimento" -ForegroundColor Cyan
Write-Host "• Mocks: Habilitados" -ForegroundColor Cyan
Write-Host "• Modo Teste: Habilitado" -ForegroundColor Cyan
Write-Host "• API: Simulada localmente" -ForegroundColor Cyan

Write-Host "`n📁 ARQUIVOS IMPORTANTES:" -ForegroundColor Yellow
Write-Host "• Configuração: lib/core/config/env_config.dart" -ForegroundColor Cyan
Write-Host "• Dados de Teste: assets/mocks/test_data.json" -ForegroundColor Cyan
Write-Host "• Documentação API: API_DOCUMENTATION.md" -ForegroundColor Cyan

Write-Host "`n🚀 APP EXECUTANDO COM SUCESSO!" -ForegroundColor Green
Write-Host "Use os dados de teste acima para navegar pelo app" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar a execução" -ForegroundColor Yellow
