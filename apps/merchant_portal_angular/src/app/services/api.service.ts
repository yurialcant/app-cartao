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
  
  // Reports
  getReports(params: any): Observable<any> {
    return this.http.get(`${this.baseUrl}/portal/reports`, { headers: this.getHeaders(), params });
  }
  
  // Transfers
  getTransfers(): Observable<any> {
    return this.http.get(`${this.baseUrl}/portal/transfers`, { headers: this.getHeaders() });
  }
  
  // Stores
  getStores(): Observable<any> {
    return this.http.get(`${this.baseUrl}/portal/stores`, { headers: this.getHeaders() });
  }
  
  // Operators
  getOperators(): Observable<any> {
    return this.http.get(`${this.baseUrl}/portal/operators`, { headers: this.getHeaders() });
  }
  
  // Terminals
  getTerminals(): Observable<any> {
    return this.http.get(`${this.baseUrl}/portal/terminals`, { headers: this.getHeaders() });
  }
}
