import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

interface Dispute {
  id: string;
  transactionId: string;
  userId: string;
  userName: string;
  amount: number;
  reason: string;
  status: string;
  createdAt: string;
  resolvedAt?: string;
}

@Component({
  selector: 'app-disputes',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <h1>⚖️ Gestão de Disputas</h1>
        <div class="stats">
          <span class="stat">🔴 {{ getPendingCount() }} Pendentes</span>
          <span class="stat">🟢 {{ getResolvedCount() }} Resolvidas</span>
        </div>
      </div>

      <div class="filters">
        <select [(ngModel)]="statusFilter" (change)="filterDisputes()">
          <option value="">Todos os status</option>
          <option value="OPEN">Abertas</option>
          <option value="UNDER_REVIEW">Em análise</option>
          <option value="RESOLVED">Resolvidas</option>
          <option value="REJECTED">Rejeitadas</option>
        </select>
      </div>

      <div class="loading" *ngIf="loading">Carregando disputas...</div>

      <div class="disputes-list" *ngIf="!loading">
        <div class="dispute-card" *ngFor="let dispute of filteredDisputes" [class]="'status-' + dispute.status.toLowerCase()">
          <div class="dispute-header">
            <span class="dispute-id">#{{ dispute.id.substring(0, 8) }}</span>
            <span class="status-badge" [class]="'badge-' + dispute.status.toLowerCase()">{{ dispute.status }}</span>
          </div>
          <div class="dispute-body">
            <p><strong>Usuário:</strong> {{ dispute.userName }}</p>
            <p><strong>Valor:</strong> {{ dispute.amount | currency:'BRL' }}</p>
            <p><strong>Motivo:</strong> {{ dispute.reason }}</p>
            <p><strong>Data:</strong> {{ dispute.createdAt | date:'dd/MM/yyyy HH:mm' }}</p>
          </div>
          <div class="dispute-actions" *ngIf="dispute.status === 'OPEN' || dispute.status === 'UNDER_REVIEW'">
            <button class="btn-success" (click)="resolveDispute(dispute, 'approve')">✅ Aprovar</button>
            <button class="btn-danger" (click)="resolveDispute(dispute, 'reject')">❌ Rejeitar</button>
            <button class="btn-secondary" (click)="reviewDispute(dispute)">🔍 Analisar</button>
          </div>
        </div>
      </div>

      <div class="empty-state" *ngIf="!loading && filteredDisputes.length === 0">
        <p>🎉 Nenhuma disputa encontrada</p>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .page-header h1 { margin: 0; }
    .stats { display: flex; gap: 20px; }
    .stat { padding: 8px 16px; background: #f5f5f5; border-radius: 20px; font-size: 14px; }
    .filters { margin-bottom: 20px; }
    .filters select { padding: 10px; border: 1px solid #ddd; border-radius: 4px; min-width: 200px; }
    .disputes-list { display: grid; gap: 16px; }
    .dispute-card { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #ddd; }
    .dispute-card.status-open { border-left-color: #dc3545; }
    .dispute-card.status-under_review { border-left-color: #ffc107; }
    .dispute-card.status-resolved { border-left-color: #28a745; }
    .dispute-card.status-rejected { border-left-color: #6c757d; }
    .dispute-header { display: flex; justify-content: space-between; margin-bottom: 12px; }
    .dispute-id { font-weight: 600; color: #666; }
    .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
    .badge-open { background: #f8d7da; color: #721c24; }
    .badge-under_review { background: #fff3cd; color: #856404; }
    .badge-resolved { background: #d4edda; color: #155724; }
    .badge-rejected { background: #e2e3e5; color: #383d41; }
    .dispute-body p { margin: 8px 0; color: #333; }
    .dispute-actions { display: flex; gap: 10px; margin-top: 16px; padding-top: 16px; border-top: 1px solid #eee; }
    .btn-success { background: #28a745; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
    .btn-danger { background: #dc3545; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
    .btn-secondary { background: #6c757d; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
    .loading, .empty-state { text-align: center; padding: 40px; color: #666; }
  `]
})
export class DisputesComponent implements OnInit {
  disputes: Dispute[] = [];
  filteredDisputes: Dispute[] = [];
  loading = true;
  statusFilter = '';

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadDisputes();
  }

  loadDisputes(): void {
    this.loading = true;
    this.apiService.getDisputes().subscribe({
      next: (data) => {
        this.disputes = data || this.getMockDisputes();
        this.filteredDisputes = [...this.disputes];
        this.loading = false;
      },
      error: () => {
        this.disputes = this.getMockDisputes();
        this.filteredDisputes = [...this.disputes];
        this.loading = false;
      }
    });
  }

  getMockDisputes(): Dispute[] {
    return [
      { id: 'a1b2c3d4-1234-5678-9abc-def012345678', transactionId: 'tx-001', userId: 'u1', userName: 'João Silva', amount: 150.00, reason: 'Cobrança duplicada', status: 'OPEN', createdAt: '2024-01-20T10:30:00' },
      { id: 'b2c3d4e5-2345-6789-abcd-ef0123456789', transactionId: 'tx-002', userId: 'u2', userName: 'Maria Santos', amount: 85.50, reason: 'Não reconheço a compra', status: 'UNDER_REVIEW', createdAt: '2024-01-19T14:15:00' },
      { id: 'c3d4e5f6-3456-789a-bcde-f01234567890', transactionId: 'tx-003', userId: 'u3', userName: 'Pedro Costa', amount: 320.00, reason: 'Valor incorreto', status: 'RESOLVED', createdAt: '2024-01-18T09:00:00', resolvedAt: '2024-01-19T11:00:00' },
      { id: 'd4e5f6g7-4567-89ab-cdef-012345678901', transactionId: 'tx-004', userId: 'u4', userName: 'Ana Oliveira', amount: 45.00, reason: 'Produto não entregue', status: 'REJECTED', createdAt: '2024-01-17T16:45:00', resolvedAt: '2024-01-18T10:30:00' },
    ];
  }

  filterDisputes(): void {
    this.filteredDisputes = this.disputes.filter(d => !this.statusFilter || d.status === this.statusFilter);
  }

  getPendingCount(): number {
    return this.disputes.filter(d => d.status === 'OPEN' || d.status === 'UNDER_REVIEW').length;
  }

  getResolvedCount(): number {
    return this.disputes.filter(d => d.status === 'RESOLVED' || d.status === 'REJECTED').length;
  }

  resolveDispute(dispute: Dispute, action: string): void {
    const newStatus = action === 'approve' ? 'RESOLVED' : 'REJECTED';
    if (confirm(`Confirma ${action === 'approve' ? 'aprovar' : 'rejeitar'} a disputa #${dispute.id.substring(0, 8)}?`)) {
      dispute.status = newStatus;
      dispute.resolvedAt = new Date().toISOString();
      alert(`Disputa ${newStatus === 'RESOLVED' ? 'aprovada' : 'rejeitada'} com sucesso!`);
    }
  }

  reviewDispute(dispute: Dispute): void {
    dispute.status = 'UNDER_REVIEW';
    alert(`Disputa #${dispute.id.substring(0, 8)} marcada para análise`);
  }
}


