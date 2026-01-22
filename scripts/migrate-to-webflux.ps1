# Script para replicar padrão WebFlux + R2DBC para todos os BFFs

$bffs = @("employer-bff", "merchant-bff", "user-bff", "merchant-portal-bff")
$basePath = "c:\Users\gesch\Documents\projeto-lucas\services"
$adminPath = "$basePath\admin-bff"

# Copiar pom.xml limpo de admin para os outros BFFs
foreach ($bff in $bffs) {
    $bffPath = "$basePath\$bff"
    
    # Ler pom.xml do admin
    $pomContent = Get-Content "$adminPath\pom.xml" -Raw
    
    # Adaptar o nome do projeto
    $pomContent = $pomContent -replace 'com.benefits:admin-bff', "com.benefits:$bff"
    $pomContent = $pomContent -replace '<artifactId>admin-bff</artifactId>', "<artifactId>$bff</artifactId>"
    $pomContent = $pomContent -replace '<name>Admin BFF</name>', "<name>$(($bff -split '-' | ForEach-Object { $_[0].ToString().ToUpper() + $_.Substring(1) }) -join ' ') BFF</name>"
    
    # Escrever o pom.xml adaptado
    $pomContent | Out-File "$bffPath\pom.xml" -Encoding UTF8 -Force
    
    Write-Host "✅ ${bff}: pom.xml atualizado"
}

Write-Host "`n✅ Todos os pom.xml foram atualizados com WebFlux + R2DBC"
