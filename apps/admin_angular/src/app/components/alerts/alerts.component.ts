import { Component, OnInit } from '@angular/core';
import { AdminService } from '../../services/admin.service';

@Component({
  selector: 'app-alerts',
  templateUrl: './alerts.component.html',
  styleUrls: ['./alerts.component.css']
})
export class AlertsComponent implements OnInit {
  alerts: any[] = [];
  loading = true;
  newAlert = { type: 'INFO', message: '', targetUserId: null };

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadAlerts();
  }

  loadAlerts(): void {
    this.adminService.getActiveAlerts().subscribe({
      next: (alerts) => {
        this.alerts = alerts;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading alerts:', err);
        this.loading = false;
      }
    });
  }

  createAlert(): void {
    this.adminService.createAlert(this.newAlert).subscribe({
      next: () => {
        this.loadAlerts();
        this.newAlert = { type: 'INFO', message: '', targetUserId: null };
      },
      error: (err) => console.error('Error creating alert:', err)
    });
  }

  resolveAlert(id: number): void {
    this.adminService.resolveAlert(id).subscribe({
      next: () => this.loadAlerts(),
      error: (err) => console.error('Error resolving alert:', err)
    });
  }
}
