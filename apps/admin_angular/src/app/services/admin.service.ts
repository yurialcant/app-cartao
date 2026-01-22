import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry, timeout } from 'rxjs/operators';
import { ApiResponse, Tenant, TenantConfigKV } from '../models';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  
  private baseUrl = `${environment.apiUrl}/api/admin`;
  private requestTimeout = 30000; // 30 seconds
  
  constructor(private http: HttpClient) {}
  
  /**
   * Handle HTTP errors
   */
  private handleError(error: HttpErrorResponse) {
    let errorMessage = 'An error occurred';
    
    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Client Error: ${error.error.message}`;
    } else {
      // Server-side error
      if (error.status === 0) {
        errorMessage = 'Network error - unable to reach server';
      } else if (error.status === 401) {
        errorMessage = 'Unauthorized - please login again';
      } else if (error.status === 403) {
        errorMessage = 'Forbidden - you do not have access';
      } else if (error.status === 404) {
        errorMessage = 'Resource not found';
      } else if (error.status === 400) {
        errorMessage = `Validation error: ${error.error?.message || 'Invalid request'}`;
      } else if (error.status >= 500) {
        errorMessage = `Server error (${error.status}): ${error.error?.message || 'Please try again later'}`;
      }
    }
    
    console.error('API Error:', errorMessage, error);
    return throwError(() => new Error(errorMessage));
  }

  private makeRequest<T>(
    method: 'get' | 'post' | 'put' | 'delete',
    endpoint: string,
    data?: any
  ): Observable<T> {
    const url = `${this.baseUrl}${endpoint}`;
    
    let request: Observable<T>;
    
    switch (method) {
      case 'get':
        request = this.http.get<T>(url);
        break;
      case 'post':
        request = this.http.post<T>(url, data);
        break;
      case 'put':
        request = this.http.put<T>(url, data);
        break;
      case 'delete':
        request = this.http.delete<T>(url);
        break;
    }
    
    return request.pipe(
      timeout(this.requestTimeout),
      retry(1),
      catchError(err => this.handleError(err))
    );
  }
  
  // Audit Logs
  getEntityAuditLog(entityType: string, entityId: string): Observable<ApiResponse<any[]>> {
    return this.makeRequest('get', `/audit/${entityType}/${entityId}`);
  }
  
  getUserAuditLog(userId: string, daysBack?: number): Observable<ApiResponse<any[]>> {
    const days = daysBack || 7;
    return this.makeRequest('get', `/audit/user/${userId}?daysBack=${days}`);
  }
  
  // System Alerts
  getActiveAlerts(tenantId: string): Observable<ApiResponse<any[]>> {
    return this.makeRequest('get', `/alerts/${tenantId}`);
  }
  
  createAlert(alert: any): Observable<ApiResponse<any>> {
    return this.makeRequest('post', '/alerts', alert);
  }
  
  resolveAlert(alertId: string, resolution: any): Observable<ApiResponse<any>> {
    return this.makeRequest('put', `/alerts/${alertId}/resolve`, resolution);
  }
  
  // System Config
  getConfig(tenantId: string, configKey: string): Observable<ApiResponse<TenantConfigKV>> {
    return this.makeRequest('get', `/config/${tenantId}/${configKey}`);
  }
  
  getTenantConfigs(tenantId: string): Observable<ApiResponse<TenantConfigKV[]>> {
    return this.makeRequest('get', `/config/${tenantId}`);
  }
  
  setConfig(config: TenantConfigKV): Observable<ApiResponse<TenantConfigKV>> {
    return this.makeRequest('post', '/config', config);
  }
  
  deleteConfig(tenantId: string, configKey: string): Observable<void> {
    return this.makeRequest('delete', `/config/${tenantId}/${configKey}`);
  }
}
