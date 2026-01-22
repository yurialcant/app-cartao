import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-audit',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>📋 Logs de Auditoria</h1>
      <div class="loading" *ngIf="loading">Carregando logs...</div>
      <table class="data-table" *ngIf="!loading">
        <thead>
          <tr>
            <th>Data/Hora</th>
            <th>Ação</th>
            <th>Usuário</th>
            <th>Recurso</th>
            <th>Detalhes</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let log of auditLogs">
            <td>{{ log.timestamp | date:'dd/MM/yyyy HH:mm:ss' }}</td>
            <td><span class="action-badge" [class]="'action-' + log.action.toLowerCase()">{{ log.action }}</span></td>
            <td>{{ log.userId }}</td>
            <td>{{ log.resource }}</td>
            <td>{{ log.details }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-top: 20px; }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; font-weight: 600; }
    .action-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .action-create { background: #d4edda; color: #155724; }
    .action-update { background: #fff3cd; color: #856404; }
    .action-delete { background: #f8d7da; color: #721c24; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class AuditComponent implements OnInit {
  auditLogs: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadLogs();
  }

  loadLogs(): void {
    this.apiService.getAuditLogs().subscribe({
      next: (data) => { this.auditLogs = data || this.getMockLogs(); this.loading = false; },
      error: () => { this.auditLogs = this.getMockLogs(); this.loading = false; }
    });
  }

  getMockLogs(): any[] {
    return [
      { timestamp: new Date(), action: 'CREATE', userId: 'admin', resource: 'User', details: 'Criou usuário user1' },
      { timestamp: new Date(), action: 'UPDATE', userId: 'admin', resource: 'Merchant', details: 'Atualizou merchant XYZ' },
      { timestamp: new Date(), action: 'DELETE', userId: 'system', resource: 'Session', details: 'Sessão expirada removida' }
    ];
  }
}


