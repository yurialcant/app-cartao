# Script para criar repositórios individuais no GitHub
# Execute este script APÓS obter seu Personal Access Token

$token = Read-Host "Cole seu Personal Access Token do GitHub"

# Configurar GitHub CLI com o token
$env:GITHUB_TOKEN = $token
$env:Path += ";C:\Program Files\GitHub CLI"

# Lista de repositórios a criar
$repos = @(
    # Services
    "benefits-core",
    "tenant-service",
    "identity-service",
    "payments-orchestrator",
    "merchant-service",
    "support-service",
    "audit-service",
    "notification-service",
    "recon-service",
    "reconciliation-service",
    "risk-service",
    "settlement-service",
    "privacy-service",
    "webhook-receiver",
    "webhook-service",
    "payments-service",
    "billing-service",
    "device-service",
    "employer-service",
    "kyb-service",
    "kyc-service",
    "ops-relay",
    "acquirer-adapter",

    # BFFs
    "admin-bff",
    "employer-bff",
    "merchant-bff",
    "platform-bff",
    "pos-bff",
    "support-bff",
    "tenant-bff",
    "user-bff",

    # Apps
    "admin-portal",
    "admin-angular",
    "app-pos-flutter",
    "app-user-flutter",
    "employer-portal",
    "employer-portal-angular",
    "merchant-portal",
    "merchant-portal-angular",
    "merchant-pos-flutter",
    "platform-portal",
    "user-app",
    "user-app-flutter"
)

foreach ($repo in $repos) {
    Write-Host "Criando repositório: $repo"

    # Criar repositório no GitHub
    gh repo create "ttiede/$repo" --private --description "Benefits Platform - $repo"

    # Navegar para a pasta do serviço
    $repoPath = "services/$repo"
    if (!(Test-Path $repoPath)) {
        $repoPath = "bffs/$repo"
    }
    if (!(Test-Path $repoPath)) {
        $repoPath = "apps/$repo"
    }

    if (Test-Path $repoPath) {
        Push-Location $repoPath

        # Inicializar git se necessário
        if (!(Test-Path ".git")) {
            git init
            git add .
            git commit -m "Initial commit for $repo"
        }

        # Configurar remote
        git remote remove origin 2>$null
        git remote add origin "git@github.com:ttiede/$repo.git"

        # Push
        git push -u origin main

        Pop-Location
    }

    Write-Host "✅ $repo criado e enviado!"
}

Write-Host "🎉 Todos os repositórios foram criados e enviados!"