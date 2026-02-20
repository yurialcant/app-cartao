# Corretor Automático de Código - Clean Architecture
# Autor: Assistant
# Data: $(Get-Date -Format "yyyy-MM-dd HH:mm-dd")

param(
    [switch]$AutoFix,
    [switch]$Backup,
    [switch]$Preview
)

Write-Host "🔧 CORRETOR AUTOMÁTICO DE CÓDIGO - CLEAN ARCHITECTURE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Função para fazer backup dos arquivos
function Backup-Files {
    if (-not $Backup) { return }
    
    Write-Host "`n💾 FAZENDO BACKUP DOS ARQUIVOS..." -ForegroundColor Yellow
    $backupDir = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    foreach ($file in $dartFiles) {
        $relativePath = $file.FullName.Replace((Get-Location).Path, "")
        $backupPath = Join-Path $backupDir $relativePath
        $backupDirPath = Split-Path $backupPath -Parent
        
        if (-not (Test-Path $backupDirPath)) {
            New-Item -ItemType Directory -Path $backupDirPath -Force | Out-Null
        }
        
        Copy-Item $file.FullName $backupPath
    }
    
    Write-Host "✅ Backup criado em: $backupDir" -ForegroundColor Green
}

# Função para remover imports não utilizados
function Remove-UnusedImports {
    Write-Host "`n📚 REMOVENDO IMPORTS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $removedImports = 0
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        $lines = $content -split "`n"
        $newLines = @()
        $skipNext = $false
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            if ($line -match "^import\s+['""]([^'""]+)['""];?$") {
                $import = $matches[1]
                $importName = ($import -split "/")[-1] -replace "\.dart$", ""
                
                # Verificar se o import é usado no arquivo
                $isUsed = $false
                for ($j = 0; $j -lt $lines.Count; $j++) {
                    if ($j -ne $i -and $lines[$j] -match "\b$importName\b" -and $lines[$j] -notmatch "^import") {
                        $isUsed = $true
                        break
                    }
                }
                
                if (-not $isUsed) {
                    if ($Preview) {
                        Write-Host "  📝 Removeria import: $import de $($file.Name)" -ForegroundColor Yellow
                    } else {
                        Write-Host "  ❌ Removendo import: $import de $($file.Name)" -ForegroundColor Red
                        $removedImports++
                        continue
                    }
                }
            }
            
            $newLines += $line
        }
        
        if (-not $Preview -and $content -ne ($newLines -join "`n")) {
            $newLines -join "`n" | Set-Content $file.FullName -NoNewline
        }
    }
    
    return $removedImports
}

# Função para remover métodos não utilizados
function Remove-UnusedMethods {
    Write-Host "`n🔧 REMOVENDO MÉTODOS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $removedMethods = 0
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        # Encontrar métodos privados não utilizados
        $pattern = "void\s+(_\w+)\s*\([^)]*\)\s*\{[^{}]*\}"
        $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        foreach ($match in $matches) {
            $methodName = $match.Groups[1].Value
            
            # Verificar se o método é chamado
            $isCalled = $content -match "\b$methodName\s*\("
            if (-not $isCalled) {
                if ($Preview) {
                    Write-Host "  📝 Removeria método: $methodName de $($file.Name)" -ForegroundColor Yellow
                } else {
                    Write-Host "  ❌ Removendo método: $methodName de $($file.Name)" -ForegroundColor Red
                    $content = $content.Replace($match.Value, "")
                    $removedMethods++
                }
            }
        }
        
        if (-not $Preview -and $content -ne $originalContent) {
            $content | Set-Content $file.FullName -NoNewline
        }
    }
    
    return $removedMethods
}

