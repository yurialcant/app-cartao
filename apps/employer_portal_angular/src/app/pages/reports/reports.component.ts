import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="reports-page">
      <h1>Relatórios e Exports</h1>
      <div class="reports-content">
        <p>Relatórios e exports serão exibidos aqui</p>
      </div>
    </div>
  `,
  styles: [`
    .reports-page {
      padding: 2rem;
    }
  `]
})
export class ReportsComponent implements OnInit {
  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    // TODO: Carregar relatórios
  }
}
