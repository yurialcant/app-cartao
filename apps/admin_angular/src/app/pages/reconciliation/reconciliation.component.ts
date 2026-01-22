import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-reconciliation',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>🔄 Conciliação</h1>
      <div class="summary-cards">
        <div class="summary-card"><h3>Total Processado</h3><p>{{ totalProcessed | currency:'BRL' }}</p></div>
        <div class="summary-card"><h3>Conciliado</h3><p>{{ reconciled | currency:'BRL' }}</p></div>
        <div class="summary-card warning"><h3>Pendente</h3><p>{{ pending | currency:'BRL' }}</p></div>
        <div class="summary-card error"><h3>Divergente</h3><p>{{ divergent | currency:'BRL' }}</p></div>
      </div>
      <div class="loading" *ngIf="loading">Carregando dados...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr><th>Data</th><th>Lote</th><th>Transações</th><th>Valor</th><th>Status</th></tr>
        </thead>
        <tbody>
          <tr *ngFor="let item of reconItems">
            <td>{{ item.date | date:'dd/MM/yyyy' }}</td>
            <td>{{ item.batchId }}</td>
            <td>{{ item.transactionCount }}</td>
            <td>{{ item.amount | currency:'BRL' }}</td>
            <td><span class="status-badge" [class]="'status-' + item.status.toLowerCase()">{{ item.status }}</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .summary-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin: 20px 0; }
    .summary-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .summary-card h3 { margin: 0; font-size: 14px; color: #666; }
    .summary-card p { margin: 10px 0 0; font-size: 24px; font-weight: bold; color: #28a745; }
    .summary-card.warning p { color: #ffc107; }
    .summary-card.error p { color: #dc3545; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-matched { background: #d4edda; color: #155724; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-divergent { background: #f8d7da; color: #721c24; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class ReconciliationComponent implements OnInit {
  reconItems: any[] = [];
  loading = true;
  totalProcessed = 0;
  reconciled = 0;
  pending = 0;
  divergent = 0;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadReconData();
  }

  loadReconData(): void {
    this.totalProcessed = 1250000;
    this.reconciled = 1180000;
    this.pending = 50000;
    this.divergent = 20000;
    
    this.apiService.getReconciliation().subscribe({
      next: (data) => { this.reconItems = data || this.getMockData(); this.loading = false; },
      error: () => { this.reconItems = this.getMockData(); this.loading = false; }
    });
  }

  getMockData(): any[] {
    return [
      { date: new Date(), batchId: 'B001', transactionCount: 150, amount: 45000, status: 'MATCHED' },
      { date: new Date(), batchId: 'B002', transactionCount: 89, amount: 28500, status: 'PENDING' },
      { date: new Date(), batchId: 'B003', transactionCount: 12, amount: 3200, status: 'DIVERGENT' }
    ];
  }
}


