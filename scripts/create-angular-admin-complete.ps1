# Script para criar Angular Admin completo

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║     🎨 CRIANDO ANGULAR ADMIN COMPLETO 🎨                      ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$baseDir = Split-Path -Parent $PSScriptRoot
$adminDir = Join-Path $baseDir "apps/admin_angular"

# Criar estrutura básica do Angular
$angularStructure = @{
    "src/app" = @("components", "services", "models", "guards", "interceptors", "pages")
    "src/app/pages" = @("dashboard", "users", "merchants", "topups", "reconciliation", "disputes", "risk", "support", "audit")
    "src/app/components" = @("layout", "shared")
    "src/assets" = @()
    "src/environments" = @()
}

foreach ($path in $angularStructure.Keys) {
    $fullPath = Join-Path $adminDir $path
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

# Criar package.json completo
$packageJson = @{
    name = "admin-angular"
    version = "1.0.0"
    scripts = @{
        ng = "ng"
        start = "ng serve --port 4200"
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

$packageJsonPath = Join-Path $adminDir "package.json"
$packageJson | ConvertTo-Json -Depth 10 | Set-Content -Path $packageJsonPath -Encoding UTF8
Write-Host "  ✓ package.json criado" -ForegroundColor Green

# Criar angular.json básico
$angularJson = @"
{
  "`$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "version": 1,
  "newProjectRoot": "projects",
  "projects": {
    "admin-angular": {
      "projectType": "application",
      "schematics": {},
      "root": "",
      "sourceRoot": "src",
      "prefix": "app",
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/admin-angular",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": ["zone.js"],
            "tsConfig": "tsconfig.app.json",
            "assets": ["src/favicon.ico", "src/assets"],
            "styles": ["src/styles.css"],
            "scripts": []
          }
        },
        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "options": {
            "port": 4200
          }
        }
      }
    }
  }
}
"@

$angularJsonPath = Join-Path $adminDir "angular.json"
Set-Content -Path $angularJsonPath -Value $angularJson -Encoding UTF8
Write-Host "  ✓ angular.json criado" -ForegroundColor Green

# Criar tsconfig.json
$tsconfig = @"
{
  "compileOnSave": false,
  "compilerOptions": {
    "outDir": "./dist/out-tsc",
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "declaration": false,
    "experimentalDecorators": true,
    "moduleResolution": "node",
    "importHelpers": true,
    "target": "ES2022",
    "module": "ES2022",
    "lib": ["ES2022", "dom"]
  },
  "angularCompilerOptions": {
    "enableI18nLegacyMessageIdFormat": false,
    "strictInjectionParameters": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }
}
"@

$tsconfigPath = Join-Path $adminDir "tsconfig.json"
Set-Content -Path $tsconfigPath -Value $tsconfig -Encoding UTF8
Write-Host "  ✓ tsconfig.json criado" -ForegroundColor Green

# Criar arquivos principais
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

$mainTsPath = Join-Path $adminDir "src/main.ts"
if (-not (Test-Path (Split-Path $mainTsPath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $mainTsPath -Parent) -Force | Out-Null
}
Set-Content -Path $mainTsPath -Value $mainTs -Encoding UTF8
Write-Host "  ✓ main.ts criado" -ForegroundColor Green

# Criar index.html
$indexHtml = @"
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>Admin - Benefits Platform</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>
<body>
  <app-root></app-root>
</body>
</html>
"@

$indexHtmlPath = Join-Path $adminDir "src/index.html"
Set-Content -Path $indexHtmlPath -Value $indexHtml -Encoding UTF8
Write-Host "  ✓ index.html criado" -ForegroundColor Green

# Criar AppComponent
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
  title = 'Admin - Benefits Platform';
}
"@

$appComponentPath = Join-Path $adminDir "src/app/app.component.ts"
Set-Content -Path $appComponentPath -Value $appComponentTs -Encoding UTF8
Write-Host "  ✓ app.component.ts criado" -ForegroundColor Green

