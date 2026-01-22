# Script para adicionar dependência OpenFeign em todos os BFFs

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     📦 ADICIONANDO DEPENDÊNCIAS OPENFEIGN NOS BFFs 📦          ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$bffs = @("user-bff", "admin-bff", "merchant-bff", "merchant-portal-bff")

$feignDependency = @"
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
"@

foreach ($bffName in $bffs) {
    $pomPath = Join-Path $baseDir "services/$bffName/pom.xml"
    
    if (-not (Test-Path $pomPath)) {
        Write-Host "  ⚠ $bffName/pom.xml não encontrado" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "  Verificando $bffName..." -ForegroundColor Yellow
    
    $pomContent = Get-Content $pomPath -Raw
    
    if ($pomContent -match "spring-cloud-starter-openfeign") {
        Write-Host "    ⚠ OpenFeign já existe em $bffName" -ForegroundColor Yellow
        continue
    }
    
    # Encontrar posição para inserir (antes do fechamento de dependencies)
    $insertPos = $pomContent.LastIndexOf("</dependencies>")
    
    if ($insertPos -eq -1) {
        Write-Host "    ✗ Não foi possível encontrar </dependencies>" -ForegroundColor Red
        continue
    }
    
    $newPomContent = $pomContent.Insert($insertPos, $feignDependency)
    Set-Content -Path $pomPath -Value $newPomContent -Encoding UTF8
    
    Write-Host "    ✓ OpenFeign adicionado em $bffName" -ForegroundColor Green
}

Write-Host "`n✅ Dependências adicionadas!" -ForegroundColor Green
Write-Host ""
