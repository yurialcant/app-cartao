# Analisador Profundo de Código - Clean Architecture
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "🔍 ANÁLISE PROFUNDA DO CÓDIGO - CLEAN ARCHITECTURE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Estrutura esperada da Clean Architecture
$CleanArchitecture = @{
    "lib/core" = @{
        "config" = "Configurações e constantes",
        "domain" = "Entidades e casos de uso",
        "data" = "Repositórios e fontes de dados",
        "infrastructure" = "Implementações externas",
        "utils" = "Utilitários e helpers"
    }
    "lib/presentation" = @{
        "screens" = "Telas da aplicação",
        "widgets" = "Widgets reutilizáveis",
        "providers" = "Gerenciadores de estado",
        "controllers" = "Controladores de tela"
    }
    "lib/features" = @{
        "auth" = "Funcionalidade de autenticação",
        "dashboard" = "Funcionalidade do dashboard",
        "profile" = "Funcionalidade de perfil"
    }
}

# Função para analisar imports não utilizados
function Analyze-UnusedImports {
    Write-Host "`n📚 ANALISANDO IMPORTS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $unusedImports = @()
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $lines = $content -split "`n"
        
        foreach ($line in $lines) {
            if ($line -match "^import\s+['""]([^'""]+)['""];?$") {
                $import = $matches[1]
                $importName = ($import -split "/")[-1] -replace "\.dart$", ""
                
                # Verificar se o import é usado no arquivo
                $isUsed = $false
                foreach ($checkLine in $lines) {
                    if ($checkLine -match "\b$importName\b" -and $checkLine -notmatch "^import") {
                        $isUsed = $true
                        break
                    }
                }
                
                if (-not $isUsed) {
                    $unusedImports += @{
                        File = $file.FullName
                        Import = $import
                        Line = ($lines | Select-String $import).LineNumber
                    }
                }
            }
        }
    }
    
    return $unusedImports
}

# Função para analisar métodos não utilizados
function Analyze-UnusedMethods {
    Write-Host "`n🔧 ANALISANDO MÉTODOS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $unusedMethods = @()
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        
        # Encontrar métodos privados
        $privateMethods = [regex]::Matches($content, "void\s+_\w+\s*\([^)]*\)\s*\{")
        
        foreach ($method in $privateMethods) {
            $methodName = ($method.Value -split "\s+")[1]
            $methodName = $methodName -replace "\(.*$", ""
            
            # Verificar se o método é chamado
            $isCalled = $content -match "\b$methodName\s*\("
            if (-not $isCalled) {
                $unusedMethods += @{
                    File = $file.FullName
                    Method = $methodName
                    Line = ($content.Substring(0, $method.Index) -split "`n").Count
                }
            }
        }
    }
    
    return $unusedMethods
}

# Função para analisar arquivos não utilizados
function Analyze-UnusedFiles {
    Write-Host "`n📁 ANALISANDO ARQUIVOS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $unusedFiles = @()
    
    foreach ($file in $dartFiles) {
        $fileName = $file.Name -replace "\.dart$", ""
        $isReferenced = $false
        
        # Verificar se o arquivo é referenciado em outros arquivos
        foreach ($otherFile in $dartFiles) {
            if ($otherFile.FullName -ne $file.FullName) {
                $content = Get-Content $otherFile.FullName -Raw
                if ($content -match "import.*$fileName") {
                    $isReferenced = $true
                    break
                }
            }
        }
        
        # Verificar se é um arquivo principal (main.dart, app_router.dart, etc.)
        $isMainFile = $fileName -match "^(main|app_router|app_version|env_config)$"
        
        if (-not $isReferenced -and -not $isMainFile) {
            $unusedFiles += $file.FullName
        }
    }
    
    return $unusedFiles
}

# Função para verificar estrutura da Clean Architecture
function Analyze-CleanArchitecture {
    Write-Host "`n🏗️ ANALISANDO ESTRUTURA CLEAN ARCHITECTURE..." -ForegroundColor Yellow
    
    $issues = @()
    
    foreach ($layer in $CleanArchitecture.Keys) {
        $layerPath = "lib/$layer"
        if (-not (Test-Path $layerPath)) {
            $issues += "❌ Camada '$layer' não encontrada"
            continue
        }
        
        foreach ($subfolder in $CleanArchitecture[$layer].Keys) {
            $subfolderPath = "$layerPath/$subfolder"
            if (-not (Test-Path $subfolderPath)) {
                $issues += "⚠️ Subpasta '$subfolder' não encontrada em $layer"
            } else {
                $files = Get-ChildItem $subfolderPath -Filter "*.dart" -Recurse
                if ($files.Count -eq 0) {
                    $issues += "⚠️ Subpasta '$subfolder' está vazia"
                }
            }
        }
    }
    
    return $issues
}