# Função para remover arquivos não utilizados
function Remove-UnusedFiles {
    Write-Host "`n📁 REMOVENDO ARQUIVOS NÃO UTILIZADOS..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $unusedFiles = @()
    $removedFiles = 0
    
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
        
        # Verificar se é um arquivo principal
        $isMainFile = $fileName -match "^(main|app_router|app_version|env_config)$"
        
        if (-not $isReferenced -and -not $isMainFile) {
            $unusedFiles += $file.FullName
        }
    }
    
    foreach ($file in $unusedFiles) {
        if ($Preview) {
            Write-Host "  📝 Removeria arquivo: $file" -ForegroundColor Yellow
        } else {
            Write-Host "  ❌ Removendo arquivo: $file" -ForegroundColor Red
            Remove-Item $file -Force
            $removedFiles++
        }
    }
    
    return $removedFiles
}

# Função para reorganizar estrutura da Clean Architecture
function Reorganize-CleanArchitecture {
    Write-Host "`n🏗️ REORGANIZANDO ESTRUTURA CLEAN ARCHITECTURE..." -ForegroundColor Yellow
    
    $changes = 0
    
    # Criar estrutura de pastas se não existir
    $structure = @{
        "lib/core/domain" = "Entidades e casos de uso",
        "lib/core/data" = "Repositórios e fontes de dados", 
        "lib/core/infrastructure" = "Implementações externas",
        "lib/features/auth" = "Funcionalidade de autenticação",
        "lib/features/dashboard" = "Funcionalidade do dashboard",
        "lib/features/profile" = "Funcionalidade de perfil",
        "lib/presentation/widgets" = "Widgets reutilizáveis",
        "lib/presentation/controllers" = "Controladores de tela"
    }
    
    foreach ($folder in $structure.Keys) {
        if (-not (Test-Path $folder)) {
            if ($Preview) {
                Write-Host "  📝 Criaria pasta: $folder" -ForegroundColor Yellow
            } else {
                Write-Host "  📁 Criando pasta: $folder" -ForegroundColor Green
                New-Item -ItemType Directory -Path $folder -Force | Out-Null
                $changes++
            }
        }
    }
    
    # Mover arquivos para suas pastas corretas
    $fileMoves = @{
        "lib/core/storage/app_storage.dart" = "lib/core/data/",
        "lib/data/services/auth_service.dart" = "lib/core/data/",
        "lib/data/models/user_model.dart" = "lib/core/domain/",
        "lib/presentation/providers/auth_provider.dart" = "lib/presentation/controllers/"
    }
    
    foreach ($move in $fileMoves.GetEnumerator()) {
        $source = $move.Key
        $destination = $move.Value
        
        if (Test-Path $source) {
            if ($Preview) {
                Write-Host "  📝 Moveria: $source → $destination" -ForegroundColor Yellow
            } else {
                Write-Host "  🔄 Movendo: $source → $destination" -ForegroundColor Blue
                $destPath = Join-Path $destination (Split-Path $source -Leaf)
                Move-Item $source $destPath -Force
                $changes++
            }
        }
    }
    
    return $changes
}

# Função para resolver dependências circulares
function Resolve-CircularDependencies {
    Write-Host "`n🔄 RESOLVENDO DEPENDÊNCIAS CIRCULARES..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $resolvedDeps = 0
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        # Verificar imports relativos que podem causar dependências circulares
        $imports = [regex]::Matches($content, "import\s+['""]([^'""]+)['""];?")
        
        foreach ($import in $imports) {
            $importPath = $import.Groups[1].Value
            
            if ($importPath.StartsWith(".")) {
                $importFile = Join-Path (Split-Path $file.FullName) $importPath
                if (Test-Path "$importFile.dart") {
                    $importFile = "$importFile.dart"
                    
                    # Verificar se há dependência circular
                    $importContent = Get-Content $importFile -Raw
                    $currentFileName = (Split-Path $file.FullName -Leaf) -replace "\.dart$", ""
                    
                    if ($importContent -match "import.*$currentFileName") {
                        if ($Preview) {
                            Write-Host "  📝 Resolveria dependência circular: $($file.Name) ↔ $((Split-Path $importFile -Leaf))" -ForegroundColor Yellow
                        } else {
                            Write-Host "  🔄 Resolvendo dependência circular: $($file.Name) ↔ $((Split-Path $importFile -Leaf))" -ForegroundColor Blue
                            
                            # Substituir import relativo por import absoluto
                            $absolutePath = $importPath -replace "^\.\./", "lib/"
                            $content = $content.Replace($import.Value, "import '$absolutePath';")
                            $resolvedDeps++
                        }
                    }
                }
            }
        }
        
        if (-not $Preview -and $content -ne $originalContent) {
            $content | Set-Content $file.FullName -NoNewline
        }
    }
    
    return $resolvedDeps
}

