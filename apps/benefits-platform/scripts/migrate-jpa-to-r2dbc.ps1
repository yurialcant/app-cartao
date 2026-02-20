#!/usr/bin/env pwsh
# migrate-jpa-to-r2dbc.ps1
# Migrates JPA entities and repositories to R2DBC for benefits-core and tenant-service

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("benefits-core", "tenant-service", "both")]
    [string]$Service = "both"
)

$ErrorActionPreference = "Stop"
$rootPath = "c:\Users\gesch\Documents\projeto-lucas"

function Convert-JpaToR2dbc {
    param(
        [string]$FilePath
    )
    
    Write-Host "  Converting: $($FilePath | Split-Path -Leaf)" -ForegroundColor Cyan
    
    $content = Get-Content $FilePath -Raw
    $modified = $false
    
    # 1. Replace imports
    if ($content -match 'import jakarta\.persistence\.\*;') {
        $content = $content -replace 'import jakarta\.persistence\.\*;', @'
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;
'@
        $modified = $true
    }
    
    # 2. Remove @Entity annotation
    if ($content -match '@Entity\s*\n') {
        $content = $content -replace '@Entity\s*\n', ''
        $modified = $true
    }
    
    # 3. Replace @Table(name = "...") with @Table("...")
    if ($content -match '@Table\(name\s*=\s*"([^"]+)"\)') {
        $tableName = $matches[1]
        $content = $content -replace '@Table\(name\s*=\s*"' + [regex]::Escape($tableName) + '"\)', "@Table(`"$tableName`")"
        $modified = $true
    }
    
    # 4. Remove @GeneratedValue
    if ($content -match '@GeneratedValue\([^)]+\)\s*\n') {
        $content = $content -replace '@GeneratedValue\([^)]+\)\s*\n', ''
        $modified = $true
    }
    
    # 5. Remove @Enumerated (R2DBC handles this automatically)
    if ($content -match '@Enumerated\(EnumType\.[A-Z]+\)\s*\n') {
        $content = $content -replace '@Enumerated\(EnumType\.[A-Z]+\)\s*\n', ''
        $modified = $true
    }
    
    # 6. Remove @PrePersist and @PreUpdate (use @EnableR2dbcAuditing instead)
    if ($content -match '@PrePersist\s*\n\s*protected void onCreate\(\) \{[^}]+\}\s*\n') {
        $content = $content -replace '@PrePersist\s*\n\s*protected void onCreate\(\) \{[^}]+\}\s*\n', ''
        $modified = $true
    }
    
    if ($content -match '@PreUpdate\s*\n\s*protected void onUpdate\(\) \{[^}]+\}\s*\n') {
        $content = $content -replace '@PreUpdate\s*\n\s*protected void onUpdate\(\) \{[^}]+\}\s*\n', ''
        $modified = $true
    }
    
    # 7. Handle @Column annotations - keep them as-is for R2DBC
    # R2DBC @Column is compatible
    
    # 8. Remove unique constraints from @Table (not supported in R2DBC)
    if ($content -match '@Table\([^)]*uniqueConstraints[^)]+\)') {
        $content = $content -replace ',\s*uniqueConstraints\s*=\s*\{[^}]+\}', ''
        $modified = $true
    }
    
    # 9. Remove columnDefinition (handle JSON differently)
    # This is complex, we'll handle case-by-case
    
    if ($modified) {
        Set-Content -Path $FilePath -Value $content -NoNewline
        Write-Host "    ✅ Converted entity" -ForegroundColor Green
        return $true
    } else {
        Write-Host "    ⚠️  No changes needed" -ForegroundColor Yellow
        return $false
    }
}

function Convert-Repository {
    param(
        [string]$FilePath
    )
    
    Write-Host "  Converting: $($FilePath | Split-Path -Leaf)" -ForegroundColor Cyan
    
    $content = Get-Content $FilePath -Raw
    $modified = $false
    
    # Replace JpaRepository with R2dbcRepository
    if ($content -match 'import org\.springframework\.data\.jpa\.repository\.JpaRepository;') {
        $content = $content -replace 'import org\.springframework\.data\.jpa\.repository\.JpaRepository;', 'import org.springframework.data.repository.reactive.ReactiveCrudRepository;'
        $modified = $true
    }
    
    if ($content -match 'extends JpaRepository<([^,]+),\s*([^>]+)>') {
        $entity = $matches[1]
        $id = $matches[2]
        $content = $content -replace "extends JpaRepository<$entity,\s*$id>", "extends ReactiveCrudRepository<$entity, $id>"
        $modified = $true
    }
    
    # Add Mono and Flux imports
    if ($modified -and $content -notmatch 'import reactor\.core\.publisher\.Mono;') {
        $content = $content -replace '(package [^;]+;)', "`$1`n`nimport reactor.core.publisher.Mono;`nimport reactor.core.publisher.Flux;"
    }
    
    # Replace Optional<T> with Mono<T>
    if ($content -match 'Optional<([^>]+)>') {
        $content = $content -replace 'Optional<([^>]+)>', 'Mono<$1>'
        $content = $content -replace 'import java\.util\.Optional;', ''
        $modified = $true
    }
    
    # Replace List<T> with Flux<T>
    if ($content -match 'List<([^>]+)>') {
        $content = $content -replace 'List<([^>]+)>', 'Flux<$1>'
        $content = $content -replace 'import java\.util\.List;', ''
        $modified = $true
    }
    
    if ($modified) {
        Set-Content -Path $FilePath -Value $content -NoNewline
        Write-Host "    ✅ Converted repository" -ForegroundColor Green
        return $true
    } else {
        Write-Host "    ⚠️  No changes needed" -ForegroundColor Yellow
        return $false
    }
}

# Main execution
Write-Host "`n🔄 JPA to R2DBC Migration Tool" -ForegroundColor Magenta
Write-Host "================================`n" -ForegroundColor Magenta

$services = @()
if ($Service -eq "both") {
    $services = @("benefits-core", "tenant-service")
} else {
    $services = @($Service)
}

$summary = @{}

foreach ($svc in $services) {
    Write-Host "`n📦 Processing service: $svc" -ForegroundColor Yellow
    
    $entityCount = 0
    $repoCount = 0
    
    # Determine paths
    if ($svc -eq "benefits-core") {
        $entityPath = "$rootPath\services\benefits-core\src\main\java\com\benefits\core\entity"
        $repoPath = "$rootPath\services\benefits-core\src\main\java\com\benefits\core\repository"
    } else {
        $entityPath = "$rootPath\services\tenant-service\src\main\java\com\benefits\tenantservice\entity"
        $repoPath = "$rootPath\services\tenant-service\src\main\java\com\benefits\tenantservice\repository"
    }
    
    # Convert entities
    Write-Host "`n  🏗️  Converting entities..." -ForegroundColor Cyan
    $entities = Get-ChildItem -Path $entityPath -Filter "*.java" -ErrorAction SilentlyContinue
    foreach ($entity in $entities) {
        if (Convert-JpaToR2dbc -FilePath $entity.FullName) {
            $entityCount++
        }
    }
    
    # Convert repositories
    Write-Host "`n  📚 Converting repositories..." -ForegroundColor Cyan
    $repos = Get-ChildItem -Path $repoPath -Filter "*.java" -ErrorAction SilentlyContinue
    foreach ($repo in $repos) {
        if (Convert-Repository -FilePath $repo.FullName) {
            $repoCount++
        }
    }
    
    $summary[$svc] = @{
        Entities = $entityCount
        Repositories = $repoCount
    }
    
    Write-Host "`n  ✅ Completed $svc" -ForegroundColor Green
    Write-Host "     Entities: $entityCount" -ForegroundColor White
    Write-Host "     Repositories: $repoCount" -ForegroundColor White
}

Write-Host "`n`n📊 Migration Summary" -ForegroundColor Magenta
Write-Host "===================`n" -ForegroundColor Magenta

foreach ($key in $summary.Keys) {
    Write-Host "  $key" -ForegroundColor Yellow
    Write-Host "    Entities converted: $($summary[$key].Entities)" -ForegroundColor Green
    Write-Host "    Repositories converted: $($summary[$key].Repositories)" -ForegroundColor Green
}

Write-Host "`n✅ Migration completed!`n" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the converted files" -ForegroundColor White
Write-Host "  2. Build the services: mvn clean package" -ForegroundColor White
Write-Host "  3. Test the reactive endpoints`n" -ForegroundColor White
