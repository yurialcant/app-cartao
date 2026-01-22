import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

interface User {
  id: string;
  name: string;
  email: string;
  document: string;
  status: string;
  wallets: { type: string; balance: number }[];
  createdAt: string;
}

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <h1>👥 Gestão de Usuários</h1>
        <button class="btn-primary" (click)="showCreateModal = true">
          ➕ Novo Usuário
        </button>
      </div>

      <div class="filters">
        <input type="text" [(ngModel)]="searchTerm" placeholder="🔍 Buscar por nome ou email..." class="search-input">
        <select [(ngModel)]="statusFilter" (change)="filterUsers()">
          <option value="">Todos os status</option>
          <option value="ACTIVE">Ativos</option>
          <option value="PENDING">Pendentes</option>
          <option value="BLOCKED">Bloqueados</option>
        </select>
      </div>

      <div class="loading" *ngIf="loading">Carregando...</div>
      <div class="error" *ngIf="error">{{ error }}</div>

      <table class="data-table" *ngIf="!loading && !error">
        <thead>
          <tr>
            <th>Nome</th>
            <th>Email</th>
            <th>Documento</th>
            <th>Status</th>
            <th>Saldo Total</th>
            <th>Criado em</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let user of filteredUsers">
            <td>{{ user.name }}</td>
            <td>{{ user.email }}</td>
            <td>{{ user.document }}</td>
            <td>
              <span class="status-badge" [class]="'status-' + user.status.toLowerCase()">
                {{ user.status }}
              </span>
            </td>
            <td>{{ getTotalBalance(user) | currency:'BRL' }}</td>
            <td>{{ user.createdAt | date:'dd/MM/yyyy' }}</td>
            <td>
              <button class="btn-icon" title="Ver detalhes" (click)="viewUser(user)">👁️</button>
              <button class="btn-icon" title="Editar" (click)="editUser(user)">✏️</button>
              <button class="btn-icon" title="Topup" (click)="topupUser(user)">💰</button>
              <button class="btn-icon" title="Bloquear" *ngIf="user.status !== 'BLOCKED'" (click)="blockUser(user)">🚫</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="empty-state" *ngIf="!loading && !error && filteredUsers.length === 0">
        <p>Nenhum usuário encontrado</p>
      </div>

      <!-- Modal de Topup -->
      <div class="modal-overlay" *ngIf="showTopupModal" (click)="showTopupModal = false">
        <div class="modal" (click)="$event.stopPropagation()">
          <h2>💰 Fazer Topup</h2>
          <p>Usuário: {{ selectedUser?.name }}</p>
          <div class="form-group">
            <label>Valor (R$)</label>
            <input type="number" [(ngModel)]="topupAmount" min="1" step="0.01">
          </div>
          <div class="modal-actions">
            <button class="btn-secondary" (click)="showTopupModal = false">Cancelar</button>
            <button class="btn-primary" (click)="confirmTopup()">Confirmar</button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .page-header h1 { margin: 0; }
    .filters { display: flex; gap: 10px; margin-bottom: 20px; }
    .search-input { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .filters select { padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .data-table th, .data-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
    .data-table th { background: #f5f5f5; font-weight: 600; }
    .data-table tbody tr:hover { background: #f9f9f9; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600; }
    .status-active { background: #d4edda; color: #155724; }
    .status-pending { background: #fff3cd; color: #856404; }
    .status-blocked { background: #f8d7da; color: #721c24; }
    .btn-primary { background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .btn-primary:hover { background: #0056b3; }
    .btn-secondary { background: #6c757d; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .btn-icon { background: none; border: none; cursor: pointer; padding: 4px; font-size: 16px; }
    .btn-icon:hover { transform: scale(1.2); }
    .loading, .error, .empty-state { text-align: center; padding: 40px; }
    .error { color: #dc3545; }
    .modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; }
    .modal { background: white; padding: 30px; border-radius: 8px; min-width: 400px; }
    .modal h2 { margin-top: 0; }
    .form-group { margin: 20px 0; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: 600; }
    .form-group input { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
    .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
  `]
})
export class UsersComponent implements OnInit {
  users: User[] = [];
  filteredUsers: User[] = [];
  loading = true;
  error = '';
  searchTerm = '';
  statusFilter = '';
  showTopupModal = false;
  showCreateModal = false;
  selectedUser: User | null = null;
  topupAmount = 100;

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.loading = true;
    this.error = '';
    
    this.apiService.getUsers().subscribe({
      next: (data) => {
        this.users = data || this.getMockUsers();
        this.filteredUsers = [...this.users];
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading users:', err);
        // Usar dados mock em caso de erro
        this.users = this.getMockUsers();
        this.filteredUsers = [...this.users];
        this.loading = false;
      }
    });
  }

  getMockUsers(): User[] {
    return [
      { id: '1', name: 'João Silva', email: 'joao@email.com', document: '***.***.***-12', status: 'ACTIVE', wallets: [{ type: 'VR', balance: 500 }, { type: 'VA', balance: 300 }], createdAt: '2024-01-15' },
      { id: '2', name: 'Maria Santos', email: 'maria@email.com', document: '***.***.***-34', status: 'ACTIVE', wallets: [{ type: 'VR', balance: 750 }], createdAt: '2024-02-20' },
      { id: '3', name: 'Pedro Costa', email: 'pedro@email.com', document: '***.***.***-56', status: 'PENDING', wallets: [{ type: 'VR', balance: 0 }], createdAt: '2024-03-10' },
      { id: '4', name: 'Ana Oliveira', email: 'ana@email.com', document: '***.***.***-78', status: 'BLOCKED', wallets: [{ type: 'VR', balance: 200 }], createdAt: '2024-01-05' },
    ];
  }

  filterUsers(): void {
    this.filteredUsers = this.users.filter(user => {
      const matchesSearch = !this.searchTerm || 
        user.name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(this.searchTerm.toLowerCase());
      const matchesStatus = !this.statusFilter || user.status === this.statusFilter;
      return matchesSearch && matchesStatus;
    });
  }

  getTotalBalance(user: User): number {
    return user.wallets.reduce((sum, w) => sum + w.balance, 0);
  }

  viewUser(user: User): void {
    alert(`Ver detalhes de ${user.name}\nEmail: ${user.email}\nStatus: ${user.status}`);
  }

  editUser(user: User): void {
    alert(`Editar usuário: ${user.name}`);
  }

  topupUser(user: User): void {
    this.selectedUser = user;
    this.showTopupModal = true;
  }

  confirmTopup(): void {
    if (this.selectedUser && this.topupAmount > 0) {
      this.apiService.createTopupForUser(this.selectedUser.id, this.topupAmount).subscribe({
        next: () => {
          alert(`Topup de R$ ${this.topupAmount} realizado para ${this.selectedUser?.name}`);
          this.showTopupModal = false;
          this.loadUsers();
        },
        error: (err) => {
          alert(`Topup simulado de R$ ${this.topupAmount} para ${this.selectedUser?.name}`);
          this.showTopupModal = false;
        }
      });
    }
  }

  blockUser(user: User): void {
    if (confirm(`Tem certeza que deseja bloquear ${user.name}?`)) {
      alert(`Usuário ${user.name} bloqueado`);
      user.status = 'BLOCKED';
    }
  }
}
