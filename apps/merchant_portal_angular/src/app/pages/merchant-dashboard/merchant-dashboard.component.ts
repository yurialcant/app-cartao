import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-merchant-dashboard',
  templateUrl: './merchant-dashboard.component.html',
  styleUrls: ['./merchant-dashboard.component.css']
})
export class MerchantDashboardComponent implements OnInit {
  
  dashboardData: any = {
    totalSales: 0,
    totalTransactions: 0,
    netRevenue: 0,
    pendingSettlements: 0,
    operatorsOnline: 0,
    averageTicket: 0
  };
  
  terminals: any[] = [];
  recentTransactions: any[] = [];
  operators: any[] = [];
  
  constructor(private http: HttpClient) {}
  
  ngOnInit(): void {
    this.loadDashboardData();
    this.loadTerminals();
    this.loadRecentTransactions();
    this.loadOperators();
  }
  
  loadDashboardData(): void {
    this.http.get<any>('/api/merchant/dashboard').subscribe(
      (data) => {
        this.dashboardData = data;
      }
    );
  }
  
  loadTerminals(): void {
    this.http.get<any[]>('/api/merchant/terminals').subscribe(
      (data) => {
        this.terminals = data;
      }
    );
  }
  
  loadRecentTransactions(): void {
    this.http.get<any[]>('/api/merchant/transactions?limit=10').subscribe(
      (data) => {
        this.recentTransactions = data;
      }
    );
  }
  
  loadOperators(): void {
    this.http.get<any[]>('/api/merchant/operators').subscribe(
      (data) => {
        this.operators = data;
      }
    );
  }
  
  openTerminal(terminalId: string): void {
    console.log('Opening terminal:', terminalId);
  }
  
  openOperator(operatorId: string): void {
    console.log('Opening operator:', operatorId);
  }
}
