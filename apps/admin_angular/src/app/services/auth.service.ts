import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of } from 'rxjs';
import { tap, catchError, map } from 'rxjs/operators';
import { Router } from '@angular/router';
import { environment } from '../../environments/environment';

export interface UserInfo {
  id: string;
  username: string;
  email: string;
  name: string;
  roles: string[];
  tenantId: string;
  permissions: string[];
}

export interface TokenInfo {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
}

/**
 * Serviço de autenticação integrado com Keycloak.
 * 
 * Responsabilidades:
 * - Login/Logout
 * - Gerenciamento de tokens
 * - Extração de roles do JWT
 * - Verificação de permissões
 */
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly TOKEN_KEY = 'auth_token';
  private readonly REFRESH_KEY = 'refresh_token';
  private readonly USER_KEY = 'user_info';

  private currentUserSubject = new BehaviorSubject<UserInfo | null>(null);
  public currentUser$ = this.currentUserSubject.asObservable();

  private isAuthenticatedSubject = new BehaviorSubject<boolean>(false);
  public isAuthenticated$ = this.isAuthenticatedSubject.asObservable();

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    this.loadStoredUser();
  }

  /**
   * Carrega usuário do localStorage se existir
   */
  private loadStoredUser(): void {
    const storedUser = localStorage.getItem(this.USER_KEY);
    const token = localStorage.getItem(this.TOKEN_KEY);
    
    if (storedUser && token) {
      try {
        const user = JSON.parse(storedUser);
        this.currentUserSubject.next(user);
        this.isAuthenticatedSubject.next(true);
      } catch (e) {
        this.clearAuth();
      }
    }
  }

  /**
   * Login via Keycloak (password grant para desenvolvimento)
   * FALLBACK: Se Keycloak falhar, usa credenciais mock
   */
  login(username: string, password: string): Observable<boolean> {
    // MODO MOCK - Remover em produção
    if (this.tryMockLogin(username, password)) {
      return of(true);
    }
    
    const keycloakUrl = environment.keycloakUrl || 'http://localhost:8081';
    const realm = environment.keycloakRealm || 'benefits';
    const clientId = environment.keycloakClientId || 'benefits-admin-portal';

    const tokenUrl = `${keycloakUrl}/realms/${realm}/protocol/openid-connect/token`;
    
    const body = new URLSearchParams();
    body.set('grant_type', 'password');
    body.set('client_id', clientId);
    body.set('username', username);
    body.set('password', password);

    return this.http.post<any>(tokenUrl, body.toString(), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
    }).pipe(
      tap(response => {
        this.handleTokenResponse(response);
      }),
      map(() => true),
      catchError(error => {
        console.error('Login failed via Keycloak, trying mock...', error);
        // Fallback para mock
        if (this.tryMockLogin(username, password)) {
          return of(true);
        }
        return of(false);
      })
    );
  }

  /**
   * Mock login para desenvolvimento (REMOVER EM PRODUÇÃO)
   */
  private tryMockLogin(username: string, password: string): boolean {
    const mockUsers: Record<string, {password: string, user: UserInfo}> = {
      'admin@flash.com': {
        password: 'admin123',
        user: {
          id: 'admin-001',
          username: 'admin',
          email: 'admin@flash.com',
          name: 'Super Admin',
          roles: ['SUPER_ADMIN', 'ADMIN'],
          tenantId: 'tenant-default',
          permissions: ['tenants:read', 'tenants:write', 'tenants:delete', 'users:read', 'users:write', 'users:delete', 'features:read', 'features:write']
        }
      },
      'admin': {
        password: 'admin123',
        user: {
          id: 'admin-001',
          username: 'admin',
          email: 'admin@flash.com',
          name: 'Super Admin',
          roles: ['SUPER_ADMIN', 'ADMIN'],
          tenantId: 'tenant-default',
          permissions: ['tenants:read', 'tenants:write', 'tenants:delete', 'users:read', 'users:write', 'users:delete', 'features:read', 'features:write']
        }
      }
    };

    const mockCreds = mockUsers[username];
    if (mockCreds && mockCreds.password === password) {
      // Simular token JWT
      const mockToken = 'mock-jwt-token-' + btoa(username);
      localStorage.setItem(this.TOKEN_KEY, mockToken);
      localStorage.setItem(this.USER_KEY, JSON.stringify(mockCreds.user));
      
      this.currentUserSubject.next(mockCreds.user);
      this.isAuthenticatedSubject.next(true);
      
      console.log('🔐 Mock login successful for:', username);
      return true;
    }
    
    return false;
  }

  /**
   * Processa resposta de token do Keycloak
   */
  private handleTokenResponse(response: any): void {
    const accessToken = response.access_token;
    const refreshToken = response.refresh_token;
    
    localStorage.setItem(this.TOKEN_KEY, accessToken);
    localStorage.setItem(this.REFRESH_KEY, refreshToken);

    // Decodificar JWT para extrair informações do usuário
    const user = this.decodeToken(accessToken);
    localStorage.setItem(this.USER_KEY, JSON.stringify(user));
    
    this.currentUserSubject.next(user);
    this.isAuthenticatedSubject.next(true);
  }

  /**
   * Decodifica o JWT e extrai informações do usuário
   */
  private decodeToken(token: string): UserInfo {
    try {
      const payload = token.split('.')[1];
      const decoded = JSON.parse(atob(payload));
      
      // Extrair roles de diferentes locais possíveis no JWT
      let roles: string[] = [];
      
      // Roles no claim "roles" (nosso custom mapper)
      if (Array.isArray(decoded.roles)) {
        roles = decoded.roles;
      }
      
      // Roles em realm_access.roles (padrão Keycloak)
      if (decoded.realm_access?.roles) {
        roles = [...roles, ...decoded.realm_access.roles];
      }
      
      // Remover duplicatas
      roles = [...new Set(roles)];
      
      return {
        id: decoded.sub,
        username: decoded.preferred_username || decoded.username,
        email: decoded.email,
        name: decoded.name || decoded.preferred_username,
        roles: roles,
        tenantId: decoded.tenant_id || 'default',
        permissions: this.derivePermissions(roles)
      };
    } catch (e) {
      console.error('Error decoding token:', e);
      return {
        id: '',
        username: '',
        email: '',
        name: '',
        roles: [],
        tenantId: 'default',
        permissions: []
      };
    }
  }

  /**
   * Deriva permissões a partir das roles
   */
  private derivePermissions(roles: string[]): string[] {
    const permissions: string[] = [];
    
    if (roles.includes('SUPER_ADMIN')) {
      permissions.push(
        'tenants:read', 'tenants:write', 'tenants:delete',
        'users:read', 'users:write', 'users:delete',
        'merchants:read', 'merchants:write', 'merchants:delete',
        'features:read', 'features:write',
        'system:read', 'system:write',
        'reports:read', 'reports:export'
      );
    }
    
    if (roles.includes('ADMIN')) {
      permissions.push(
        'tenants:read',
        'users:read', 'users:write',
        'merchants:read', 'merchants:write',
        'features:read',
        'reports:read'
      );
    }
    
    return [...new Set(permissions)];
  }

  /**
   * Logout - limpa tokens e redireciona
   */
  logout(): void {
    const keycloakUrl = environment.keycloakUrl || 'http://localhost:8081';
    const realm = environment.keycloakRealm || 'benefits';
    
    this.clearAuth();
    
    // Opcional: logout no Keycloak
    // window.location.href = `${keycloakUrl}/realms/${realm}/protocol/openid-connect/logout`;
    
    this.router.navigate(['/login']);
  }

  /**
   * Limpa dados de autenticação
   */
  private clearAuth(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.currentUserSubject.next(null);
    this.isAuthenticatedSubject.next(false);
  }

  /**
   * Retorna o token de acesso atual
   */
  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  /**
   * Retorna o usuário atual
   */
  getCurrentUser(): UserInfo | null {
    return this.currentUserSubject.value;
  }

  /**
   * Retorna as roles do usuário atual
   */
  getUserRoles(): string[] {
    return this.currentUserSubject.value?.roles || [];
  }

  /**
   * Verifica se o usuário tem uma role específica
   */
  hasRole(role: string): boolean {
    return this.getUserRoles().includes(role);
  }

  /**
   * Verifica se o usuário tem pelo menos uma das roles
   */
  hasAnyRole(roles: string[]): boolean {
    const userRoles = this.getUserRoles();
    return roles.some(role => userRoles.includes(role));
  }

  /**
   * Verifica se o usuário tem uma permissão específica
   */
  hasPermission(permission: string): boolean {
    return this.currentUserSubject.value?.permissions.includes(permission) || false;
  }

  /**
   * Verifica se o usuário é SUPER_ADMIN
   */
  isSuperAdmin(): boolean {
    return this.hasRole('SUPER_ADMIN');
  }

  /**
   * Verifica se o usuário é ADMIN (inclui SUPER_ADMIN)
   */
  isAdmin(): boolean {
    return this.hasAnyRole(['ADMIN', 'SUPER_ADMIN']);
  }

  /**
   * Retorna o tenant_id do usuário
   */
  getTenantId(): string {
    return this.currentUserSubject.value?.tenantId || 'default';
  }

  /**
   * Verifica se está autenticado
   */
  isAuthenticated(): boolean {
    return this.isAuthenticatedSubject.value;
  }
}