# Função para analisar dependências circulares
function Analyze-CircularDependencies {
    Write-Host "`n🔄 ANALISANDO DEPENDÊNCIAS CIRCULARES..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $circularDeps = @()
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $imports = [regex]::Matches($content, "import\s+['""]([^'""]+)['""];?")
        
        foreach ($import in $imports) {
            $importPath = $import.Groups[1].Value
            
            # Verificar se é um import relativo
            if ($importPath.StartsWith(".")) {
                $importFile = Join-Path (Split-Path $file.FullName) $importPath
                if (Test-Path "$importFile.dart") {
                    $importFile = "$importFile.dart"
                    
                    # Verificar se o arquivo importado também importa o arquivo atual
                    $importContent = Get-Content $importFile -Raw
                    $currentFileName = (Split-Path $file.FullName -Leaf) -replace "\.dart$", ""
                    if ($importContent -match "import.*$currentFileName") {
                        $circularDeps += @{
                            File1 = $file.FullName
                            File2 = $importFile
                        }
                    }
                }
            }
        }
    }
    
    return $circularDeps
}

# Executar análises
Write-Host "`n🚀 INICIANDO ANÁLISES..." -ForegroundColor Green

$unusedImports = Analyze-UnusedImports
$unusedMethods = Analyze-UnusedMethods
$unusedFiles = Analyze-UnusedFiles
$cleanArchIssues = Analyze-CleanArchitecture
$circularDeps = Analyze-CircularDependencies

# Exibir resultados
Write-Host "`n📊 RESULTADOS DA ANÁLISE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Imports não utilizados
Write-Host "`n📚 IMPORTS NÃO UTILIZADOS: $($unusedImports.Count)" -ForegroundColor Yellow
if ($unusedImports.Count -gt 0) {
    foreach ($import in $unusedImports) {
        Write-Host "  ❌ $($import.File):$($import.Line) - $($import.Import)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Nenhum import não utilizado encontrado" -ForegroundColor Green
}

# Métodos não utilizados
Write-Host "`n🔧 MÉTODOS NÃO UTILIZADOS: $($unusedMethods.Count)" -ForegroundColor Yellow
if ($unusedMethods.Count -gt 0) {
    foreach ($method in $unusedMethods) {
        Write-Host "  ❌ $($method.File):$($method.Line) - $($method.Method)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Nenhum método não utilizado encontrado" -ForegroundColor Green
}

# Arquivos não utilizados
Write-Host "`n📁 ARQUIVOS NÃO UTILIZADOS: $($unusedFiles.Count)" -ForegroundColor Yellow
if ($unusedFiles.Count -gt 0) {
    foreach ($file in $unusedFiles) {
        Write-Host "  ❌ $file" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Nenhum arquivo não utilizado encontrado" -ForegroundColor Green
}

# Problemas de Clean Architecture
Write-Host "`n🏗️ PROBLEMAS DE CLEAN ARCHITECTURE: $($cleanArchIssues.Count)" -ForegroundColor Yellow
if ($cleanArchIssues.Count -gt 0) {
    foreach ($issue in $cleanArchIssues) {
        Write-Host "  ⚠️ $issue" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✅ Estrutura Clean Architecture está correta" -ForegroundColor Green
}

# Dependências circulares
Write-Host "`n🔄 DEPENDÊNCIAS CIRCULARES: $($circularDeps.Count)" -ForegroundColor Yellow
if ($circularDeps.Count -gt 0) {
    foreach ($dep in $circularDeps) {
        Write-Host "  ❌ $($dep.File1) ↔ $($dep.File2)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Nenhuma dependência circular encontrada" -ForegroundColor Green
}

# Resumo
$totalIssues = $unusedImports.Count + $unusedMethods.Count + $unusedFiles.Count + $cleanArchIssues.Count + $circularDeps.Count

Write-Host "`n📈 RESUMO DA ANÁLISE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "🔍 Total de problemas encontrados: $totalIssues" -ForegroundColor White
Write-Host "📚 Imports não utilizados: $($unusedImports.Count)" -ForegroundColor White
Write-Host "🔧 Métodos não utilizados: $($unusedMethods.Count)" -ForegroundColor White
Write-Host "📁 Arquivos não utilizados: $($unusedFiles.Count)" -ForegroundColor White
Write-Host "🏗️ Problemas de arquitetura: $($cleanArchIssues.Count)" -ForegroundColor White
Write-Host "🔄 Dependências circulares: $($circularDeps.Count)" -ForegroundColor White

if ($totalIssues -eq 0) {
    Write-Host "`n🎉 CÓDIGO PERFEITO! Nenhum problema encontrado." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Foram encontrados $totalIssues problemas para corrigir." -ForegroundColor Yellow
    Write-Host "Execute o script de correção automática para resolver os problemas." -ForegroundColor White
}

Write-Host "`n🚀 ANÁLISE CONCLUÍDA!" -ForegroundColor Green
