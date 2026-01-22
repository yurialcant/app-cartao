# Script para criar Angular Merchant Portal completo

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🏪 CRIANDO ANGULAR MERCHANT PORTAL COMPLETO 🏪            ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$portalDir = Join-Path $baseDir "apps/merchant_portal_angular"

# Criar estrutura básica do Angular
$angularStructure = @{
    "src/app" = @("components", "services", "models", "guards", "interceptors", "pages")
    "src/app/pages" = @("dashboard", "reports", "transfers", "stores", "operators", "terminals")
    "src/app/components" = @("layout", "shared")
    "src/assets" = @()
    "src/environments" = @()
}

foreach ($path in $angularStructure.Keys) {
    $fullPath = Join-Path $portalDir $path
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
    foreach ($subPath in $angularStructure[$path]) {
        $subFullPath = Join-Path $fullPath $subPath
        if (-not (Test-Path $subFullPath)) {
            New-Item -ItemType Directory -Path $subFullPath -Force | Out-Null
        }
    }
}

# Criar package.json (similar ao admin)
$packageJson = @{
    name = "merchant-portal-angular"
    version = "1.0.0"
    scripts = @{
        ng = "ng"
        start = "ng serve --port 4201"
        build = "ng build"
        test = "ng test"
        lint = "ng lint"
    }
    dependencies = @{
        "@angular/animations" = "^17.0.0"
        "@angular/common" = "^17.0.0"
        "@angular/compiler" = "^17.0.0"
        "@angular/core" = "^17.0.0"
        "@angular/forms" = "^17.0.0"
        "@angular/platform-browser" = "^17.0.0"
        "@angular/platform-browser-dynamic" = "^17.0.0"
        "@angular/router" = "^17.0.0"
        "rxjs" = "~7.8.0"
        "tslib" = "^2.3.0"
        "zone.js" = "~0.14.0"
        "@angular/material" = "^17.0.0"
        "@angular/cdk" = "^17.0.0"
    }
    devDependencies = @{
        "@angular-devkit/build-angular" = "^17.0.0"
        "@angular/cli" = "^17.0.0"
        "@angular/compiler-cli" = "^17.0.0"
        "@types/jasmine" = "~5.1.0"
        "jasmine-core" = "~5.1.0"
        "karma" = "~6.4.0"
        "karma-chrome-launcher" = "~3.2.0"
        "karma-coverage" = "~2.2.0"
        "karma-jasmine" = "~5.1.0"
        "karma-jasmine-html-reporter" = "~2.1.0"
        "typescript" = "~5.2.0"
    }
}

$packageJsonPath = Join-Path $portalDir "package.json"
$packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath -Encoding UTF8
Write-Host "  ✓ package.json criado" -ForegroundColor Green

# Criar arquivos principais (similar ao admin, mas adaptado)
$mainTs = @"
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { routes } from './app/app.routes';

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient(),
    provideAnimations()
  ]
}).catch(err => console.error(err));
"@

$mainTsPath = Join-Path $portalDir "src/main.ts"
Set-Content -Path $mainTsPath -Value $mainTs -Encoding UTF8
Write-Host "  ✓ main.ts criado" -ForegroundColor Green

# Criar routes
$appRoutes = @"
import { Routes } from '@angular/router';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { ReportsComponent } from './pages/reports/reports.component';
import { TransfersComponent } from './pages/transfers/transfers.component';
import { StoresComponent } from './pages/stores/stores.component';
import { OperatorsComponent } from './pages/operators/operators.component';
import { TerminalsComponent } from './pages/terminals/terminals.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'reports', component: ReportsComponent },
  { path: 'transfers', component: TransfersComponent },
  { path: 'stores', component: StoresComponent },
  { path: 'operators', component: OperatorsComponent },
  { path: 'terminals', component: TerminalsComponent },
];
"@

$appRoutesPath = Join-Path $portalDir "src/app/app.routes.ts"
Set-Content -Path $appRoutesPath -Value $appRoutes -Encoding UTF8
Write-Host "  ✓ app.routes.ts criado" -ForegroundColor Green

