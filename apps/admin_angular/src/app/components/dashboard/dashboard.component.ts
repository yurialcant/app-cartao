import { Component, OnInit } from '@angular/core';
import { AdminService } from '../../services/admin.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  stats: any = {};
  loading = true;

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadDashboard();
  }

  loadDashboard(): void {
    // TODO: Implement dashboard data loading from API
    this.stats = {
      totalTenants: 0,
      activeUsers: 0,
      totalTransactions: 0,
      systemHealth: 'Healthy'
    };
    this.loading = false;
  }
}
