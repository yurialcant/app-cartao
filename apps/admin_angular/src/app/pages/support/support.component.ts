import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-support',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>🎫 Tickets de Suporte</h1>
      <div class="loading" *ngIf="loading">Carregando tickets...</div>
      <div class="tickets-list" *ngIf="!loading">
        <div class="ticket-card" *ngFor="let ticket of tickets" [class]="'priority-' + ticket.priority.toLowerCase()">
          <div class="ticket-header">
            <span class="ticket-id">#{{ ticket.id }}</span>
            <span class="priority-badge">{{ ticket.priority }}</span>
          </div>
          <h3>{{ ticket.subject }}</h3>
          <p>{{ ticket.description }}</p>
          <div class="ticket-meta">
            <span>👤 {{ ticket.userName }}</span>
            <span>📅 {{ ticket.createdAt | date:'dd/MM/yyyy' }}</span>
            <span class="status-badge" [class]="'status-' + ticket.status.toLowerCase()">{{ ticket.status }}</span>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .tickets-list { display: grid; gap: 16px; margin-top: 20px; }
    .ticket-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid #ddd; }
    .ticket-card.priority-high { border-left-color: #dc3545; }
    .ticket-card.priority-medium { border-left-color: #ffc107; }
    .ticket-card.priority-low { border-left-color: #28a745; }
    .ticket-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
    .ticket-id { color: #666; font-weight: 600; }
    .priority-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; background: #f5f5f5; }
    .ticket-card h3 { margin: 0 0 10px; }
    .ticket-card p { color: #666; margin: 0 0 15px; }
    .ticket-meta { display: flex; gap: 20px; font-size: 14px; color: #888; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-open { background: #fff3cd; color: #856404; }
    .status-in_progress { background: #cce5ff; color: #004085; }
    .status-closed { background: #d4edda; color: #155724; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class SupportComponent implements OnInit {
  tickets: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadTickets();
  }

  loadTickets(): void {
    this.apiService.getTickets().subscribe({
      next: (data) => { this.tickets = data || this.getMockTickets(); this.loading = false; },
      error: () => { this.tickets = this.getMockTickets(); this.loading = false; }
    });
  }

  getMockTickets(): any[] {
    return [
      { id: 'TK001', subject: 'Problema com pagamento', description: 'Não consigo finalizar pagamento', userName: 'João', priority: 'HIGH', status: 'OPEN', createdAt: new Date() },
      { id: 'TK002', subject: 'Dúvida sobre saldo', description: 'Como verificar meu saldo?', userName: 'Maria', priority: 'LOW', status: 'IN_PROGRESS', createdAt: new Date() },
      { id: 'TK003', subject: 'Cartão bloqueado', description: 'Preciso desbloquear', userName: 'Pedro', priority: 'MEDIUM', status: 'CLOSED', createdAt: new Date() }
    ];
  }
}


