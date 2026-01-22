# Script para atualizar rotas do Flutter User App

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🗺️  ATUALIZANDO ROTAS DO FLUTTER USER APP 🗺️             ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$mainDartPath = Join-Path $baseDir "apps/user_app_flutter/lib/main.dart"

if (-not (Test-Path $mainDartPath)) {
    Write-Host "  ✗ main.dart não encontrado" -ForegroundColor Red
    exit 1
}

$content = Get-Content $mainDartPath -Raw

# Adicionar imports das novas telas
$newImports = @"

import 'screens/qr_payment_screen.dart';
import 'screens/card_payment_screen.dart';
import 'screens/security_screen.dart';
import 'screens/support_screen.dart';
import 'screens/privacy_screen.dart';
"@

# Adicionar rotas
$newRoutes = @"

        '/qr-payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QrPaymentScreen(qrCode: args['qrCode'] as String);
        },
        '/card-payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CardPaymentScreen(amount: args['amount'] as double);
        },
        '/security': (context) => const SecurityScreen(),
        '/support': (context) => const SupportScreen(),
        '/privacy': (context) => const PrivacyScreen(),
"@

# Adicionar imports se não existirem
if ($content -notmatch "qr_payment_screen") {
    $content = $content -replace "(import 'screens/.*\.dart';)", "`$1$newImports"
    Write-Host "  ✓ Imports adicionados" -ForegroundColor Green
}

# Adicionar rotas se não existirem
if ($content -notmatch "'/qr-payment'") {
    # Encontrar onde adicionar (antes do último })
    $routesPattern = "routes: <String, WidgetBuilder>"
    if ($content -match $routesPattern) {
        $routesEnd = $content.IndexOf("};", $content.IndexOf($routesPattern))
        if ($routesEnd -gt 0) {
            $content = $content.Insert($routesEnd, $newRoutes)
            Write-Host "  ✓ Rotas adicionadas" -ForegroundColor Green
        }
    }
}

Set-Content -Path $mainDartPath -Value $content -Encoding UTF8

Write-Host "`n✅ Rotas do Flutter atualizadas!" -ForegroundColor Green
Write-Host ""
