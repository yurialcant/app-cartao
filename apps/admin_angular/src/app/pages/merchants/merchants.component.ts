import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-merchants',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>🏪 Merchants</h1>
      <div class="loading" *ngIf="loading">Carregando merchants...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr><th>Nome</th><th>CNPJ</th><th>Categoria</th><th>Status</th><th>Ações</th></tr>
        </thead>
        <tbody>
          <tr *ngFor="let merchant of merchants">
            <td>{{ merchant.name }}</td>
            <td>{{ merchant.document }}</td>
            <td>{{ merchant.category }}</td>
            <td><span class="status-badge" [class]="'status-' + merchant.status.toLowerCase()">{{ merchant.status }}</span></td>
            <td><button class="btn-icon">👁️</button> <button class="btn-icon">✏️</button></td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-top: 20px; }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; font-weight: 600; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-active { background: #d4edda; color: #155724; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-blocked { background: #f8d7da; color: #721c24; }
    .btn-icon { background: none; border: none; cursor: pointer; font-size: 16px; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class MerchantsComponent implements OnInit {
  merchants: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadMerchants();
  }

  loadMerchants(): void {
    this.apiService.getMerchants().subscribe({
      next: (data) => { this.merchants = data || this.getMockMerchants(); this.loading = false; },
      error: () => { this.merchants = this.getMockMerchants(); this.loading = false; }
    });
  }

  getMockMerchants(): any[] {
    return [
      { name: 'Restaurante Sabor', document: '12.345.678/0001-90', category: 'FOOD', status: 'ACTIVE' },
      { name: 'Supermercado ABC', document: '98.765.432/0001-10', category: 'GROCERY', status: 'ACTIVE' },
      { name: 'Farmácia Saúde', document: '11.222.333/0001-44', category: 'HEALTH', status: 'PENDING' }
    ];
  }
}


