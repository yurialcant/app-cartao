import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="page-container">
      <h1>📈 Relatórios</h1>
      <div class="loading" *ngIf="loading">Carregando relatórios...</div>
      <div class="report-cards" *ngIf="!loading">
        <div class="report-card" *ngFor="let report of reports">
          <h3>{{ report.name }}</h3>
          <p>{{ report.description }}</p>
          <button class="btn-download" (click)="downloadReport(report)">Baixar PDF</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .page-container { padding: 20px; }
    .report-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-top: 20px; }
    .report-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .report-card h3 { margin: 0 0 10px 0; }
    .report-card p { color: #666; margin-bottom: 15px; }
    .btn-download { background: #2e7d32; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
    .btn-download:hover { background: #1b5e20; }
    .loading { text-align: center; padding: 40px; }
  `]
})
export class ReportsComponent implements OnInit {
  reports: any[] = [];
  loading = true;

  constructor(private apiService: ApiService) {}
  
  ngOnInit(): void {
    this.loadReports();
  }

  loadReports(): void {
    this.apiService.getReports({}).subscribe({
      next: (data) => { this.reports = data || this.getMockReports(); this.loading = false; },
      error: () => { this.reports = this.getMockReports(); this.loading = false; }
    });
  }

  getMockReports(): any[] {
    return [
      { id: 1, name: 'Vendas Diárias', description: 'Relatório completo de vendas do dia' },
      { id: 2, name: 'Vendas Mensais', description: 'Resumo consolidado do mês' },
      { id: 3, name: 'Repasses', description: 'Histórico de repasses recebidos' },
      { id: 4, name: 'Transações', description: 'Detalhamento de todas as transações' }
    ];
  }

  downloadReport(report: any): void {
    alert(`Baixando: ${report.name}`);
  }
}
