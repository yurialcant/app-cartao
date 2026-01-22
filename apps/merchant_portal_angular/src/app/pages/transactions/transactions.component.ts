import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-transactions',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="transactions-page">
      <h1>Histórico de Transações</h1>
      
      <div class="filters">
        <input type="date" [(ngModel)]="filterDate" (ngModelChange)="filterTransactions()" placeholder="Data">
        <select [(ngModel)]="statusFilter" (ngModelChange)="filterTransactions()">
          <option value="">Todos os Status</option>
          <option value="APPROVED">Aprovado</option>
          <option value="PENDING">Pendente</option>
          <option value="DECLINED">Recusado</option>
        </select>
        <select [(ngModel)]="typeFilter" (ngModelChange)="filterTransactions()">
          <option value="">Todos os Tipos</option>
          <option value="PAYMENT">Pagamento</option>
          <option value="REFUND">Reembolso</option>
          <option value="TOPUP">Recarga</option>
        </select>
        <input type="text" placeholder="Buscar por user/merchant..." [(ngModel)]="searchText" (ngModelChange)="filterTransactions()">
      </div>

      <div *ngIf="loading" class="loading">Carregando transações...</div>
      
      <div *ngIf="!loading && transactions.length === 0" class="no-data">
        Nenhuma transação encontrada
      </div>

      <table *ngIf="!loading && transactions.length > 0" class="transactions-table">
        <thead>
          <tr>
            <th>Data/Hora</th>
            <th>ID Transação</th>
            <th>Usuário</th>
            <th>Comerciante</th>
            <th>Valor</th>
            <th>Tipo</th>
            <th>Status</th>
            <th>Método</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let txn of filteredTransactions">
            <td>{{ txn.created_at | date:'dd/MM/yyyy HH:mm' }}</td>
            <td class="tx-id">{{ txn.id | slice:0:8 }}...</td>
            <td>{{ txn.user_name }}</td>
            <td>{{ txn.merchant_name }}</td>
            <td class="amount">{{ txn.amount | currency:'BRL' }}</td>
            <td>{{ txn.type }}</td>
            <td><span [class]="'status-' + txn.status.toLowerCase()">{{ txn.status }}</span></td>
            <td>{{ txn.method }}</td>
            <td class="actions-col">
              <button (click)="viewDetails(txn)" class="btn-view">Ver Detalhes</button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Details Modal -->
      <div *ngIf="showDetailsModal" class="modal-overlay" (click)="closeDetailsModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <h2>Detalhes da Transação</h2>
          
          <div *ngIf="selectedTransaction" class="transaction-details">
            <div class="detail-row">
              <span class="detail-label">ID Transação:</span>
              <span class="detail-value">{{ selectedTransaction.id }}</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Data/Hora:</span>
              <span class="detail-value">{{ selectedTransaction.created_at | date:'dd/MM/yyyy HH:mm:ss' }}</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Usuário:</span>
              <span class="detail-value">{{ selectedTransaction.user_name }} ({{ selectedTransaction.user_id }})</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Comerciante:</span>
              <span class="detail-value">{{ selectedTransaction.merchant_name }} ({{ selectedTransaction.merchant_id }})</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Valor:</span>
              <span class="detail-value amount">{{ selectedTransaction.amount | currency:'BRL' }}</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Tipo:</span>
              <span class="detail-value">{{ selectedTransaction.type }}</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Status:</span>
              <span class="detail-value" [class]="'status-' + selectedTransaction.status.toLowerCase()">
                {{ selectedTransaction.status }}
              </span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Método de Pagamento:</span>
              <span class="detail-value">{{ selectedTransaction.method }}</span>
            </div>
            
            <div class="detail-row" *ngIf="selectedTransaction.card_last_four">
              <span class="detail-label">Cartão (últimos 4 dígitos):</span>
              <span class="detail-value">**** **** **** {{ selectedTransaction.card_last_four }}</span>
            </div>
            
            <div class="detail-row">
              <span class="detail-label">Descrição:</span>
              <span class="detail-value">{{ selectedTransaction.description }}</span>
            </div>
          </div>
          
          <div class="modal-actions">
            <button (click)="downloadReceipt()" class="btn-primary">Baixar Recibo</button>
            <button (click)="closeDetailsModal()" class="btn-secondary">Fechar</button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .transactions-page {
      padding: 2rem;
      background: #f5f5f5;
      min-height: 100vh;
    }

    h1 {
      color: #333;
      margin-bottom: 2rem;
    }

    .filters {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
      flex-wrap: wrap;
    }

    .filters input, .filters select {
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      flex: 1;
      min-width: 150px;
      font-size: 1rem;
    }

    .loading, .no-data {
      text-align: center;
      padding: 2rem;
      color: #666;
      font-size: 1.1rem;
    }

    .transactions-table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      border-radius: 4px;
      overflow: hidden;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .transactions-table th {
      background: #667eea;
      color: white;
      padding: 1rem;
      text-align: left;
      font-weight: 600;
    }

    .transactions-table td {
      padding: 1rem;
      border-bottom: 1px solid #eee;
      font-size: 0.95rem;
    }

    .transactions-table tr:hover {
      background: #f9f9f9;
    }

    .tx-id {
      font-family: monospace;
      color: #666;
    }

    .amount {
      font-weight: 600;
      color: #2e7d32;
    }

    .status-approved {
      color: #4CAF50;
      font-weight: 600;
    }

    .status-pending {
      color: #ff9800;
      font-weight: 600;
    }

    .status-declined {
      color: #f44336;
      font-weight: 600;
    }

    .actions-col {
      display: flex;
      gap: 0.5rem;
    }

    .btn-view {
      background: #667eea;
      color: white;
      padding: 0.5rem 1rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 0.9rem;
    }

    .btn-view:hover {
      background: #5568d3;
    }

    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }

    .modal-content {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      max-width: 600px;
      width: 90%;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      max-height: 80vh;
      overflow-y: auto;
    }

    .modal-content h2 {
      margin-bottom: 1.5rem;
      color: #333;
    }

    .transaction-details {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .detail-row {
      display: flex;
      justify-content: space-between;
      padding: 0.75rem;
      background: #f5f5f5;
      border-radius: 4px;
      flex-wrap: wrap;
      gap: 1rem;
    }

    .detail-label {
      font-weight: 600;
      color: #555;
      min-width: 150px;
    }

    .detail-value {
      color: #333;
      flex: 1;
      text-align: right;
    }

    .modal-actions {
      display: flex;
      gap: 1rem;
      margin-top: 2rem;
    }

    .btn-primary, .btn-secondary {
      flex: 1;
      padding: 0.75rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 600;
      font-size: 1rem;
    }

    .btn-primary {
      background: #667eea;
      color: white;
    }

    .btn-primary:hover {
      background: #5568d3;
    }

    .btn-secondary {
      background: #ccc;
      color: #333;
    }

    .btn-secondary:hover {
      background: #bbb;
    }
  `]
})
export class TransactionsComponent implements OnInit {
  transactions: any[] = [];
  filteredTransactions: any[] = [];
  
  loading = false;
  showDetailsModal = false;
  selectedTransaction: any = null;
  
  filterDate = '';
  statusFilter = '';
  typeFilter = '';
  searchText = '';

  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    this.loadTransactions();
  }
  
  loadTransactions() {
    this.loading = true;
    // Mock data - em produção seria chamado via apiService
    this.transactions = [
      {
        id: 'txn-12345678-1234-1234-1234-123456789012',
        user_id: 'user-001',
        user_name: 'João Silva',
        merchant_id: 'merchant-001',
        merchant_name: 'Restaurante Sabor',
        amount: 45.50,
        type: 'PAYMENT',
        status: 'APPROVED',
        method: 'VR',
        card_last_four: '1234',
        description: 'Almoço',
        created_at: new Date(Date.now() - 86400000 * 2)
      },
      {
        id: 'txn-87654321-4321-4321-4321-210987654321',
        user_id: 'user-002',
        user_name: 'Maria Santos',
        merchant_id: 'merchant-002',
        merchant_name: 'Supermercado BomPreço',
        amount: 156.80,
        type: 'PAYMENT',
        status: 'APPROVED',
        method: 'VA',
        card_last_four: '5678',
        description: 'Compras supermercado',
        created_at: new Date(Date.now() - 86400000)
      },
      {
        id: 'txn-11111111-2222-3333-4444-555555555555',
        user_id: 'user-001',
        user_name: 'João Silva',
        merchant_id: 'merchant-001',
        merchant_name: 'Restaurante Sabor',
        amount: 32.00,
        type: 'PAYMENT',
        status: 'APPROVED',
        method: 'VR',
        card_last_four: '1234',
        description: 'Jantar',
        created_at: new Date()
      },
      {
        id: 'txn-99999999-8888-7777-6666-555544443333',
        user_id: 'user-003',
        user_name: 'Carlos Oliveira',
        merchant_id: 'merchant-003',
        merchant_name: 'Farmácia Saúde',
        amount: 89.90,
        type: 'PAYMENT',
        status: 'PENDING',
        method: 'FLEX',
        card_last_four: '9999',
        description: 'Farmácia - Medicamentos',
        created_at: new Date(Date.now() - 3600000)
      },
      {
        id: 'txn-44444444-5555-6666-7777-888888888888',
        user_id: 'user-002',
        user_name: 'Maria Santos',
        merchant_id: 'merchant-002',
        merchant_name: 'Supermercado BomPreço',
        amount: 250.00,
        type: 'REFUND',
        status: 'DECLINED',
        method: 'VA',
        card_last_four: '5678',
        description: 'Devolução - Produto com defeito',
        created_at: new Date(Date.now() - 172800000)
      }
    ];
    
    this.filteredTransactions = [...this.transactions];
    this.loading = false;
  }
  
  filterTransactions() {
    this.filteredTransactions = this.transactions.filter(txn => {
      const matchesDate = !this.filterDate || 
        new Date(txn.created_at).toISOString().split('T')[0] === this.filterDate;
      
      const matchesStatus = !this.statusFilter || txn.status === this.statusFilter;
      const matchesType = !this.typeFilter || txn.type === this.typeFilter;
      const matchesSearch = !this.searchText ||
        txn.user_name.toLowerCase().includes(this.searchText.toLowerCase()) ||
        txn.merchant_name.toLowerCase().includes(this.searchText.toLowerCase());
      
      return matchesDate && matchesStatus && matchesType && matchesSearch;
    });
  }
  
  viewDetails(txn: any) {
    this.selectedTransaction = txn;
    this.showDetailsModal = true;
  }
  
  closeDetailsModal() {
    this.showDetailsModal = false;
    this.selectedTransaction = null;
  }
  
  downloadReceipt() {
    if (!this.selectedTransaction) return;
    
    const receipt = `
RECIBO DE TRANSAÇÃO
═══════════════════════════════════════
ID: ${this.selectedTransaction.id}
Data: ${new Date(this.selectedTransaction.created_at).toLocaleString('pt-BR')}

Usuário: ${this.selectedTransaction.user_name}
Comerciante: ${this.selectedTransaction.merchant_name}
Valor: ${new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(this.selectedTransaction.amount)}
Tipo: ${this.selectedTransaction.type}
Status: ${this.selectedTransaction.status}
Método: ${this.selectedTransaction.method}

Descrição: ${this.selectedTransaction.description}
═══════════════════════════════════════
    `;
    
    const element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(receipt));
    element.setAttribute('download', `recibo-${this.selectedTransaction.id}.txt`);
    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  }
}
