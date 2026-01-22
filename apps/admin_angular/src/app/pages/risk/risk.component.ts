import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-risk',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>🛡️ Análise de Risco</h1>
      <div class="risk-summary">
        <div class="risk-card high"><h3>Alto Risco</h3><p>{{ highRisk }}</p></div>
        <div class="risk-card medium"><h3>Médio Risco</h3><p>{{ mediumRisk }}</p></div>
        <div class="risk-card low"><h3>Baixo Risco</h3><p>{{ lowRisk }}</p></div>
      </div>
      <div class="loading" *ngIf="loading">Carregando...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr><th>Transação</th><th>Usuário</th><th>Valor</th><th>Score</th><th>Status</th></tr>
        </thead>
        <tbody>
          <tr *ngFor="let item of riskItems">
            <td>{{ item.transactionId }}</td>
            <td>{{ item.userId }}</td>
            <td>{{ item.amount | currency:'BRL' }}</td>
            <td><span class="score" [class]="getScoreClass(item.score)">{{ item.score }}</span></td>
            <td>{{ item.status }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .risk-summary { display: flex; gap: 20px; margin: 20px 0; }
    .risk-card { flex: 1; padding: 20px; border-radius: 8px; text-align: center; color: white; }
    .risk-card.high { background: #dc3545; }
    .risk-card.medium { background: #ffc107; color: #333; }
    .risk-card.low { background: #28a745; }
    .risk-card h3 { margin: 0; font-size: 14px; }
    .risk-card p { margin: 10px 0 0; font-size: 32px; font-weight: bold; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; }
    .score { padding: 4px 8px; border-radius: 4px; font-weight: bold; }
    .score.high { background: #f8d7da; color: #721c24; }
    .score.medium { background: #fff3cd; color: #856404; }
    .score.low { background: #d4edda; color: #155724; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class RiskComponent implements OnInit {
  riskItems: any[] = [];
  loading = true;
  highRisk = 5;
  mediumRisk = 12;
  lowRisk = 245;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadRiskData();
  }

  loadRiskData(): void {
    this.apiService.getRiskAnalysis().subscribe({
      next: (data) => { this.riskItems = data || this.getMockData(); this.loading = false; },
      error: () => { this.riskItems = this.getMockData(); this.loading = false; }
    });
  }

  getMockData(): any[] {
    return [
      { transactionId: 'TX001', userId: 'user1', amount: 1500, score: 85, status: 'BLOCKED' },
      { transactionId: 'TX002', userId: 'user2', amount: 350, score: 45, status: 'REVIEW' },
      { transactionId: 'TX003', userId: 'user3', amount: 50, score: 15, status: 'APPROVED' }
    ];
  }

  getScoreClass(score: number): string {
    if (score >= 70) return 'high';
    if (score >= 40) return 'medium';
    return 'low';
  }
}


