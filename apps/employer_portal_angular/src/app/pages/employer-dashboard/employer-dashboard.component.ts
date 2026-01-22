import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-employer-dashboard',
  templateUrl: './employer-dashboard.component.html',
  styleUrls: ['./employer-dashboard.component.css']
})
export class EmployerDashboardComponent implements OnInit {
  
  dashboardData: any = {
    totalEmployees: 0,
    totalCreditsDistributed: 0,
    pendingApprovals: 0,
    activeTopups: 0
  };
  
  employees: any[] = [];
  pendingApprovals: any[] = [];
  
  constructor(private http: HttpClient) {}
  
  ngOnInit(): void {
    this.loadDashboardData();
    this.loadEmployees();
    this.loadPendingApprovals();
  }
  
  loadDashboardData(): void {
    this.http.get<any>('/api/employer/dashboard').subscribe(
      (data) => {
        this.dashboardData = data;
      },
      (error) => {
        console.error('Error loading dashboard:', error);
      }
    );
  }
  
  loadEmployees(): void {
    this.http.get<any[]>('/api/employer/employees').subscribe(
      (data) => {
        this.employees = data;
      },
      (error) => {
        console.error('Error loading employees:', error);
      }
    );
  }
  
  loadPendingApprovals(): void {
    this.http.get<any[]>('/api/employer/approvals/pending').subscribe(
      (data) => {
        this.pendingApprovals = data;
      },
      (error) => {
        console.error('Error loading approvals:', error);
      }
    );
  }
  
  approveExpense(approvalId: string): void {
    this.http.put(`/api/employer/approvals/${approvalId}/approve`, {
      approvedBy: 'admin'
    }).subscribe(
      () => {
        this.loadPendingApprovals();
      },
      (error) => {
        console.error('Error approving expense:', error);
      }
    );
  }
  
  rejectExpense(approvalId: string, reason: string): void {
    this.http.put(`/api/employer/approvals/${approvalId}/reject`, {
      rejectionReason: reason
    }).subscribe(
      () => {
        this.loadPendingApprovals();
      },
      (error) => {
        console.error('Error rejecting expense:', error);
      }
    );
  }
}
