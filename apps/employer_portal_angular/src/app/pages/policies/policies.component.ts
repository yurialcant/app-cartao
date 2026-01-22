import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-policies',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="policies-page">
      <h1>Políticas de Benefício</h1>
      <div class="policies-list">
        <p>Políticas serão exibidas aqui</p>
      </div>
    </div>
  `,
  styles: [`
    .policies-page {
      padding: 2rem;
    }
  `]
})
export class PoliciesComponent implements OnInit {
  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    // TODO: Carregar políticas
  }
}
