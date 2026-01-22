# Script para adicionar loggers manualmente no employer-service

$ErrorActionPreference = "Stop"
$script:RootPath = Split-Path -Parent $PSScriptRoot

Write-Host "`n🔧 Adicionando loggers no employer-service..." -ForegroundColor Cyan

$files = @(
    @{Path="services/employer-service/src/main/java/com/benefits/employerservice/controller/EmployerController.java"; Class="EmployerController"},
    @{Path="services/employer-service/src/main/java/com/benefits/employerservice/service/EmployerService.java"; Class="EmployerService"},
    @{Path="services/employer-service/src/main/java/com/benefits/employerservice/controller/EmployeeController.java"; Class="EmployeeController"},
    @{Path="services/employer-service/src/main/java/com/benefits/employerservice/service/EmployeeService.java"; Class="EmployeeService"}
)

foreach ($file in $files) {
    $fullPath = Join-Path $script:RootPath $file.Path
    
    if (Test-Path $fullPath) {
        Write-Host "  Corrigindo: $($file.Path)" -ForegroundColor Yellow
        
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        
        # Remover @Slf4j se existir
        $content = $content -replace 'import lombok\.extern\.slf4j\.Slf4j;', ''
        $content = $content -replace '@Slf4j\s*', ''
        
        # Adicionar imports se não existirem
        if ($content -notmatch 'import org\.slf4j\.Logger;') {
            $content = $content -replace '(import lombok\.RequiredArgsConstructor;)', "`$1`nimport org.slf4j.Logger;`nimport org.slf4j.LoggerFactory;"
        }
        
        # Adicionar logger após a declaração da classe (antes dos campos)
        if ($content -notmatch 'private static final Logger log') {
            # Encontrar o padrão @RequiredArgsConstructor seguido de public class
            if ($content -match '(@RequiredArgsConstructor\s+)?(public class ' + [regex]::Escape($file.Class) + '[^{]*\{)') {
                $content = $content -replace '(@RequiredArgsConstructor\s+)?(public class ' + [regex]::Escape($file.Class) + '[^{]*\{)', "`$1`$2`n    `n    private static final Logger log = LoggerFactory.getLogger($($file.Class).class);"
            }
        }
        
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "    ✅ Corrigido" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Arquivo não encontrado: $($file.Path)" -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Loggers adicionados no employer-service!" -ForegroundColor Green
