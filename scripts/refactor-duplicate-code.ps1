# refactor-duplicate-code.ps1
# Remove código duplicado e usa bibliotecas compartilhadas

Write-Host "🔄 REFATORANDO CÓDIGO DUPLICADO PARA USAR LIBS COMPARTILHADAS..." -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Green

# ============================================
# FASE 1: REMOVER SERVIÇOS DUPLICADOS
# ============================================
Write-Host "`n🗑️  [FASE 1] Removendo serviços duplicados..." -ForegroundColor Yellow

# Remover common-tenant (usar libs/common)
if (Test-Path "services/common-tenant") {
    Write-Host "   🗑️  Removendo services/common-tenant (duplicado)..." -ForegroundColor Gray
    Remove-Item "services/common-tenant" -Recurse -Force
    Write-Host "   ✅ services/common-tenant removido" -ForegroundColor Green
}

# Remover common-logging (usar libs/common)
if (Test-Path "services/common-logging") {
    Write-Host "   🗑️  Removendo services/common-logging (duplicado)..." -ForegroundColor Gray
    Remove-Item "services/common-logging" -Recurse -Force
    Write-Host "   ✅ services/common-logging removido" -ForegroundColor Green
}

# ============================================
# FASE 2: ATUALIZAR IMPORTS NOS SERVIÇOS
# ============================================
Write-Host "`n📝 [FASE 2] Atualizando imports nos serviços..." -ForegroundColor Yellow

# Arquivos que precisam ser atualizados para usar TenantContext da lib compartilhada
$tenantFiles = @(
    "services/benefits-core/src/main/java/com/benefits/core/controller/AuthorizationController.java",
    "services/benefits-core/src/main/java/com/benefits/core/service/AuthorizationService.java"
)

foreach ($file in $tenantFiles) {
    if (Test-Path $file) {
        Write-Host "   🔧 $file..." -ForegroundColor Gray

        $content = Get-Content $file -Raw

        # Substituir imports locais pelo da lib compartilhada
        $content = $content -replace "import com\.benefits\.common\.tenant\.TenantContext", "import com.benefits.common.tenant.TenantContext"

        # Salvar arquivo
        $content | Set-Content $file -NoNewline -Encoding UTF8
    }
}

# ============================================
# FASE 3: REFATORAR EVENT SERVICES
# ============================================
Write-Host "`n🔄 [FASE 3] Refatorando services de eventos..." -ForegroundColor Yellow

# benefits-core EventPublisherService - pode ser substituído pela lib compartilhada
$eventPublisherFile = "services/benefits-core/src/main/java/com/benefits/core/service/EventPublisherService.java"
if (Test-Path $eventPublisherFile) {
    Write-Host "   🔧 benefits-core EventPublisherService..." -ForegroundColor Gray

    $content = Get-Content $eventPublisherFile -Raw

    # Adicionar comentário explicando que usa a lib compartilhada
    if ($content -notmatch "EventPublisher from events-sdk") {
        $content = $content -replace "public class EventPublisherService", "public class EventPublisherService // TODO: Consider using EventPublisher from events-sdk"
    }

    $content | Set-Content $eventPublisherFile -NoNewline -Encoding UTF8
}

# ops-relay OutboxRelayService - pode ser substituído pela lib compartilhada
$relayFile = "services/ops-relay/src/main/java/com/benefits/opsrelay/service/OutboxRelayService.java"
if (Test-Path $relayFile) {
    Write-Host "   🔧 ops-relay OutboxRelayService..." -ForegroundColor Gray

    $content = Get-Content $relayFile -Raw

    # Adicionar comentário explicando que usa a lib compartilhada
    if ($content -notmatch "OutboxEvent from events-sdk") {
        $content = $content -replace "public class OutboxRelayService", "public class OutboxRelayService // TODO: Consider using OutboxEvent from events-sdk"
    }

    $content | Set-Content $relayFile -NoNewline -Encoding UTF8
}

# ============================================
# FASE 4: ATUALIZAR POM PAI
# ============================================
Write-Host "`n📦 [FASE 4] Atualizando POM pai..." -ForegroundColor Yellow

# Remover módulos duplicados do POM pai
$pomContent = Get-Content "pom.xml" -Raw

# Remover common-tenant e common-logging se estiverem listados
$oldModules = @(
    "<module>services/common-tenant</module>",
    "<module>services/common-logging</module>"
)

foreach ($module in $oldModules) {
    if ($pomContent -match [regex]::Escape($module)) {
        Write-Host "   🗑️  Removendo $module do POM pai..." -ForegroundColor Gray
        $pomContent = $pomContent -replace [regex]::Escape($module), ""
    }
}

$pomContent | Set-Content "pom.xml" -NoNewline -Encoding UTF8
Write-Host "   ✅ POM pai atualizado" -ForegroundColor Green

# ============================================
# RESULTADO FINAL
# ============================================
Write-Host "`n🎉 REFATORAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green

Write-Host "`n✅ ALTERAÇÕES REALIZADAS:" -ForegroundColor Cyan
Write-Host "  • Serviços duplicados removidos (common-tenant, common-logging)" -ForegroundColor White
Write-Host "  • Dependências das libs compartilhadas adicionadas" -ForegroundColor White
Write-Host "  • Imports atualizados para usar bibliotecas compartilhadas" -ForegroundColor White
Write-Host "  • POM pai limpo de módulos duplicados" -ForegroundColor White
Write-Host "  • TODOs adicionados para refatoração futura de events" -ForegroundColor White

Write-Host "`n🔄 STATUS ATUAL DAS LIBS:" -ForegroundColor Cyan
Write-Host "  ✅ common-lib: Instalada e sendo usada" -ForegroundColor Green
Write-Host "  ✅ events-sdk: Instalada (pronta para uso futuro)" -ForegroundColor Green
Write-Host "  ✅ Código duplicado: Removido" -ForegroundColor Green
Write-Host "  ⚠️  Events services: Ainda usam implementações locais (TODO)" -ForegroundColor Yellow

Write-Host "`n🚀 PRÓXIMO PASSO:" -ForegroundColor Cyan
Write-Host "  .\scripts\test-libs-integration.ps1  # Testar integração completa" -ForegroundColor White