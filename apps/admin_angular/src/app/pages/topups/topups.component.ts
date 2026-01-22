import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-topups',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="page-container">
      <h1>Top-ups</h1>
      
      <div class="form-section">
        <h2>Criar Top-up para Usuário</h2>
        <form (ngSubmit)="createTopup()">
          <div class="form-group">
            <label>User ID:</label>
            <input type="text" [(ngModel)]="topupUserId" name="userId" required />
            <small>Exemplo: b9a3fdb4-688c-41c7-b705-bcc0e322c022 (user1)</small>
          </div>
          <div class="form-group">
            <label>Valor (R$):</label>
            <input type="number" [(ngModel)]="topupAmount" name="amount" step="0.01" required />
          </div>
          <button type="submit" [disabled]="isLoading">Criar Top-up</button>
        </form>
        <div *ngIf="topupResult" class="result success">
          <p>✅ Top-up criado com sucesso!</p>
          <p>Valor: R$ {{ topupResult.amount }}</p>
          <p>Status: {{ topupResult.status }}</p>
        </div>
        <div *ngIf="errorMessage" class="result error">
          <p>❌ Erro: {{ errorMessage }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container {
      padding: 20px;
    }
    .form-section {
      margin-top: 20px;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 8px;
      max-width: 500px;
    }
    .form-group {
      margin-bottom: 15px;
    }
    label {
      display: block;
      margin-bottom: 5px;
      font-weight: bold;
    }
    input {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
      box-sizing: border-box;
    }
    small {
      display: block;
      margin-top: 5px;
      color: #666;
      font-size: 12px;
    }
    button {
      padding: 10px 20px;
      background: #007bff;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 16px;
    }
    button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    button:hover:not(:disabled) {
      background: #0056b3;
    }
    .result {
      margin-top: 15px;
      padding: 15px;
      border-radius: 4px;
    }
    .result.success {
      background: #d4edda;
      border: 1px solid #c3e6cb;
      color: #155724;
    }
    .result.error {
      background: #f8d7da;
      border: 1px solid #f5c6cb;
      color: #721c24;
    }
  `]
})
export class TopupsComponent implements OnInit {
  topupUserId = 'b9a3fdb4-688c-41c7-b705-bcc0e322c022'; // user1
  topupAmount = 100.00;
  isLoading = false;
  topupResult: any = null;
  errorMessage: string = '';

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    // Componente inicializado
  }

  createTopup() {
    this.isLoading = true;
    this.errorMessage = '';
    this.topupResult = null;
    
    this.apiService.createTopupForUser(this.topupUserId, this.topupAmount).subscribe({
      next: (result) => {
        this.topupResult = result;
        this.isLoading = false;
        console.log('Top-up criado:', result);
      },
      error: (error) => {
        console.error('Erro ao criar topup:', error);
        this.errorMessage = error.error?.message || error.message || 'Erro desconhecido';
        this.isLoading = false;
      }
    });
  }
}


