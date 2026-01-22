import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>📊 Dashboard do Merchant</h1>
      <div class="stats-grid">
        <div class="stat-card">
          <h3>💰 Vendas Hoje</h3>
          <p class="stat-value">{{ salesToday | currency:'BRL' }}</p>
        </div>
        <div class="stat-card">
          <h3>💳 Transações</h3>
          <p class="stat-value">{{ transactionsCount }}</p>
        </div>
        <div class="stat-card">
          <h3>📈 Ticket Médio</h3>
          <p class="stat-value">{{ avgTicket | currency:'BRL' }}</p>
        </div>
        <div class="stat-card">
          <h3>💸 A Receber</h3>
          <p class="stat-value">{{ pendingTransfers | currency:'BRL' }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 20px; }
    .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .stat-card h3 { margin: 0 0 10px 0; color: #666; font-size: 14px; }
    .stat-value { margin: 0; font-size: 28px; font-weight: bold; color: #2e7d32; }
  `]
})
export class DashboardComponent implements OnInit {
  salesToday = 0;
  transactionsCount = 0;
  avgTicket = 0;
  pendingTransfers = 0;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadDashboardData();
  }

  loadDashboardData(): void {
    this.salesToday = 12500;
    this.transactionsCount = 87;
    this.avgTicket = 143.68;
    this.pendingTransfers = 8750;
  }
}
