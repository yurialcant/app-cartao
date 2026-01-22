import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-stores',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <h1>🏬 Lojas</h1>
        <button class="btn-primary">+ Nova Loja</button>
      </div>
      <div class="loading" *ngIf="loading">Carregando lojas...</div>
      <div class="stores-grid" *ngIf="!loading">
        <div class="store-card" *ngFor="let store of stores">
          <h3>{{ store.name }}</h3>
          <p>{{ store.address }}</p>
          <div class="store-meta">
            <span class="status-badge" [class]="'status-' + store.status.toLowerCase()">{{ store.status }}</span>
            <span>{{ store.terminalsCount }} terminais</span>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .btn-primary { background: #2e7d32; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .stores-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
    .store-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .store-card h3 { margin: 0 0 10px 0; }
    .store-card p { color: #666; margin-bottom: 15px; }
    .store-meta { display: flex; justify-content: space-between; align-items: center; }
    .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; }
    .status-active { background: #d4edda; color: #155724; }
    .status-inactive { background: #f8d7da; color: #721c24; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class StoresComponent implements OnInit {
  stores: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadStores();
  }

  loadStores(): void {
    this.apiService.getStores().subscribe({
      next: (data) => { this.stores = data || this.getMockStores(); this.loading = false; },
      error: () => { this.stores = this.getMockStores(); this.loading = false; }
    });
  }

  getMockStores(): any[] {
    return [
      { id: 1, name: 'Loja Centro', address: 'Rua das Flores, 123 - Centro', status: 'ACTIVE', terminalsCount: 3 },
      { id: 2, name: 'Loja Shopping', address: 'Shopping ABC, Loja 45', status: 'ACTIVE', terminalsCount: 2 },
      { id: 3, name: 'Loja Bairro', address: 'Av. Brasil, 500', status: 'INACTIVE', terminalsCount: 1 }
    ];
  }
}
