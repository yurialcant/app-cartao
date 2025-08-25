# Script para executar Flutter App com FORCE_LOGIN_MODE
# Sempre força o fluxo de login, ignorando dados salvos

Write-Host "🚀 Executando Flutter App com FORCE_LOGIN_MODE..." -ForegroundColor Green

# Verifica se Flutter está instalado
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter não encontrado. Instale o Flutter primeiro." -ForegroundColor Red
    exit 1
}

# Lista dispositivos disponíveis
Write-Host "📱 Dispositivos disponíveis:" -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "🔑 FORCE_LOGIN_MODE: Sempre força o fluxo de login" -ForegroundColor Cyan
Write-Host "📋 Comportamento:" -ForegroundColor Cyan
Write-Host "   • Ignora dados salvos no dispositivo" -ForegroundColor White
Write-Host "   • Sempre redireciona para tela de login" -ForegroundColor White
Write-Host "   • Útil para testar fluxo de login existente" -ForegroundColor White
Write-Host ""

# Executa o app com FORCE_LOGIN_MODE
Write-Host "▶️ Executando app..." -ForegroundColor Green
flutter run --dart-define=FORCE_LOGIN_MODE=true
