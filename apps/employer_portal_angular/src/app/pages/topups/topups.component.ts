import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-topups',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="topups-page">
      <h1>Cargas de Benefícios</h1>
      <div class="actions">
        <button (click)="createManualTopup()">Carga Manual</button>
        <button (click)="createRecurringTopup()">Carga Recorrente</button>
      </div>
      <div class="topups-list">
        <p>Histórico de cargas será exibido aqui</p>
      </div>
    </div>
  `,
  styles: [`
    .topups-page {
      padding: 2rem;
    }
    .actions {
      margin: 1rem 0;
      display: flex;
      gap: 1rem;
    }
    button {
      padding: 0.5rem 1rem;
      background: #667eea;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  `]
})
export class TopupsComponent implements OnInit {
  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    // TODO: Carregar histórico de cargas
  }
  
  createManualTopup() {
    // TODO: Abrir modal para criar carga manual
  }
  
  createRecurringTopup() {
    // TODO: Abrir modal para criar carga recorrente
  }
}
