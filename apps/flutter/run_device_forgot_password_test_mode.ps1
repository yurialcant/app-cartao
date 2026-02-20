# Script para executar Flutter app em modo de teste para "Esqueci minha senha"
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "🚀 EXECUTANDO FLUTTER APP EM MODO DE TESTE PARA 'ESQUECI MINHA SENHA'" -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green

# Verifica se Flutter está instalado
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter encontrado:" -ForegroundColor Green
    Write-Host $flutterVersion[0] -ForegroundColor Cyan
} catch {
    Write-Host "❌ ERRO: Flutter não encontrado no PATH" -ForegroundColor Red
    Write-Host "   Instale Flutter e adicione ao PATH do sistema" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Lista dispositivos disponíveis
Write-Host "📱 DISPOSITIVOS DISPONÍVEIS:" -ForegroundColor Yellow
flutter devices

Write-Host ""

# Verifica se há dispositivos
$devices = flutter devices --machine | ConvertFrom-Json
if ($devices.Count -eq 0) {
    Write-Host "❌ ERRO: Nenhum dispositivo encontrado" -ForegroundColor Red
    Write-Host "   Conecte um dispositivo ou inicie um emulador" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Executa o app em modo de teste para "Esqueci minha senha"
Write-Host "🔐 EXECUTANDO EM MODO DE TESTE PARA 'ESQUECI MINHA SENHA'..." -ForegroundColor Green
Write-Host "   Variáveis de ambiente:" -ForegroundColor Cyan
Write-Host "   - TEST_MODE=true (para primeiro acesso)" -ForegroundColor Cyan
Write-Host "   - FORGOT_PASSWORD_TEST_MODE=true (para esqueci minha senha)" -ForegroundColor Cyan
Write-Host ""

try {
    # Executa com ambas as variáveis de teste
    flutter run --dart-define=TEST_MODE=true --dart-define=FORGOT_PASSWORD_TEST_MODE=true
} catch {
    Write-Host "❌ ERRO ao executar Flutter app:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Script executado com sucesso!" -ForegroundColor Green
