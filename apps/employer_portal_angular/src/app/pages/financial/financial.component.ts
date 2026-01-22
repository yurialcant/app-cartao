import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-financial',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="financial-page">
      <h1>Financeiro</h1>
      <div class="financial-content">
        <p>Faturas, pagamentos e conciliação serão exibidos aqui</p>
      </div>
    </div>
  `,
  styles: [`
    .financial-page {
      padding: 2rem;
    }
  `]
})
export class FinancialComponent implements OnInit {
  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    // TODO: Carregar dados financeiros
  }
}
