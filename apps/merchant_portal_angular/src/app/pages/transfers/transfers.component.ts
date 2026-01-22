import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-transfers',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>💰 Repasses</h1>
      <div class="summary">
        <div class="summary-item"><span>Disponível:</span> <strong>{{ available | currency:'BRL' }}</strong></div>
        <div class="summary-item"><span>Pendente:</span> <strong>{{ pending | currency:'BRL' }}</strong></div>
      </div>
      <div class="loading" *ngIf="loading">Carregando repasses...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr><th>Data</th><th>Valor</th><th>Status</th><th>Conta</th></tr>
        </thead>
        <tbody>
          <tr *ngFor="let transfer of transfers">
            <td>{{ transfer.date | date:'dd/MM/yyyy' }}</td>
            <td>{{ transfer.amount | currency:'BRL' }}</td>
            <td><span class="status-badge" [class]="'status-' + transfer.status.toLowerCase()">{{ transfer.status }}</span></td>
            <td>{{ transfer.bankAccount }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .summary { display: flex; gap: 40px; margin: 20px 0; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .summary-item span { color: #666; }
    .summary-item strong { font-size: 24px; color: #2e7d32; margin-left: 10px; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; font-weight: 600; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-completed { background: #d4edda; color: #155724; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-processing { background: #cce5ff; color: #004085; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class TransfersComponent implements OnInit {
  transfers: any[] = [];
  loading = true;
  available = 8750;
  pending = 3200;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadTransfers();
  }

  loadTransfers(): void {
    this.apiService.getTransfers().subscribe({
      next: (data) => { this.transfers = data || this.getMockTransfers(); this.loading = false; },
      error: () => { this.transfers = this.getMockTransfers(); this.loading = false; }
    });
  }

  getMockTransfers(): any[] {
    return [
      { date: new Date(), amount: 5000, status: 'COMPLETED', bankAccount: 'Banco do Brasil - **** 1234' },
      { date: new Date(), amount: 3750, status: 'PROCESSING', bankAccount: 'Banco do Brasil - **** 1234' },
      { date: new Date(), amount: 2800, status: 'PENDING', bankAccount: 'Banco do Brasil - **** 1234' }
    ];
  }
}
