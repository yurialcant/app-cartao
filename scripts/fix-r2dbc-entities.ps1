#!/usr/bin/env pwsh
# fix-r2dbc-entities.ps1
# Fine-tune R2DBC entity conversions

$ErrorActionPreference = "Stop"
$rootPath = "c:\Users\gesch\Documents\projeto-lucas"

function Fix-R2dbcEntity {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $modified = $false
    
    # 1. Fix @Table annotation format
    if ($content -match '@Table\(name\s*=\s*"([^"]+)"\)') {
        $tableName = $matches[1]
        $content = $content -replace '@Table\(name\s*=\s*"' + [regex]::Escape($tableName) + '"\)', "@Table(`"$tableName`")"
        $modified = $true
    }
    
    # 2. Remove @Column unsupported attributes in R2DBC
    # Remove nullable, unique, length from @Column
    $content = $content -replace '@Column\(([^)]*?)\bnullable\s*=\s*(true|false)\s*,?\s*', '@Column($1'
    $content = $content -replace '@Column\(([^)]*?)\bunique\s*=\s*(true|false)\s*,?\s*', '@Column($1'
    $content = $content -replace '@Column\(([^)]*?)\blength\s*=\s*\d+\s*,?\s*', '@Column($1'
    $content = $content -replace '@Column\(([^)]*?)\bcolumnDefinition\s*=\s*"[^"]*"\s*,?\s*', '@Column($1'
    $content = $content -replace '@Column\(([^)]*?)\bprecision\s*=\s*\d+\s*,?\s*', '@Column($1'
    $content = $content -replace '@Column\(([^)]*?)\bscale\s*=\s*\d+\s*,?\s*', '@Column($1'
    
    # Clean up empty @Column() or @Column(,)
    $content = $content -replace '@Column\(\s*,?\s*\)\s*\n', ''
    $content = $content -replace '@Column\(\s*\)\s*\n', ''
    
    # 3. Fix extra whitespace after @Id
    $content = $content -replace '@Id\s+\n\s+private', "@Id`n    private"
    
    # 4. Remove @org.hibernate.annotations.JdbcTypeCode (not in R2DBC)
    $content = $content -replace '@org\.hibernate\.annotations\.JdbcTypeCode\([^)]+\)\s*\n', ''
    
    if ($modified) {
        Set-Content -Path $FilePath -Value $content -NoNewline
        return $true
    }
    return $false
}

function Fix-R2dbcRepository {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    $modified = $false
    
    # Ensure proper imports are in place
    if ($content -notmatch 'import reactor\.core\.publisher\.Mono;') {
        $content = $content -replace '(package [^;]+;\s*\n)', "`$1`nimport reactor.core.publisher.Mono;`nimport reactor.core.publisher.Flux;`n"
        $modified = $true
    }
    
    # Remove duplicate import lines
    $lines = $content -split "`n"
    $uniqueLines = @()
    $seenImports = @{}
    
    foreach ($line in $lines) {
        if ($line -match '^import\s+([^;]+);') {
            $importName = $matches[1]
            if (-not $seenImports.ContainsKey($importName)) {
                $seenImports[$importName] = $true
                $uniqueLines += $line
            }
        } else {
            $uniqueLines += $line
        }
    }
    
    $newContent = $uniqueLines -join "`n"
    if ($newContent -ne $content) {
        Set-Content -Path $FilePath -Value $newContent -NoNewline
        return $true
    }
    
    return $false
}

# Process both services
Write-Host "`n🔧 Fine-tuning R2DBC conversions..." -ForegroundColor Magenta

$services = @(
    @{ Name = "benefits-core"; EntityPath = "services\benefits-core\src\main\java\com\benefits\core\entity"; RepoPath = "services\benefits-core\src\main\java\com\benefits\core\repository" },
    @{ Name = "tenant-service"; EntityPath = "services\tenant-service\src\main\java\com\benefits\tenantservice\entity"; RepoPath = "services\tenant-service\src\main\java\com\benefits\tenantservice\repository" }
)

foreach ($svc in $services) {
    Write-Host "`n📦 Processing $($svc.Name)..." -ForegroundColor Yellow
    
    # Fix entities
    $entityPath = Join-Path $rootPath $svc.EntityPath
    $entities = Get-ChildItem -Path $entityPath -Filter "*.java"
    foreach ($entity in $entities) {
        if (Fix-R2dbcEntity -FilePath $entity.FullName) {
            Write-Host "  ✅ Fixed: $($entity.Name)" -ForegroundColor Green
        }
    }
    
    # Fix repositories
    $repoPath = Join-Path $rootPath $svc.RepoPath
    $repos = Get-ChildItem -Path $repoPath -Filter "*.java"
    foreach ($repo in $repos) {
        if (Fix-R2dbcRepository -FilePath $repo.FullName) {
            Write-Host "  ✅ Fixed: $($repo.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "`n✅ Fine-tuning completed!`n" -ForegroundColor Green
