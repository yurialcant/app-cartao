# Script de Limpeza do Projeto - Remove arquivos desnecessários
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "🧹 LIMPEZA DO PROJETO FLUTTER" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Lista de arquivos e pastas desnecessárias
$UnnecessaryItems = @(
    "flutter_login_app_v1.0.0_complete_20250825_153030.zip",
    "generate_android_builds.ps1",
    "generate_simple_builds.ps1", 
    "generate_builds.ps1",
    "auto_build_loop.ps1",
    "builds_android",
    "builds_simple",
    "builds",
    ".idea",
    "windows",
    "macos",
    "linux",
    "build"
)

Write-Host "📋 Itens identificados para remoção:" -ForegroundColor Yellow
foreach ($item in $UnnecessaryItems) {
    if (Test-Path $item) {
        $size = if (Test-Path $item -PathType Leaf) { 
            [math]::Round((Get-Item $item).Length / 1MB, 2) 
        } else { 
            "Pasta" 
        }
        Write-Host "  ❌ $item ($size)" -ForegroundColor Red
    } else {
        Write-Host "  ✅ $item (não encontrado)" -ForegroundColor Green
    }
}

Write-Host "`n🗑️ Iniciando limpeza..." -ForegroundColor Yellow

$totalFreed = 0
$removedItems = 0

foreach ($item in $UnnecessaryItems) {
    if (Test-Path $item) {
        try {
            if (Test-Path $item -PathType Leaf) {
                # Arquivo
                $size = (Get-Item $item).Length
                Remove-Item $item -Force
                $totalFreed += $size
                $removedItems++
                Write-Host "✅ Removido arquivo: $item ($([math]::Round($size / 1MB, 2)) MB)" -ForegroundColor Green
            } else {
                # Pasta
                Remove-Item $item -Recurse -Force
                $removedItems++
                Write-Host "✅ Removida pasta: $item" -ForegroundColor Green
            }
        } catch {
            Write-Host "❌ Erro ao remover $item : $_" -ForegroundColor Red
        }
    }
}

# Limpeza adicional
Write-Host "`n🧹 Limpeza adicional..." -ForegroundColor Yellow

# Limpar cache do Flutter
try {
    flutter clean
    Write-Host "✅ Cache do Flutter limpo" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao limpar cache do Flutter" -ForegroundColor Red
}

# Limpar dependências antigas
try {
    Remove-Item ".dart_tool" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Dependências antigas removidas" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Erro ao remover dependências antigas" -ForegroundColor Yellow
}

# Resumo da limpeza
Write-Host "`n📊 RESUMO DA LIMPEZA" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🗑️ Itens removidos: $removedItems" -ForegroundColor White
Write-Host "💾 Espaço liberado: $([math]::Round($totalFreed / 1MB, 2)) MB" -ForegroundColor Green

Write-Host "`n🚀 PROJETO LIMPO E OTIMIZADO!" -ForegroundColor Green
Write-Host "Agora você pode usar o smart_build_system.ps1 para builds inteligentes." -ForegroundColor White
