import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { Router } from '@angular/router';

export interface UserInfo {
  id: string;
  username: string;
  email: string;
  name: string;
  roles: string[];
  tenantId: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly TOKEN_KEY = 'auth_token';
  private readonly USER_KEY = 'user_info';

  private currentUserSubject = new BehaviorSubject<UserInfo | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(private router: Router) {
    this.loadStoredUser();
  }

  private loadStoredUser(): void {
    const storedUser = localStorage.getItem(this.USER_KEY);
    if (storedUser) {
      try {
        const user = JSON.parse(storedUser);
        this.currentUserSubject.next(user);
      } catch (e) {
        this.clearAuth();
      }
    }
  }

  /**
   * Mock login para desenvolvimento
   */
  login(username: string, password: string): Observable<boolean> {
    const mockUsers: Record<string, {password: string, user: UserInfo}> = {
      'merchant@flash.com': {
        password: 'merchant123',
        user: {
          id: 'merchant-001',
          username: 'merchant',
          email: 'merchant@flash.com',
          name: 'Merchant Admin',
          roles: ['MERCHANT_ADMIN'],
          tenantId: 'tenant-default'
        }
      },
      'merchant@demo.com': {
        password: 'merchant123',
        user: {
          id: 'merchant-002',
          username: 'merchant',
          email: 'merchant@demo.com',
          name: 'Demo Merchant',
          roles: ['MERCHANT_ADMIN'],
          tenantId: 'tenant-default'
        }
      }
    };

    const mockCreds = mockUsers[username];
    if (mockCreds && mockCreds.password === password) {
      const mockToken = 'mock-jwt-token-' + btoa(username);
      localStorage.setItem(this.TOKEN_KEY, mockToken);
      localStorage.setItem(this.USER_KEY, JSON.stringify(mockCreds.user));
      
      this.currentUserSubject.next(mockCreds.user);
      console.log('✅ Mock login successful for:', username);
      return of(true);
    }
    
    console.error('❌ Invalid credentials');
    return of(false);
  }

  logout(): void {
    this.clearAuth();
    this.router.navigate(['/login']);
  }

  private clearAuth(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  getCurrentUser(): UserInfo | null {
    return this.currentUserSubject.value;
  }

  isAuthenticated(): boolean {
    return !!this.getToken() && !!this.getCurrentUser();
  }

  getTenantId(): string {
    return this.getCurrentUser()?.tenantId || 'default';
  }
}
