import { Component } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';

@Component({
  standalone: true,
  imports: [MatToolbarModule, MatCardModule, MatFormFieldModule, MatInputModule, MatButtonModule, FormsModule],
  selector: 'app-root',
  template: `
    <!-- #region agent log -->
    <script>
      fetch('http://127.0.0.1:7242/ingest/68771221-a4f5-4ed1-9b1e-3d7a2a71e033', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          sessionId: 'debug-session',
          runId: 'system-verification',
          hypothesisId: 'H4',
          location: 'app.component.ts:5',
          message: 'Angular portal component initialized',
          data: {portal: 'admin', component: 'app-root'},
          timestamp: Date.now()
        })
      }).catch(() => {});
    </script>
    <!-- #endregion -->
    <div class="app-container">
      <mat-toolbar color="primary" class="header">
        <span>Operations Administration</span>
        <span class="spacer"></span>
        <button mat-button>Monitoring</button>
        <button mat-button>Logs</button>
        <button mat-button>Alerts</button>
        <button mat-button>Config</button>
      </mat-toolbar>

      <div class="content">
        <mat-card class="monitoring-card">
          <mat-card-header>
            <mat-card-title>System Monitoring</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="monitoring-grid">
              <div class="metric-item">
                <div class="metric-title">Active Services</div>
                <div class="metric-value">13/13</div>
                <div class="metric-status healthy">● All UP</div>
              </div>
              <div class="metric-item">
                <div class="metric-title">Database Status</div>
                <div class="metric-value">PostgreSQL</div>
                <div class="metric-status healthy">● Connected</div>
              </div>
              <div class="metric-item">
                <div class="metric-title">Cache Status</div>
                <div class="metric-value">Redis</div>
                <div class="metric-status healthy">● Connected</div>
              </div>
              <div class="metric-item">
                <div class="metric-title">Async Events</div>
                <div class="metric-value">70%</div>
                <div class="metric-status warning">● In Progress</div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
        <mat-card>
          <mat-card-header>
            <mat-card-title>Admin - Criar Usuário Flutter</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <form (ngSubmit)="createUser()" #userForm="ngForm">
              <div class="form-grid">
                <mat-form-field appearance="outline">
                  <mat-label>Tenant ID</mat-label>
                  <input matInput name="tenantId" [(ngModel)]="tenantId" required>
                </mat-form-field>
                <mat-form-field appearance="outline">
                  <mat-label>Nome</mat-label>
                  <input matInput name="name" [(ngModel)]="name" required>
                </mat-form-field>
                <mat-form-field appearance="outline">
                  <mat-label>Email</mat-label>
                  <input matInput name="email" [(ngModel)]="email" required>
                </mat-form-field>
                <mat-form-field appearance="outline">
                  <mat-label>CPF</mat-label>
                  <input matInput name="cpf" [(ngModel)]="cpf" required>
                </mat-form-field>
                <mat-form-field appearance="outline">
                  <mat-label>Senha</mat-label>
                  <input matInput type="password" name="password" [(ngModel)]="password" required>
                </mat-form-field>
              </div>
              <button mat-raised-button color="primary" type="submit">Criar Usuário</button>
              <span class="result" *ngIf="result">{{result}}</span>
            </form>
          </mat-card-content>
        </mat-card>
      </div>
    </div>
  `,
  styles: [`
    .app-container {
      min-height: 100vh;
      background-color: #f5f5f5;
    }

    .header {
      position: fixed;
      top: 0;
      width: 100%;
      z-index: 1000;
    }

    .spacer {
      flex: 1 1 auto;
    }

    .content {
      padding: 80px 20px 20px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .monitoring-card {
      margin-bottom: 20px;
    }

    .monitoring-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }

    .metric-item {
      padding: 20px;
      background: #f8f9fa;
      border-radius: 8px;
      text-align: center;
    }

    .metric-title {
      font-size: 1.1em;
      font-weight: 500;
      color: #666;
      margin-bottom: 10px;
    }

    .metric-value {
      font-size: 1.8em;
      font-weight: bold;
      color: #1976d2;
      margin-bottom: 5px;
    }

    .metric-status {
      font-size: 0.9em;
      font-weight: bold;
    }

    .healthy {
      color: #4caf50;
    }

    .warning {
      color: #ff9800;
    }
  `]
})
export class AppComponent {
  title = 'Operations Administration Portal';
  tenantId: string = 'TENANT001';
  name: string = '';
  email: string = '';
  cpf: string = '';
  password: string = '';
  result?: string;

  constructor(private http: HttpClient) {}

  createUser() {
    const payload = {
      tenantId: this.tenantId,
      name: this.name,
      email: this.email,
      cpf: this.cpf,
      password: this.password,
    };
    this.http.post('http://localhost:8080/api/v1/auth/register', payload)
      .subscribe({
        next: (resp: any) => this.result = `✅ Usuário criado: ${resp.userId || resp.user_id || 'ok'}`,
        error: (err: any) => this.result = `❌ Erro: ${err.message || err.status}`,
      });
  }
}