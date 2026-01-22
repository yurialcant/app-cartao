import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>📊 Dashboard</h1>
      <div class="stats-grid">
        <div class="stat-card">
          <h3>👥 Usuários</h3>
          <p class="stat-value">{{ userCount }}</p>
        </div>
        <div class="stat-card">
          <h3>🏪 Merchants</h3>
          <p class="stat-value">{{ merchantCount }}</p>
        </div>
        <div class="stat-card">
          <h3>💰 Transações Hoje</h3>
          <p class="stat-value">{{ transactionsToday }}</p>
        </div>
        <div class="stat-card">
          <h3>⚠️ Disputas Pendentes</h3>
          <p class="stat-value">{{ pendingDisputes }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 20px; }
    .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .stat-card h3 { margin: 0 0 10px 0; color: #666; font-size: 14px; }
    .stat-value { margin: 0; font-size: 32px; font-weight: bold; color: #333; }
  `]
})
export class DashboardComponent implements OnInit {
  userCount = 0;
  merchantCount = 0;
  transactionsToday = 0;
  pendingDisputes = 0;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadStats();
  }

  loadStats(): void {
    // Mock data for now
    this.userCount = 1250;
    this.merchantCount = 85;
    this.transactionsToday = 3420;
    this.pendingDisputes = 12;
  }
}


