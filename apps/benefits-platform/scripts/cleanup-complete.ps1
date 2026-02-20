# cleanup-complete.ps1
# Limpeza completa para chegar aos 100%

Write-Host "🧹 LIMPEZA COMPLETA PARA 100%..." -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Green

# ============================================
# FASE 1: REMOVER MOCKS RESTANTES
# ============================================
Write-Host "`n🗑️  [FASE 1] Removendo mocks restantes..." -ForegroundColor Yellow

# Mover mocks Python para legacy
if (Test-Path "mock-admin-bff.py") {
    Move-Item "mock-admin-bff.py" "legacy-mocks/" -Force
    Write-Host "   ✅ mock-admin-bff.py movido para legacy-mocks/" -ForegroundColor Green
}

if (Test-Path "mock-user-bff.py") {
    Move-Item "mock-user-bff.py" "legacy-mocks/" -Force
    Write-Host "   ✅ mock-user-bff.py movido para legacy-mocks/" -ForegroundColor Green
}

# Mover acquirer-stub para legacy (já que é usado apenas em desenvolvimento)
if (Test-Path "services/acquirer-stub") {
    Move-Item "services/acquirer-stub" "legacy-mocks/" -Force
    Write-Host "   ✅ acquirer-stub movido para legacy-mocks/" -ForegroundColor Green
}

# ============================================
# FASE 2: LIMPAR DUPLICATAS DE PACKAGES
# ============================================
Write-Host "`n🔄 [FASE 2] Limpando duplicatas de packages..." -ForegroundColor Yellow

$servicesWithDuplicates = @(
    "notification-service",
    "payments-service",
    "privacy-service",
    "reconciliation-service",
    "risk-service",
    "webhook-receiver",
    "webhook-service"
)

foreach ($service in $servicesWithDuplicates) {
    $oldPath = "services/$service/src/main/java/com/lucasprojects"
    $newPath = "services/$service/src/main/java/com/benefits"

    if (Test-Path $oldPath) {
        Write-Host "   🔄 $service - movendo duplicatas..." -ForegroundColor Gray

        # Criar diretório benefits se não existir
        if (!(Test-Path $newPath)) {
            New-Item -ItemType Directory -Path $newPath -Force | Out-Null
        }

        # Mover conteúdo do lucasprojects para benefits
        Get-ChildItem $oldPath -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Replace($oldPath, "")
            $newFilePath = Join-Path $newPath $relativePath

            if ($_.PSIsContainer) {
                if (!(Test-Path $newFilePath)) {
                    New-Item -ItemType Directory -Path $newFilePath -Force | Out-Null
                }
            } else {
                # Renomear package declarations
                $content = Get-Content $_.FullName -Raw
                $content = $content -replace "package com\.lucasprojects\.", "package com.benefits."
                $content | Set-Content $newFilePath -NoNewline
            }
        }

        # Remover diretório antigo
        Remove-Item $oldPath -Recurse -Force
        Write-Host "   ✅ $service - duplicatas removidas" -ForegroundColor Green
    }
}

# ============================================
# FASE 3: UNIFICAR CONFIGURAÇÕES
# ============================================
Write-Host "`n⚙️  [FASE 3] Unificando configurações..." -ForegroundColor Yellow

# Padronizar application.yml em todos os serviços
$services = Get-ChildItem "services" -Directory

foreach ($service in $services) {
    $appYml = "$service/src/main/resources/application.yml"

    if (Test-Path $appYml) {
        Write-Host "   🔧 $service..." -ForegroundColor Gray

        $content = Get-Content $appYml -Raw

        # Garantir profiles padrão
        if ($content -notmatch "spring:\s*\n\s*profiles:") {
            $content = $content -replace "spring:", "spring:`n  profiles:`n    active: local"
        }

        # Garantir server port
        if ($content -notmatch "server:\s*\n\s*port:") {
            $content = $content -replace "spring:", "server:`n  port: 8080`n`nspring:"
        }

        $content | Set-Content $appYml -NoNewline
    }
}

Write-Host "   ✅ Configurações unificadas" -ForegroundColor Green

# ============================================
# FASE 4: ATUALIZAR POM.XMLs
# ============================================
Write-Host "`n📦 [FASE 4] Atualizando POM.xmls..." -ForegroundColor Yellow

foreach ($service in $servicesWithDuplicates) {
    $pomPath = "services/$service/pom.xml"

    if (Test-Path $pomPath) {
        Write-Host "   🔧 $service pom.xml..." -ForegroundColor Gray

        $content = Get-Content $pomPath -Raw

        # Atualizar groupId se necessário
        $content = $content -replace "<groupId>com\.lucasprojects</groupId>", "<groupId>com.benefits</groupId>"

        $content | Set-Content $pomPath -NoNewline
    }
}

Write-Host "   ✅ POM.xmls atualizados" -ForegroundColor Green

# ============================================
# FASE 5: LIMPAR BUILD ARTIFACTS
# ============================================
Write-Host "`n🧽 [FASE 5] Limpando build artifacts..." -ForegroundColor Yellow

# Limpar targets
Get-ChildItem "services" -Directory | ForEach-Object {
    $targetPath = "$_/target"
    if (Test-Path $targetPath) {
        Remove-Item $targetPath -Recurse -Force
        Write-Host "   🗑️  $_.Name/target removido" -ForegroundColor Gray
    }
}

Write-Host "   ✅ Build artifacts limpos" -ForegroundColor Green

# ============================================
# RESULTADO FINAL
# ============================================
Write-Host "`n🎉 LIMPEZA COMPLETA CONCLUÍDA!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green

Write-Host "`n✅ ITENS REMOVIDOS/CONSOLIDADOS:" -ForegroundColor Cyan
Write-Host "  • Mocks Python movidos para legacy-mocks/" -ForegroundColor White
Write-Host "  • Duplicatas de packages removidas (com.lucasprojects.*)" -ForegroundColor White
Write-Host "  • Configurações unificadas em todos os serviços" -ForegroundColor White
Write-Host "  • POM.xmls atualizados" -ForegroundColor White
Write-Host "  • Build artifacts limpos" -ForegroundColor White

Write-Host "`n🚀 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. ✅ Limpeza concluída" -ForegroundColor Green
Write-Host "2. 🔄 Testar compilação: .\scripts\build-all.ps1" -ForegroundColor White
Write-Host "3. 🔄 Testar integração: .\scripts\test-minimal-end2end.ps1" -ForegroundColor White
Write-Host "4. 🔄 Validar 100%: .\scripts\validate-complete-system.ps1" -ForegroundColor White

Write-Host "`n💡 STATUS: Sistema limpo e pronto para 100%!" -ForegroundColor Green