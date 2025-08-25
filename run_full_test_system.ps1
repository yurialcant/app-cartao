# 🚀 SCRIPT COMPLETO PARA TESTAR SISTEMA 100% MOCKADO
# Este script executa o Flutter Login App com todas as variáveis de teste habilitadas

Write-Host "🚀 FLUTTER LOGIN APP - SISTEMA COMPLETO DE TESTES" -ForegroundColor Cyan
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

# Verificar se há dispositivos conectados
Write-Host "📱 Verificando dispositivos..." -ForegroundColor Yellow
$devices = flutter devices
Write-Host "Dispositivos disponíveis:" -ForegroundColor White
Write-Host $devices -ForegroundColor White

# Verificar se há dispositivo Android
if ($devices -match "android") {
    Write-Host "✅ Dispositivo Android encontrado!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Nenhum dispositivo Android encontrado. Conecte um dispositivo ou inicie um emulador." -ForegroundColor Yellow
    Write-Host "💡 Dica: Use 'flutter emulators --launch <nome_do_emulador>' para iniciar um emulador" -ForegroundColor Cyan
}

# Limpar projeto
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

# Verificar configurações ativas
Write-Host "⚙️  Configurações ativas:" -ForegroundColor Yellow
Write-Host "   • TEST_MODE: true (limpa storage para testes)" -ForegroundColor White
Write-Host "   • USE_MOCKS: true (usa sistema de mocks)" -ForegroundColor White
Write-Host "   • FORCE_LOGIN_MODE: false (permite fluxo normal)" -ForegroundColor White
Write-Host "   • FORGOT_PASSWORD_TEST_MODE: true (modo teste recuperação)" -ForegroundColor White
Write-Host "   • API_BASE_URL: https://api.exemplo.com (será substituída pelo dev)" -ForegroundColor White
Write-Host "   • API_TIMEOUT_SECONDS: 30" -ForegroundColor White
Write-Host "   • NETWORK_DELAY_SECONDS: 1.0 (simula latência de rede)" -ForegroundColor White

# Mostrar cenários de teste disponíveis
Write-Host "🎭 CENÁRIOS DE TESTE DISPONÍVEIS:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "🔍 1. PRIMEIRO ACESSO:" -ForegroundColor Yellow
Write-Host "    • CPFs: 11144477735, 22255588846" -ForegroundColor White
Write-Host "    • Fluxo: Welcome → CPF Check → Terms → SMS → Password → Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "🔐 2. LOGIN EXISTENTE:" -ForegroundColor Yellow
Write-Host "    • CPF: 94691907009 → Senha: Senha123@" -ForegroundColor White
Write-Host "    • CPF: 63254351096 → Senha: Test123!" -ForegroundColor White
Write-Host "    • Fluxo: Welcome → CPF Check → Login → Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "🔑 3. RECUPERAÇÃO DE SENHA:" -ForegroundColor Yellow
Write-Host "    • CPFs: 94691907009, 63254351096" -ForegroundColor White
Write-Host "    • Fluxo: Login → Esqueci senha → Método → Token → Nova senha → Dashboard" -ForegroundColor White
Write-Host ""
Write-Host "🔒 4. BLOQUEIO DE CONTA:" -ForegroundColor Yellow
Write-Host "    • 3 tentativas incorretas = bloqueio temporário (10 min)" -ForegroundColor White
Write-Host "    • 5 tentativas incorretas = bloqueio permanente" -ForegroundColor White
Write-Host ""
Write-Host "📱 5. BIOMETRIA:" -ForegroundColor Yellow
Write-Host "    • Após login normal, teste autenticação biométrica" -ForegroundColor White
Write-Host "    • Simulação com 80% de sucesso para testes realistas" -ForegroundColor White

# Executar o sistema com todas as variáveis de teste
Write-Host "🚀 EXECUTANDO SISTEMA COMPLETO..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$command = @"
flutter run --debug --dart-define=TEST_MODE=true --dart-define=USE_MOCKS=true --dart-define=FORGOT_PASSWORD_TEST_MODE=true --dart-define=FORCE_LOGIN_MODE=false --dart-define=API_BASE_URL=https://api.exemplo.com --dart-define=API_TIMEOUT_SECONDS=30 --dart-define=NETWORK_DELAY_SECONDS=1.0
"@

Write-Host "Comando executado:" -ForegroundColor Cyan
Write-Host $command -ForegroundColor White
Write-Host ""

# Executar o comando
Write-Host "🎯 Iniciando aplicação..." -ForegroundColor Green
Write-Host "💡 Aguarde a compilação e inicialização..." -ForegroundColor Cyan
Write-Host "📱 O app será aberto automaticamente no dispositivo/emulador" -ForegroundColor White
Write-Host ""

# Executar o Flutter
Invoke-Expression $command

# Se chegou aqui, o app foi fechado
Write-Host ""
Write-Host "🏁 Aplicação finalizada!" -ForegroundColor Green
Write-Host "💡 Para executar novamente, rode este script novamente" -ForegroundColor Cyan
Write-Host "📚 Consulte o README.md para mais informações sobre os cenários de teste" -ForegroundColor White
