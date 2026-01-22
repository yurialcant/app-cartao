# start-flutter-simple.ps1
# Inicia Flutter app de forma simples com serviços essenciais

Write-Host "📱 INICIANDO FLUTTER APP (MODO SIMPLES)" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor Green

# ============================================
# VERIFICAÇÕES BÁSICAS
# ============================================
Write-Host "`n🔍 VERIFICAÇÕES BÁSICAS..." -ForegroundColor Yellow

# Verificar Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   🎯 Flutter: ✅ $($flutterVersion.Split()[1])" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Flutter não encontrado!" -ForegroundColor Red
    Write-Host "   💡 Instale Flutter primeiro" -ForegroundColor Yellow
    exit 1
}

# Verificar se estamos no diretório correto
if (!(Test-Path "apps/user_app_flutter/pubspec.yaml")) {
    Write-Host "   ❌ Execute a partir da raiz do projeto!" -ForegroundColor Red
    exit 1
}

Write-Host "   📁 Projeto localizado: ✅" -ForegroundColor Green

# ============================================
# PREPARAR FLUTTER APP
# ============================================
Write-Host "`n📱 PREPARANDO FLUTTER APP..." -ForegroundColor Yellow

cd apps/user_app_flutter

# Instalar dependências
Write-Host "📦 Baixando dependências..." -ForegroundColor White
flutter pub get

# Verificar configuração
Write-Host "⚙️ Verificando configuração..." -ForegroundColor White
$envConfig = Get-Content "lib/config/app_environment.dart" -Raw
if ($envConfig -match "baseUrl.*localhost:8080") {
    Write-Host "   🌐 Configuração correta: ✅" -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Configuração pode precisar ajustes" -ForegroundColor Yellow
}

# ============================================
# INSTRUÇÕES PARA O USUÁRIO
# ============================================
Write-Host "`n" + ("=" * 50) -ForegroundColor Green
Write-Host "🎯 FLUTTER APP PRONTO PARA INICIAR!" -ForegroundColor Green
Write-Host ("=" * 50) -ForegroundColor Green

Write-Host "`n📋 PRÉ-REQUISITOS PARA FUNCIONAMENTO COMPLETO:" -ForegroundColor Cyan
Write-Host "  1. 🐳 Docker Desktop rodando" -ForegroundColor White
Write-Host "  2. 🔧 Backend services ativos:" -ForegroundColor White
Write-Host "     • .\scripts\start-minimal-no-mocks.ps1" -ForegroundColor Gray
Write-Host "     OU" -ForegroundColor White
Write-Host "     • .\scripts\start-everything.ps1" -ForegroundColor Gray

Write-Host "`n🚀 OPÇÕES PARA INICIAR O FLUTTER APP:" -ForegroundColor Green

Write-Host "`n📱 PARA ANDROID EMULATOR:" -ForegroundColor Cyan
Write-Host "  flutter run" -ForegroundColor White
Write-Host "  # OU especifique o device:" -ForegroundColor Gray
Write-Host "  flutter run -d emulator-5554" -ForegroundColor White

Write-Host "`n🌐 PARA NAVEGADOR WEB:" -ForegroundColor Cyan
Write-Host "  flutter run -d chrome" -ForegroundColor White
Write-Host "  # OU para Edge:" -ForegroundColor Gray
Write-Host "  flutter run -d edge" -ForegroundColor White

Write-Host "`n📱 PARA DISPOSITIVO FÍSICO:" -ForegroundColor Cyan
Write-Host "  # Conecte o dispositivo USB" -ForegroundColor White
Write-Host "  flutter run -d <device-id>" -ForegroundColor White
Write-Host "  # Ver dispositivos: flutter devices" -ForegroundColor Gray

Write-Host "`n🎮 FUNCIONALIDADES DISPONÍVEIS:" -ForegroundColor Green
Write-Host "  🔐 Login/Registro de usuários" -ForegroundColor White
Write-Host "  👤 Gerenciamento de perfil" -ForegroundColor White
Write-Host "  💰 Carteira digital" -ForegroundColor White
Write-Host "  🎁 Benefícios corporativos" -ForegroundColor White
Write-Host "  📊 Histórico de transações" -ForegroundColor White
Write-Host "  🏪 Integração com estabelecimentos" -ForegroundColor White

Write-Host "`n🔧 CONFIGURAÇÃO DO BACKEND:" -ForegroundColor Cyan
Write-Host "  User BFF: http://localhost:8080" -ForegroundColor White
Write-Host "  Benefits Core: http://localhost:8091" -ForegroundColor White
Write-Host "  Database: PostgreSQL localhost:5432" -ForegroundColor White
Write-Host "  Cache: Redis localhost:6379" -ForegroundColor White

Write-Host "`n🧪 PARA TESTAR A INTEGRAÇÃO:" -ForegroundColor Green
Write-Host "  1. Inicie o backend primeiro" -ForegroundColor White
Write-Host "  2. Execute 'flutter run -d chrome'" -ForegroundColor White
Write-Host "  3. Teste login e navegação" -ForegroundColor White
Write-Host "  4. Verifique dados persistidos" -ForegroundColor White

Write-Host "`n📚 COMANDOS ÚTEIS:" -ForegroundColor Cyan
Write-Host "  flutter devices          # Listar devices" -ForegroundColor White
Write-Host "  flutter clean           # Limpar cache" -ForegroundColor White
Write-Host "  flutter pub get         # Atualizar dependências" -ForegroundColor White
Write-Host "  flutter analyze         # Verificar código" -ForegroundColor White
Write-Host "  flutter test            # Executar testes unitários" -ForegroundColor White

Write-Host "`n🎯 STATUS: FLUTTER APP CONFIGURADO!" -ForegroundColor Green
Write-Host "🚀 Pronto para desenvolvimento e testes!" -ForegroundColor Green

# ============================================
# INICIAR FLUTTER AUTOMATICAMENTE (OPCIONAL)
# ============================================
Write-Host "`n❓ DESEJA INICIAR O FLUTTER AGORA?" -ForegroundColor Yellow
Write-Host "  [S] Sim - Iniciar no Chrome" -ForegroundColor White
Write-Host "  [N] Não - Apenas mostrar instruções" -ForegroundColor White

$choice = Read-Host "Escolha (S/N)"

if ($choice -eq "S" -or $choice -eq "s") {
    Write-Host "`n🚀 INICIANDO FLUTTER APP NO CHROME..." -ForegroundColor Cyan
    Write-Host "💡 Pressione Ctrl+C para parar" -ForegroundColor Gray

    try {
        flutter run -d chrome
    } catch {
        Write-Host "`n⚠️ Flutter fechado ou erro ocorreu" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n📋 Instruções mostradas acima!" -ForegroundColor Green
    Write-Host "🎯 Execute 'flutter run -d chrome' quando quiser iniciar" -ForegroundColor Green
}

cd ../..

Write-Host "`n✅ CONFIGURAÇÃO CONCLUÍDA!" -ForegroundColor Green