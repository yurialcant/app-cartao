# Script para habilitar @EnableFeignClients em todos os BFFs

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     ⚙️  HABILITANDO FEIGN CLIENTS NOS BFFs ⚙️                 ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$bffs = @("user-bff", "admin-bff", "merchant-bff", "merchant-portal-bff")

foreach ($bffName in $bffs) {
    $appDir = Join-Path $baseDir "services/$bffName/src/main/java/com/benefits"
    
    # Encontrar Application.java
    $packageDirs = Get-ChildItem -Path $appDir -Directory -ErrorAction SilentlyContinue
    foreach ($packageDir in $packageDirs) {
        $appFiles = Get-ChildItem -Path $packageDir.FullName -Filter "*Application.java" -ErrorAction SilentlyContinue
        foreach ($appFile in $appFiles) {
            Write-Host "  Processando $($appFile.Name)..." -ForegroundColor Yellow
            
            $content = Get-Content $appFile.FullName -Raw
            
            if ($content -match "@EnableFeignClients") {
                Write-Host "    ⚠ @EnableFeignClients já existe" -ForegroundColor Yellow
                continue
            }
            
            # Adicionar import
            if ($content -notmatch "import org.springframework.cloud.openfeign.EnableFeignClients") {
                $content = $content -replace "(import org.springframework.boot.autoconfigure.SpringBootApplication;)", "`$1`nimport org.springframework.cloud.openfeign.EnableFeignClients;"
            }
            
            # Adicionar annotation
            $content = $content -replace "(@SpringBootApplication)", "@EnableFeignClients`n`$1"
            
            Set-Content -Path $appFile.FullName -Value $content -Encoding UTF8
            Write-Host "    ✓ @EnableFeignClients adicionado" -ForegroundColor Green
        }
    }
}

Write-Host "`n✅ Feign Clients habilitados em todos os BFFs!" -ForegroundColor Green
Write-Host ""
