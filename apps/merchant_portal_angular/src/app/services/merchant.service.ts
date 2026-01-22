import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ApiResponse } from '../models/common';
import { Terminal, Merchant } from '../models/merchant';
import { Transaction, TransactionFilter } from '../models/transaction';

@Injectable({
  providedIn: 'root'
})
export class MerchantService {
  
  private baseUrl = `${environment.apiUrl}/api`;
  
  constructor(private http: HttpClient) {}
  
  // Dashboard
  getSalesDashboard(): Observable<ApiResponse<any>> {
    return this.http.get<ApiResponse<any>>(`${this.baseUrl}/dashboard/sales`);
  }
  
  getOperatorsDashboard(): Observable<ApiResponse<any>> {
    return this.http.get<ApiResponse<any>>(`${this.baseUrl}/dashboard/operators`);
  }
  
  // Terminals
  getTerminals(): Observable<ApiResponse<Terminal[]>> {
    return this.http.get<ApiResponse<Terminal[]>>(`${this.baseUrl}/merchant/terminals`);
  }
  
  getTerminal(terminalId: string): Observable<ApiResponse<Terminal>> {
    return this.http.get<ApiResponse<Terminal>>(`${this.baseUrl}/merchant/terminals/${terminalId}`);
  }
  
  updateTerminal(terminalId: string, terminal: Partial<Terminal>): Observable<ApiResponse<Terminal>> {
    return this.http.put<ApiResponse<Terminal>>(`${this.baseUrl}/merchant/terminals/${terminalId}`, terminal);
  }
  
  // Operators
  getOperators(): Observable<ApiResponse<any[]>> {
    return this.http.get<ApiResponse<any[]>>(`${this.baseUrl}/merchant/operators`);
  }
  
  createOperator(operator: { name: string; email: string }): Observable<ApiResponse<any>> {
    return this.http.post<ApiResponse<any>>(`${this.baseUrl}/merchant/operators`, operator);
  }
  
  // Transactions
  getTransactions(filter?: TransactionFilter): Observable<ApiResponse<Transaction[]>> {
    let url = `${this.baseUrl}/merchant/transactions`;
    if (filter) {
      const params = new URLSearchParams();
      if (filter.status) params.append('status', filter.status);
      if (filter.from) params.append('from', filter.from);
      if (filter.to) params.append('to', filter.to);
      if (filter.minAmount !== undefined) params.append('minAmount', String(filter.minAmount));
      if (filter.maxAmount !== undefined) params.append('maxAmount', String(filter.maxAmount));
      if (filter.page !== undefined) params.append('page', String(filter.page));
      if (filter.pageSize !== undefined) params.append('pageSize', String(filter.pageSize));
      url += `?${params.toString()}`;
    }
    return this.http.get<ApiResponse<Transaction[]>>(url);
  }
  
  // Transfers
  getMerchantTransfers(merchantId: string): Observable<ApiResponse<any[]>> {
    return this.http.get<ApiResponse<any[]>>(`${this.baseUrl}/transfers/merchant/${merchantId}`);
  }
  
  createTransfer(transfer: { amount: number; destination: string }): Observable<ApiResponse<any>> {
    return this.http.post<ApiResponse<any>>(`${this.baseUrl}/transfers`, transfer);
  }
}
