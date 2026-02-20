import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="app-container">
      <mat-toolbar color="primary" class="header">
        <span>Merchant Portal</span>
        <span class="spacer"></span>
        <button mat-button>Dashboard</button>
        <button mat-button>Terminals</button>
        <button mat-button>Transactions</button>
        <button mat-button>Settlements</button>
      </mat-toolbar>

      <div class="content">
        <mat-card class="dashboard-card">
          <mat-card-header>
            <mat-card-title>Merchant Overview</mat-card-title>
          </mat-card-header>
          <mat-card-content>
            <div class="merchant-info">
              <div class="merchant-details">
                <h3>Restaurante Sabor</h3>
                <p>CNPJ: 12.345.678/0001-23</p>
                <p>Category: Restaurant</p>
              </div>
              <div class="merchant-stats">
                <div class="stat-item">
                  <div class="stat-number">3</div>
                  <div class="stat-label">Active Terminals</div>
                </div>
                <div class="stat-item">
                  <div class="stat-number">R\$ 15,000</div>
                  <div class="stat-label">Today's Volume</div>
                </div>
                <div class="stat-item">
                  <div class="stat-number">150</div>
                  <div class="stat-label">Transactions</div>
                </div>
                <div class="stat-item">
                  <div class="stat-number">98.5%</div>
                  <div class="stat-label">Success Rate</div>
                </div>
              </div>
            </div>
          </mat-card-content>
        </mat-card>

        <div class="cards-grid">
          <mat-card class="terminals-card">
            <mat-card-header>
              <mat-card-title>Terminal Status</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="terminal-list">
                <div class="terminal-item">
                  <span class="terminal-name">TERM001 - Matriz</span>
                  <span class="terminal-status healthy">● Online</span>
                </div>
                <div class="terminal-item">
                  <span class="terminal-name">TERM002 - Filial</span>
                  <span class="terminal-status healthy">● Online</span>
                </div>
                <div class="terminal-item">
                  <span class="terminal-name">TERM003 - Delivery</span>
                  <span class="terminal-status healthy">● Online</span>
                </div>
              </div>
            </mat-card-content>
          </mat-card>

          <mat-card class="recent-card">
            <mat-card-header>
              <mat-card-title>Recent Transactions</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <div class="transaction-list">
                <div class="transaction-item">
                  <div class="transaction-info">
                    <span class="amount">R\$ 45,00</span>
                    <span class="method">Credit Card</span>
                  </div>
                  <span class="time">2 min ago</span>
                </div>
                <div class="transaction-item">
                  <div class="transaction-info">
                    <span class="amount">R\$ 32,50</span>
                    <span class="method">Contactless</span>
                  </div>
                  <span class="time">5 min ago</span>
                </div>
                <div class="transaction-item">
                  <div class="transaction-info">
                    <span class="amount">R\$ 78,90</span>
                    <span class="method">Debit Card</span>
                  </div>
                  <span class="time">8 min ago</span>
                </div>
              </div>
            </mat-card-content>
          </mat-card>
        </div>
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

    .dashboard-card {
      margin-bottom: 20px;
    }

    .merchant-info {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 20px;
    }

    .merchant-details h3 {
      margin: 0 0 10px 0;
      color: #1976d2;
    }

    .merchant-details p {
      margin: 5px 0;
      color: #666;
    }

    .merchant-stats {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
    }

    .stat-item {
      text-align: center;
      padding: 15px;
      background: #f8f9fa;
      border-radius: 8px;
    }

    .stat-number {
      font-size: 1.8em;
      font-weight: bold;
      color: #1976d2;
      margin-bottom: 5px;
    }

    .stat-label {
      color: #666;
      font-size: 0.9em;
    }

    .cards-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
      gap: 20px;
    }

    .terminals-card, .recent-card {
      height: fit-content;
    }

    .terminal-list, .transaction-list {
      margin-top: 20px;
    }

    .terminal-item, .transaction-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px;
      margin-bottom: 8px;
      background: #f8f9fa;
      border-radius: 6px;
    }

    .terminal-name {
      font-weight: 500;
    }

    .terminal-status {
      font-size: 0.9em;
      font-weight: bold;
    }

    .healthy {
      color: #4caf50;
    }

    .transaction-info {
      display: flex;
      flex-direction: column;
    }

    .amount {
      font-weight: bold;
      font-size: 1.1em;
      color: #1976d2;
    }

    .method, .time {
      color: #666;
      font-size: 0.9em;
    }

    .time {
      font-size: 0.8em;
    }
  `]
})
export class AppComponent {
  title = 'Merchant Portal';
}