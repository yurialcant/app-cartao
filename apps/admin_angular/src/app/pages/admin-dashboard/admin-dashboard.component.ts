import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-admin-dashboard',
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  
  metrics: any = {
    totalUsers: 0,
    totalTransactions: 0,
    activeAlerts: 0,
    systemHealth: 'OK'
  };
  
  recentAlerts: any[] = [];
  chartData: any = {};
  
  constructor(private http: HttpClient) {}
  
  ngOnInit(): void {
    this.loadMetrics();
    this.loadAlerts();
    this.loadChartData();
  }
  
  loadMetrics(): void {
    this.http.get<any>('/api/admin/metrics').subscribe(
      (data) => {
        this.metrics = data;
      },
      (error) => {
        console.error('Error loading metrics:', error);
      }
    );
  }
  
  loadAlerts(): void {
    this.http.get<any[]>('/api/admin/alerts/default').subscribe(
      (data) => {
        this.recentAlerts = data.slice(0, 10);
      },
      (error) => {
        console.error('Error loading alerts:', error);
      }
    );
  }
  
  loadChartData(): void {
    this.http.get<any>('/api/admin/chart-data').subscribe(
      (data) => {
        this.chartData = data;
      },
      (error) => {
        console.error('Error loading chart data:', error);
      }
    );
  }
  
  resolveAlert(alertId: string): void {
    this.http.put(`/api/admin/alerts/${alertId}/resolve`, {
      resolvedBy: 'system',
      resolution: 'Auto-resolved'
    }).subscribe(
      () => {
        this.loadAlerts();
      },
      (error) => {
        console.error('Error resolving alert:', error);
      }
    );
  }
}