# Criar service de API
$apiService = @"
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiUrl;
  
  constructor(private http: HttpClient) {}
  
  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': \`Bearer \${token}\`
    });
  }
  
  // Reports
  getReports(params: any): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/reports\`, { headers: this.getHeaders(), params });
  }
  
  // Transfers
  getTransfers(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/transfers\`, { headers: this.getHeaders() });
  }
  
  // Stores
  getStores(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/stores\`, { headers: this.getHeaders() });
  }
  
  // Operators
  getOperators(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/operators\`, { headers: this.getHeaders() });
  }
  
  // Terminals
  getTerminals(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/terminals\`, { headers: this.getHeaders() });
  }
}
"@

$apiServicePath = Join-Path $portalDir "src/app/services/api.service.ts"
Set-Content -Path $apiServicePath -Value $apiService -Encoding UTF8
Write-Host "  ✓ api.service.ts criado" -ForegroundColor Green

# Criar environment
$environment = @"
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8085',
  keycloakUrl: 'http://localhost:8081'
};
"@

$environmentPath = Join-Path $portalDir "src/environments/environment.ts"
Set-Content -Path $environmentPath -Value $environment -Encoding UTF8
Write-Host "  ✓ environment.ts criado" -ForegroundColor Green

# Criar componentes de páginas
$pages = @("dashboard", "reports", "transfers", "stores", "operators", "terminals")
foreach ($page in $pages) {
    $pageComponent = @"
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../services/api.service';

@Component({
  selector: 'app-$page',
  standalone: true,
  imports: [CommonModule],
  template: \`
    <div class="page-container">
      <h1>$($page.Substring(0,1).ToUpper() + $page.Substring(1))</h1>
      <p>Página de $page em desenvolvimento</p>
    </div>
  \`,
  styles: [\`
    .page-container {
      padding: 20px;
    }
  \`]
})
export class $($page.Substring(0,1).ToUpper() + $page.Substring(1))Component implements OnInit {
  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    // TODO: Implementar lógica
  }
}
"@
    $pagePath = Join-Path $portalDir "src/app/pages/$page/$page.component.ts"
    Set-Content -Path $pagePath -Value $pageComponent -Encoding UTF8
    Write-Host "  ✓ $page.component.ts criado" -ForegroundColor Green
}

# Criar AppComponent e Layout (similar ao admin)
$appComponentTs = @"
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  template: \`
    <div class="app-container">
      <app-layout>
        <router-outlet></router-outlet>
      </app-layout>
    </div>
  \`,
  styles: [\`
    .app-container {
      width: 100%;
      height: 100vh;
    }
  \`]
})
export class AppComponent {
  title = 'Merchant Portal - Benefits Platform';
}
"@

$appComponentPath = Join-Path $portalDir "src/app/app.component.ts"
Set-Content -Path $appComponentPath -Value $appComponentTs -Encoding UTF8
Write-Host "  ✓ app.component.ts criado" -ForegroundColor Green

$layoutComponent = @"
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: \`
    <div class="layout">
      <nav class="sidebar">
        <ul>
          <li><a routerLink="/dashboard">Dashboard</a></li>
          <li><a routerLink="/reports">Relatórios</a></li>
          <li><a routerLink="/transfers">Repasses</a></li>
          <li><a routerLink="/stores">Lojas</a></li>
          <li><a routerLink="/operators">Operadores</a></li>
          <li><a routerLink="/terminals">Terminais</a></li>
        </ul>
      </nav>
      <main class="content">
        <ng-content></ng-content>
      </main>
    </div>
  \`,
  styles: [\`
    .layout {
      display: flex;
      height: 100vh;
    }
    .sidebar {
      width: 200px;
      background: #f5f5f5;
      padding: 20px;
    }
    .sidebar ul {
      list-style: none;
      padding: 0;
    }
    .sidebar li {
      margin: 10px 0;
    }
    .sidebar a {
      text-decoration: none;
      color: #333;
    }
    .content {
      flex: 1;
      padding: 20px;
      overflow-y: auto;
    }
  \`]
})
export class LayoutComponent {}
"@

$layoutPath = Join-Path $portalDir "src/app/components/layout/layout.component.ts"
Set-Content -Path $layoutPath -Value $layoutComponent -Encoding UTF8
Write-Host "  ✓ layout.component.ts criado" -ForegroundColor Green

# Criar index.html
$indexHtml = @"
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>Merchant Portal - Benefits Platform</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>
<body>
  <app-root></app-root>
</body>
</html>
"@

$indexHtmlPath = Join-Path $portalDir "src/index.html"
Set-Content -Path $indexHtmlPath -Value $indexHtml -Encoding UTF8
Write-Host "  ✓ index.html criado" -ForegroundColor Green

Write-Host "`n✅ Angular Merchant Portal criado com estrutura completa!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. cd apps/merchant_portal_angular" -ForegroundColor White
Write-Host "  2. npm install" -ForegroundColor White
Write-Host "  3. npm start" -ForegroundColor White
Write-Host ""
