import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private baseUrl = environment.apiUrl;
  
  constructor(private http: HttpClient) {}
  
  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token || ''}`
    });
  }
  
  // Users
  getUsers(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/users`, { headers: this.getHeaders() });
  }
  
  createUser(user: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/admin/users`, user, { headers: this.getHeaders() });
  }
  
  onboardUser(userId: string): Observable<any> {
    return this.http.post(`${this.baseUrl}/admin/users/${userId}/onboard`, {}, { headers: this.getHeaders() });
  }
  
  // Batch Credits (F05 - Employer BFF)
  createBatchCredit(batch: any): Observable<any> {
    const headers = this.getHeaders()
      .set('X-Idempotency-Key', `batch-${Date.now()}`)
      .set('X-Correlation-Id', `corr-${Date.now()}`);

    return this.http.post(`${this.baseUrl}/api/v1/credits/batch`, batch, { headers });
  }

  getBatchStatus(batchId: string): Observable<any> {
    return this.http.get(`${this.baseUrl}/api/v1/credits/batch/${batchId}`, { headers: this.getHeaders() });
  }

  listBatches(params?: any): Observable<any> {
    return this.http.get(`${this.baseUrl}/api/v1/credits/batch`, {
      headers: this.getHeaders(),
      params
    });
  }

  // Topups
  createTopupBatch(batch: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/admin/topups/batch`, batch, { headers: this.getHeaders() });
  }
  
  createTopupForUser(userId: string, amount: number): Observable<any> {
    return this.http.post(`${this.baseUrl}/admin/topups/user/${userId}`, { amount }, { headers: this.getHeaders() });
  }
  
  // Merchants
  getMerchants(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/merchants`, { headers: this.getHeaders() });
  }
  
  // Reconciliation
  getReconciliation(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/reconciliation`, { headers: this.getHeaders() });
  }
  
  // Disputes
  getDisputes(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/disputes`, { headers: this.getHeaders() });
  }
  
  // Risk
  getRiskAnalysis(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/risk`, { headers: this.getHeaders() });
  }
  
  // Support
  getTickets(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/support/tickets`, { headers: this.getHeaders() });
  }
  
  // Audit
  getAuditLogs(): Observable<any> {
    return this.http.get(`${this.baseUrl}/admin/audit`, { headers: this.getHeaders() });
  }
}
