#!/usr/bin/env pwsh
# final-r2dbc-cleanup.ps1
# Final cleanup to make all entities R2DBC-compatible

$ErrorActionPreference = "Stop"

function Clean-R2dbcEntity {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw
    
    # 1. Remove indexes from @Table
    $content = $content -replace '@Table\(name\s*=\s*"([^"]+)",\s*indexes\s*=\s*\{[^}]+\}\)', '@Table("$1")'
    $content = $content -replace '@Table\("([^"]+)",\s*indexes\s*=\s*\{[^}]+\}\)', '@Table("$1")'
    
    # 2. Fix @Id with parameters - R2DBC @Id doesn't take parameters
    $content = $content -replace '@Id\s*\n\s*@Column\([^)]+\)', '@Id'
    
    # 3. Remove all @Column parameters except the column name
    # Match @Column("name", ...) or @Column(name="name", ...) or @Column(length=X)
    $content = $content -replace '@Column\("([^"]+)"[,\s][^)]+\)', '@Column("$1")'
    $content = $content -replace '@Column\(name\s*=\s*"([^"]+)"[,\s][^)]+\)', '@Column("$1")'
    $content = $content -replace '@Column\([^"]*length\s*=\s*\d+[^)]*\)', ''
    $content = $content -replace '@Column\([^"]*precision\s*=\s*\d+[^)]*\)', ''
    $content = $content -replace '@Column\([^"]*scale\s*=\s*\d+[^)]*\)', ''
    $content = $content -replace '@Column\([^"]*columnDefinition\s*=\s*"[^"]*"[^)]*\)', ''
    
    # 4. Remove empty @Column()
    $content = $content -replace '\s*@Column\(\s*\)\s*\n', "`n"
    
    # 5. Remove @Index import and usage (not supported)
    $content = $content -replace 'import jakarta\.persistence\.Index;', ''
    
    Set-Content -Path $FilePath -Value $content -NoNewline
}

Write-Host "`n🧹 Final R2DBC cleanup..." -ForegroundColor Magenta

# Clean benefits-core entities
$corePath = "c:\Users\gesch\Documents\projeto-lucas\services\benefits-core\src\main\java\com\benefits\core\entity"
Get-ChildItem -Path $corePath -Filter "*.java" | ForEach-Object {
    Clean-R2dbcEntity -FilePath $_.FullName
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}

# Clean tenant-service entities
$tenantPath = "c:\Users\gesch\Documents\projeto-lucas\services\tenant-service\src\main\java\com\benefits\tenantservice\entity"
Get-ChildItem -Path $tenantPath -Filter "*.java" | ForEach-Object {
    Clean-R2dbcEntity -FilePath $_.FullName
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}

Write-Host "`n✅ Cleanup complete!`n" -ForegroundColor Green
