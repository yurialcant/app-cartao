import { Component, OnInit } from '@angular/core';
import { EmployerService } from '../../services/employer.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  dashboardData: any = {};
  loading = true;

  constructor(private employerService: EmployerService) {}

  ngOnInit(): void {
    this.loadDashboard();
  }

  loadDashboard(): void {
    this.employerService.getDashboardData().subscribe({
      next: (data) => {
        this.dashboardData = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading dashboard:', err);
        this.loading = false;
      }
    });
  }
}
