import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-terminals',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <div class="page-header">
        <h1>📱 Terminais</h1>
        <button class="btn-primary">+ Novo Terminal</button>
      </div>
      <div class="loading" *ngIf="loading">Carregando terminais...</div>
      <div class="terminals-grid" *ngIf="!loading">
        <div class="terminal-card" *ngFor="let terminal of terminals" [class]="'status-' + terminal.status.toLowerCase()">
          <div class="terminal-icon">📱</div>
          <h3>{{ terminal.serialNumber }}</h3>
          <p>{{ terminal.storeName }}</p>
          <div class="terminal-status">
            <span class="status-indicator"></span>
            {{ terminal.status }}
          </div>
          <p class="last-activity">Ult. atividade: {{ terminal.lastActivity | date:'dd/MM HH:mm' }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .btn-primary { background: #2e7d32; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .terminals-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
    .terminal-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
    .terminal-card.status-online { border-top: 3px solid #28a745; }
    .terminal-card.status-offline { border-top: 3px solid #dc3545; }
    .terminal-icon { font-size: 48px; margin-bottom: 10px; }
    .terminal-card h3 { margin: 0 0 5px 0; font-size: 14px; color: #333; }
    .terminal-card p { margin: 0; color: #666; font-size: 12px; }
    .terminal-status { margin: 15px 0; display: flex; align-items: center; justify-content: center; gap: 8px; }
    .status-indicator { width: 8px; height: 8px; border-radius: 50%; }
    .status-online .status-indicator { background: #28a745; }
    .status-offline .status-indicator { background: #dc3545; }
    .last-activity { font-size: 11px !important; color: #999 !important; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class TerminalsComponent implements OnInit {
  terminals: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadTerminals();
  }

  loadTerminals(): void {
    this.apiService.getTerminals().subscribe({
      next: (data) => { this.terminals = data || this.getMockTerminals(); this.loading = false; },
      error: () => { this.terminals = this.getMockTerminals(); this.loading = false; }
    });
  }

  getMockTerminals(): any[] {
    return [
      { id: 1, serialNumber: 'POS-001-A1B2', storeName: 'Loja Centro', status: 'ONLINE', lastActivity: new Date() },
      { id: 2, serialNumber: 'POS-002-C3D4', storeName: 'Loja Shopping', status: 'ONLINE', lastActivity: new Date() },
      { id: 3, serialNumber: 'POS-003-E5F6', storeName: 'Loja Bairro', status: 'OFFLINE', lastActivity: new Date(Date.now() - 86400000) }
    ];
  }
}
