# Script para configurar DNS local (Windows)
Write-Host "=== Configuração de DNS Local ===" -ForegroundColor Cyan

Write-Host "`nOpções disponíveis:" -ForegroundColor Yellow
Write-Host "1. Usar localtest.me (mais simples, zero configuração)" -ForegroundColor White
Write-Host "2. Configurar dnsmasq via Docker (mais profissional)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Escolha uma opção (1 ou 2)"

if ($choice -eq "1") {
    Write-Host "`n✅ Usando localtest.me" -ForegroundColor Green
    Write-Host "`nVocê pode usar:" -ForegroundColor Yellow
    Write-Host "  - http://api.localtest.me:8080" -ForegroundColor White
    Write-Host "  - http://auth.localtest.me:8081" -ForegroundColor White
    Write-Host "`nNenhuma configuração adicional necessária!" -ForegroundColor Green
} elseif ($choice -eq "2") {
    Write-Host "`nConfigurando dnsmasq via Docker..." -ForegroundColor Yellow
    
    # Verificar se Docker está rodando
    try {
        docker ps | Out-Null
    } catch {
        Write-Host "✗ Docker não está rodando!" -ForegroundColor Red
        Write-Host "  Inicie o Docker Desktop e execute este script novamente." -ForegroundColor Yellow
        exit 1
    }
    
    # Criar diretório se não existir
    $dnsmasqDir = "infra/dnsmasq"
    if (-not (Test-Path $dnsmasqDir)) {
        New-Item -ItemType Directory -Path $dnsmasqDir -Force | Out-Null
    }
    
    # Verificar se dnsmasq.conf existe
    $configFile = "$dnsmasqDir/dnsmasq.conf"
    if (-not (Test-Path $configFile)) {
        Write-Host "✗ Arquivo dnsmasq.conf não encontrado!" -ForegroundColor Red
        Write-Host "  Crie o arquivo infra/dnsmasq/dnsmasq.conf primeiro." -ForegroundColor Yellow
        exit 1
    }
    
    # Parar container existente se houver
    $existing = docker ps -a --filter "name=dnsmasq" --format "{{.Names}}" 2>$null
    if ($existing) {
        Write-Host "Parando container dnsmasq existente..." -ForegroundColor Yellow
        docker stop dnsmasq 2>$null | Out-Null
        docker rm dnsmasq 2>$null | Out-Null
    }
    
    # Iniciar dnsmasq
    Write-Host "Iniciando dnsmasq..." -ForegroundColor Yellow
    docker run -d --name dnsmasq `
        --cap-add=NET_ADMIN `
        -p 53:53/udp `
        -v "${PWD}/infra/dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf" `
        --restart unless-stopped `
        andyshinn/dnsmasq:latest
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ dnsmasq iniciado com sucesso!" -ForegroundColor Green
        Write-Host "`n⚠️  IMPORTANTE: Configure seu DNS para usar 127.0.0.1" -ForegroundColor Yellow
        Write-Host "`nNo Windows:" -ForegroundColor White
        Write-Host "  1. Abra 'Configurações de Rede'" -ForegroundColor Gray
        Write-Host "  2. Altere DNS para 127.0.0.1" -ForegroundColor Gray
        Write-Host "`nOu configure apenas para domínios .test:" -ForegroundColor White
        Write-Host "  - Use ferramentas como Acrylic DNS ou similar" -ForegroundColor Gray
        Write-Host "`nTeste:" -ForegroundColor Yellow
        Write-Host "  nslookup api.benefits.test" -ForegroundColor White
    } else {
        Write-Host "`n✗ Erro ao iniciar dnsmasq" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n✗ Opção inválida" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Configuração Concluída ===" -ForegroundColor Green
