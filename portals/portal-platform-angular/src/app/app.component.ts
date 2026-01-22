import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <mat-toolbar color="primary" class="header">
        <span>Platform Administration</span>
        <span class="spacer"></span>
        <button mat-button>Dashboard</button>
        <button mat-button>Tenants</button>
        <button mat-button>Services</button>
        <button mat-button>Audit</button>
      </mat-toolbar>

      <div class="content">
        <mat-card class="dashboard-card">
          <mat-card-header>
            <mat-card-title>Platform Overview</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-number">13</div>
                <div class="stat-label">Services</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">1</div>
                <div class="stat-label">Tenants</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">3</div>
                <div class="stat-label">Users</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">1,500</div>
                <div class="stat-label">Transactions</div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="services-card">
          <mat-card-header>
            <mat-card-title>Service Health</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="service-list">
              <div class="service-item">
                <span class="service-name">benefits-core</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">identity-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">payments-orchestrator</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">merchant-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">support-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">audit-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">notification-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">recon-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">settlement-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">privacy-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">billing-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">tenant-service</span>
                <span class="service-status healthy">● UP</span>
              </div>
              <div class="service-item">
                <span class="service-name">ops-relay</span>
                <span class="service-status warning">● PARTIAL</span>
              </div>
            </div>
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

    .dashboard-card, .services-card {
      margin-bottom: 20px;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }

    .stat-item {
      text-align: center;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 8px;
    }

    .stat-number {
      font-size: 2.5em;
      font-weight: bold;
      color: #1976d2;
      margin-bottom: 5px;
    }

    .stat-label {
      color: #666;
      font-size: 1.1em;
    }

    .service-list {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 10px;
    }

    .service-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 12px;
      background: #f8f9fa;
      border-radius: 4px;
    }

    .service-name {
      font-weight: 500;
    }

    .service-status {
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
  title = 'Platform Administration Portal';
}