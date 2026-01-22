import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-operators',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <h1>👤 Operadores</h1>
        <button class="btn-primary">+ Novo Operador</button>
      </div>
      <div class="loading" *ngIf="loading">Carregando operadores...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr><th>Nome</th><th>Email</th><th>Loja</th><th>Status</th><th>Ações</th></tr>
        </thead>
        <tbody>
          <tr *ngFor="let op of operators">
            <td>{{ op.name }}</td>
            <td>{{ op.email }}</td>
            <td>{{ op.storeName }}</td>
            <td><span class="status-badge" [class]="'status-' + op.status.toLowerCase()">{{ op.status }}</span></td>
            <td>
              <button class="btn-icon">✏️</button>
              <button class="btn-icon">🔒</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .btn-primary { background: #2e7d32; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; font-weight: 600; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-active { background: #d4edda; color: #155724; }
    .status-inactive { background: #f8d7da; color: #721c24; }
    .btn-icon { background: none; border: none; cursor: pointer; font-size: 16px; padding: 4px; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class OperatorsComponent implements OnInit {
  operators: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadOperators();
  }

  loadOperators(): void {
    this.apiService.getOperators().subscribe({
      next: (data) => { this.operators = data || this.getMockOperators(); this.loading = false; },
      error: () => { this.operators = this.getMockOperators(); this.loading = false; }
    });
  }

  getMockOperators(): any[] {
    return [
      { id: 1, name: 'Carlos Silva', email: 'carlos@loja.com', storeName: 'Loja Centro', status: 'ACTIVE' },
      { id: 2, name: 'Ana Costa', email: 'ana@loja.com', storeName: 'Loja Shopping', status: 'ACTIVE' },
      { id: 3, name: 'Pedro Santos', email: 'pedro@loja.com', storeName: 'Loja Bairro', status: 'INACTIVE' }
    ];
  }
}