# Função para aplicar formatação e padrões
function Apply-CodeStandards {
    Write-Host "`n✨ APLICANDO PADRÕES DE CÓDIGO..." -ForegroundColor Yellow
    
    $dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse
    $changes = 0
    
    foreach ($file in $dartFiles) {
        $content = Get-Content $file.FullName -Raw
        $originalContent = $content
        
        # Remover linhas em branco duplicadas
        $content = [regex]::Replace($content, "`n{3,}", "`n`n")
        
        # Remover espaços em branco no final das linhas
        $content = [regex]::Replace($content, "[ \t]+`n", "`n")
        
        # Adicionar linha em branco no final se não existir
        if (-not $content.EndsWith("`n")) {
            $content += "`n"
        }
        
        if ($content -ne $originalContent) {
            if ($Preview) {
                Write-Host "  📝 Formataría: $($file.Name)" -ForegroundColor Yellow
            } else {
                Write-Host "  ✨ Formatando: $($file.Name)" -ForegroundColor Green
                $content | Set-Content $file.FullName -NoNewline
                $changes++
            }
        }
    }
    
    return $changes
}

# Executar correções
Write-Host "`n🚀 INICIANDO CORREÇÕES..." -ForegroundColor Green

if ($Backup) {
    Backup-Files
}

$removedImports = Remove-UnusedImports
$removedMethods = Remove-UnusedMethods  
$removedFiles = Remove-UnusedFiles
$archChanges = Reorganize-CleanArchitecture
$resolvedDeps = Resolve-CircularDependencies
$codeStandards = Apply-CodeStandards

# Resumo das correções
Write-Host "`n📊 RESUMO DAS CORREÇÕES" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

if ($Preview) {
    Write-Host "🔍 MODO PREVIEW - Nenhuma alteração foi feita" -ForegroundColor Yellow
    Write-Host "Use -AutoFix para aplicar as correções" -ForegroundColor White
} else {
    Write-Host "✅ Imports removidos: $removedImports" -ForegroundColor Green
    Write-Host "✅ Métodos removidos: $removedMethods" -ForegroundColor Green
    Write-Host "✅ Arquivos removidos: $removedFiles" -ForegroundColor Green
    Write-Host "✅ Mudanças de arquitetura: $archChanges" -ForegroundColor Green
    Write-Host "✅ Dependências circulares resolvidas: $resolvedDeps" -ForegroundColor Green
    Write-Host "✅ Padrões de código aplicados: $codeStandards" -ForegroundColor Green
}

$totalChanges = $removedImports + $removedMethods + $removedFiles + $archChanges + $resolvedDeps + $codeStandards

Write-Host "`n📈 TOTAL DE ALTERAÇÕES: $totalChanges" -ForegroundColor White

if ($totalChanges -gt 0) {
    Write-Host "`n🎉 CÓDIGO LIMPO E ORGANIZADO!" -ForegroundColor Green
    Write-Host "Execute o code_analyzer.ps1 novamente para verificar se os problemas foram resolvidos." -ForegroundColor White
} else {
    Write-Host "`n✨ Nenhuma correção necessária!" -ForegroundColor Green
}

Write-Host "`n🚀 CORREÇÃO CONCLUÍDA!" -ForegroundColor Green
