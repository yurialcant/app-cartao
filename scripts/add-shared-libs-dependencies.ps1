# add-shared-libs-dependencies.ps1
# Adiciona dependências das bibliotecas compartilhadas aos serviços

Write-Host "📚 ADICIONANDO DEPENDÊNCIAS DAS BIBLIOTECAS COMPARTILHADAS..." -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Green

# Serviços que devem usar as bibliotecas compartilhadas
$services = @(
    "services/benefits-core/pom.xml",
    "services/tenant-service/pom.xml",
    "services/identity-service/pom.xml",
    "services/payments-orchestrator/pom.xml",
    "services/ops-relay/pom.xml",
    "bffs/user-bff/pom.xml",
    "bffs/admin-bff/pom.xml",
    "bffs/merchant-bff/pom.xml"
)

foreach ($pomPath in $services) {
    if (!(Test-Path $pomPath)) {
        Write-Host "   ⚠️  $pomPath não encontrado, pulando..." -ForegroundColor Yellow
        continue
    }

    Write-Host "   📦 $pomPath..." -ForegroundColor Gray

    $content = Get-Content $pomPath -Raw

    # Verificar se já tem as dependências
    $hasCommonLib = $content -match "common-lib"
    $hasEventsSdk = $content -match "events-sdk"

    if ($hasCommonLib -and $hasEventsSdk) {
        Write-Host "   ✅ Já tem as dependências" -ForegroundColor Green
        continue
    }

    # Adicionar dependências se não existirem
    $dependenciesSection = @"

        <!-- Shared Libraries -->
        <dependency>
            <groupId>com.benefits</groupId>
            <artifactId>common-lib</artifactId>
            <version>1.0.0-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>com.benefits</groupId>
            <artifactId>events-sdk</artifactId>
            <version>1.0.0-SNAPSHOT</version>
        </dependency>
"@

    # Inserir antes do fechamento de </dependencies>
    if ($content -match "</dependencies>") {
        $content = $content -replace "</dependencies>", "$dependenciesSection`n    </dependencies>"
        $content | Set-Content $pomPath -NoNewline -Encoding UTF8
        Write-Host "   ✅ Dependências adicionadas" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Seção </dependencies> não encontrada" -ForegroundColor Red
    }
}

Write-Host "`n🎉 DEPENDÊNCIAS DAS BIBLIOTECAS COMPARTILHADAS ADICIONADAS!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green

Write-Host "`n✅ SERVIÇOS ATUALIZADOS:" -ForegroundColor Cyan
foreach ($service in $services) {
    Write-Host "  • $service" -ForegroundColor White
}

Write-Host "`n🚀 PRÓXIMO PASSO:" -ForegroundColor Cyan
Write-Host "  .\scripts\compile-with-shared-libs.ps1  # Testar compilação" -ForegroundColor White