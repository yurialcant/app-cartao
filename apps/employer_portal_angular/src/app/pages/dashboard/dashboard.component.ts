import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dashboard">
      <h1>Dashboard</h1>
      <div class="stats">
        <div class="stat-card">
          <h3>Total Employees</h3>
          <p>{{ totalEmployees }}</p>
        </div>
        <div class="stat-card">
          <h3>Active Employees</h3>
          <p>{{ activeEmployees }}</p>
        </div>
        <div class="stat-card">
          <h3>Pending Topups</h3>
          <p>{{ pendingTopups }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .dashboard {
      padding: 2rem;
    }
    .stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
      margin-top: 2rem;
    }
    .stat-card {
      background: white;
      padding: 1.5rem;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
  `]
})
export class DashboardComponent implements OnInit {
  totalEmployees = 0;
  activeEmployees = 0;
  pendingTopups = 0;
  
  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    // TODO: Carregar dados reais
  }
}
