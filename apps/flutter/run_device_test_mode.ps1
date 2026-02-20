# 🧪 SCRIPT PARA EXECUTAR APP EM MODO TESTE
# Autor: Tiago Tiede
# Empresa: Origami
# Versão: 1.0.0

Write-Host "🧪 EXECUTANDO APP EM MODO TESTE..." -ForegroundColor Green
Write-Host ""

# Verifica se o Flutter está disponível
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO: Flutter não encontrado no PATH" -ForegroundColor Red
    Write-Host "   Certifique-se de que o Flutter está instalado e configurado" -ForegroundColor Yellow
    exit 1
}

# Verifica se há dispositivos conectados
Write-Host "📱 Verificando dispositivos conectados..." -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "🚀 Executando app em MODO TESTE..." -ForegroundColor Green
Write-Host "   - Storage será limpo automaticamente" -ForegroundColor Yellow
Write-Host "   - Rotas de primeiro acesso serão permitidas" -ForegroundColor Yellow
Write-Host "   - Ideal para testar fluxos completos" -ForegroundColor Yellow
Write-Host ""

# Executa o app em modo teste
# A variável de ambiente TEST_MODE=true ativa o modo teste
$env:TEST_MODE = "true"
flutter run --dart-define=TEST_MODE=true

Write-Host ""
Write-Host "✅ App executado em modo teste!" -ForegroundColor Green
Write-Host "   Agora você pode testar o fluxo completo de primeiro acesso" -ForegroundColor Cyan
