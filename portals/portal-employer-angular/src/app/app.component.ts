import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <mat-toolbar color="primary" class="header">
        <span>Employer Portal</span>
        <span class="spacer"></span>
        <button mat-button>Dashboard</button>
        <button mat-button>Employees</button>
        <button mat-button>Benefits</button>
        <button mat-button>Batch Upload</button>
      </mat-toolbar>

      <div class="content">
        <mat-card class="dashboard-card">
          <mat-card-header>
            <mat-card-title>Company Benefits Dashboard</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-number">3</div>
                <div class="stat-label">Active Employees</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">R\$ 5,000</div>
                <div class="stat-label">Monthly Budget</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">150</div>
                <div class="stat-label">Transactions</div>
              </div>
              <div class="stat-item">
                <div class="stat-number">95%</div>
                <div class="stat-label">Utilization Rate</div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <mat-card class="actions-card">
          <mat-card-header>
            <mat-card-title>Quick Actions</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="actions-grid">
              <button mat-raised-button color="primary">
                <mat-icon>upload</mat-icon>
                Upload Employee Batch
              </button>
              <button mat-raised-button color="accent">
                <mat-icon>credit_card</mat-icon>
                Process Payments
              </button>
              <button mat-raised-button>
                <mat-icon>analytics</mat-icon>
                View Reports
              </button>
              <button mat-raised-button>
                <mat-icon>support</mat-icon>
                Support Center
              </button>
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

    .dashboard-card, .actions-card {
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

    .actions-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-top: 20px;
    }

    button {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 20px 10px;
      height: auto;
    }

    mat-icon {
      margin-bottom: 8px;
    }
  `]
})
export class AppComponent {
  title = 'Employer Benefits Portal';
}