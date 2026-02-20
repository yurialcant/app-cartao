# 🧪 SCRIPT COMPLETO PARA EXECUTAR TESTES FLUTTER
# Este script executa todos os tipos de testes disponíveis no projeto

Write-Host "🧪 FLUTTER LOGIN APP - EXECUTOR DE TESTES COMPLETO" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Verificar se o Flutter está instalado
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter encontrado:" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor White
} catch {
    Write-Host "❌ Flutter não encontrado. Instale o Flutter primeiro." -ForegroundColor Red
    exit 1
}

# Limpar projeto antes dos testes
Write-Host "🧹 Limpando projeto..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Projeto limpo com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao limpar projeto" -ForegroundColor Red
    exit 1
}

# Instalar dependências
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependências instaladas com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao instalar dependências" -ForegroundColor Red
    exit 1
}

# Mostrar opções de teste
Write-Host "🎯 OPÇÕES DE TESTE DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "1️⃣  Testes Unitários (Mais rápidos)" -ForegroundColor Yellow
Write-Host "2️⃣  Testes de Widget (UI Components)" -ForegroundColor Yellow
Write-Host "3️⃣  Testes de Integração (Fluxos completos)" -ForegroundColor Yellow
Write-Host "4️⃣  TODOS OS TESTES (Recomendado)" -ForegroundColor Yellow
Write-Host "5️⃣  Testes com Cobertura (Relatório detalhado)" -ForegroundColor Yellow

# Escolher tipo de teste
Write-Host ""
Write-Host "Escolha o tipo de teste (1-5):" -ForegroundColor White
$choice = Read-Host

# Configurar comando baseado na escolha
switch ($choice) {
    "1" {
        $command = "flutter test test/unit/"
        $description = "Testes Unitários"
        Write-Host "🎯 Testes Unitários selecionados" -ForegroundColor Green
    }
    "2" {
        $command = "flutter test test/widget/"
        $description = "Testes de Widget"
        Write-Host "🎯 Testes de Widget selecionados" -ForegroundColor Green
    }
    "3" {
        $command = "flutter test test/integration/"
        $description = "Testes de Integração"
        Write-Host "🎯 Testes de Integração selecionados" -ForegroundColor Green
    }
    "4" {
        $command = "flutter test"
        $description = "TODOS OS TESTES"
        Write-Host "🎯 TODOS OS TESTES selecionados" -ForegroundColor Green
    }
    "5" {
        $command = "flutter test --coverage"
        $description = "Testes com Cobertura"
        Write-Host "🎯 Testes com Cobertura selecionados" -ForegroundColor Green
    }
    default {
        $command = "flutter test"
        $description = "TODOS OS TESTES (padrão)"
        Write-Host "🎯 Modo padrão selecionado (Todos os testes)" -ForegroundColor Green
    }
}

# Mostrar informações dos testes
Write-Host "📊 INFORMAÇÕES DOS TESTES:" -ForegroundColor Yellow
Write-Host "==========================" -ForegroundColor Yellow
Write-Host "🧪 Testes Unitários disponíveis:" -ForegroundColor White
Write-Host "   • auth_service_test.dart" -ForegroundColor White
Write-Host "   • biometric_service_test.dart" -ForegroundColor White
Write-Host "   • auth_test.dart" -ForegroundColor White
Write-Host ""
Write-Host "🎭 Testes de Widget disponíveis:" -ForegroundColor White
Write-Host "   • cpf_check_page_test.dart" -ForegroundColor White
Write-Host "   • first_access_register_page_test.dart" -ForegroundColor White
Write-Host ""
Write-Host "🔄 Testes de Integração disponíveis:" -ForegroundColor White
Write-Host "   • first_access_flow_test.dart" -ForegroundColor White
Write-Host "   • login_flow_test.dart" -ForegroundColor White
Write-Host "   • complete_app_flow_test.dart" -ForegroundColor White
Write-Host "   • first_access_dashboard_test.dart" -ForegroundColor White

# Executar os testes
Write-Host "🚀 EXECUTANDO TESTES..." -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green

Write-Host "Tipo de teste: $description" -ForegroundColor Cyan
Write-Host "Comando executado: $command" -ForegroundColor Cyan
Write-Host ""

# Executar o comando
Write-Host "🎯 Iniciando execução dos testes..." -ForegroundColor Green
Write-Host "⏱️  Aguarde a execução completa..." -ForegroundColor Cyan
Write-Host ""

# Executar o Flutter test
Invoke-Expression $command

# Se chegou aqui, os testes foram executados
Write-Host ""
Write-Host "🏁 Execução dos testes finalizada!" -ForegroundColor Green

# Se foi teste com cobertura, mostrar como visualizar
if ($choice -eq "5") {
    Write-Host ""
    Write-Host "📊 RELATÓRIO DE COBERTURA GERADO:" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "✅ Relatório de cobertura salvo em: coverage/lcov.info" -ForegroundColor Green
    Write-Host "🌐 Para visualizar no navegador, execute:" -ForegroundColor Yellow
    Write-Host "   genhtml coverage/lcov.info -o coverage/html" -ForegroundColor White
    Write-Host "   start coverage/html/index.html" -ForegroundColor White
}

Write-Host ""
Write-Host "💡 DICAS PARA TESTES:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "🔍 Para executar teste específico:" -ForegroundColor White
Write-Host "   flutter test test/unit/auth_service_test.dart" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Para executar com verbose:" -ForegroundColor White
Write-Host "   flutter test --verbose" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Para executar apenas testes que falharam:" -ForegroundColor White
Write-Host "   flutter test --reporter=expanded" -ForegroundColor White
Write-Host ""
Write-Host "📚 Consulte o README.md para mais informações sobre os testes" -ForegroundColor White