# Criar routes
$appRoutes = @"
import { Routes } from '@angular/router';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { UsersComponent } from './pages/users/users.component';
import { MerchantsComponent } from './pages/merchants/merchants.component';
import { TopupsComponent } from './pages/topups/topups.component';
import { ReconciliationComponent } from './pages/reconciliation/reconciliation.component';
import { DisputesComponent } from './pages/disputes/disputes.component';
import { RiskComponent } from './pages/risk/risk.component';
import { SupportComponent } from './pages/support/support.component';
import { AuditComponent } from './pages/audit/audit.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'users', component: UsersComponent },
  { path: 'merchants', component: MerchantsComponent },
  { path: 'topups', component: TopupsComponent },
  { path: 'reconciliation', component: ReconciliationComponent },
  { path: 'disputes', component: DisputesComponent },
  { path: 'risk', component: RiskComponent },
  { path: 'support', component: SupportComponent },
  { path: 'audit', component: AuditComponent },
];
"@

$appRoutesPath = Join-Path $adminDir "src/app/app.routes.ts"
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
  
  // Users
  getUsers(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/users\`, { headers: this.getHeaders() });
  }
  
  createUser(user: any): Observable<any> {
    return this.http.post(\`\${this.baseUrl}/admin/users\`, user, { headers: this.getHeaders() });
  }
  
  onboardUser(userId: string): Observable<any> {
    return this.http.post(\`\${this.baseUrl}/admin/users/\${userId}/onboard\`, {}, { headers: this.getHeaders() });
  }
  
  // Topups
  createTopupBatch(batch: any): Observable<any> {
    return this.http.post(\`\${this.baseUrl}/admin/topups/batch\`, batch, { headers: this.getHeaders() });
  }
  
  // Merchants
  getMerchants(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/merchants\`, { headers: this.getHeaders() });
  }
  
  // Reconciliation
  getReconciliation(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/reconciliation\`, { headers: this.getHeaders() });
  }
  
  // Disputes
  getDisputes(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/disputes\`, { headers: this.getHeaders() });
  }
  
  // Risk
  getRiskAnalysis(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/risk\`, { headers: this.getHeaders() });
  }
  
  // Support
  getTickets(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/support/tickets\`, { headers: this.getHeaders() });
  }
  
  // Audit
  getAuditLogs(): Observable<any> {
    return this.http.get(\`\${this.baseUrl}/admin/audit\`, { headers: this.getHeaders() });
  }
}
"@

$apiServicePath = Join-Path $adminDir "src/app/services/api.service.ts"
Set-Content -Path $apiServicePath -Value $apiService -Encoding UTF8
Write-Host "  ✓ api.service.ts criado" -ForegroundColor Green

# Criar environment
$environment = @"
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8083',
  keycloakUrl: 'http://localhost:8081'
};
"@

$environmentPath = Join-Path $adminDir "src/environments/environment.ts"
Set-Content -Path $environmentPath -Value $environment -Encoding UTF8
Write-Host "  ✓ environment.ts criado" -ForegroundColor Green

# Criar componentes de páginas básicos
$pages = @("dashboard", "users", "merchants", "topups", "reconciliation", "disputes", "risk", "support", "audit")
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
    $pagePath = Join-Path $adminDir "src/app/pages/$page/$page.component.ts"
    Set-Content -Path $pagePath -Value $pageComponent -Encoding UTF8
    Write-Host "  ✓ $page.component.ts criado" -ForegroundColor Green
}

# Criar layout component básico
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
          <li><a routerLink="/users">Usuários</a></li>
          <li><a routerLink="/merchants">Merchants</a></li>
          <li><a routerLink="/topups">Top-ups</a></li>
          <li><a routerLink="/reconciliation">Conciliação</a></li>
          <li><a routerLink="/disputes">Disputas</a></li>
          <li><a routerLink="/risk">Risco</a></li>
          <li><a routerLink="/support">Suporte</a></li>
          <li><a routerLink="/audit">Auditoria</a></li>
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

$layoutPath = Join-Path $adminDir "src/app/components/layout/layout.component.ts"
Set-Content -Path $layoutPath -Value $layoutComponent -Encoding UTF8
Write-Host "  ✓ layout.component.ts criado" -ForegroundColor Green

Write-Host "`n✅ Angular Admin criado com estrutura completa!" -ForegroundColor Green
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "  1. cd apps/admin_angular" -ForegroundColor White
Write-Host "  2. npm install" -ForegroundColor White
Write-Host "  3. npm start" -ForegroundColor White
Write-Host ""
