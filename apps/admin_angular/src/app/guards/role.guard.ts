import { Injectable } from '@angular/core';
import { CanActivate, Router, UrlTree, ActivatedRouteSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

/**
 * Guard para verificar roles do usuário.
 * 
 * Uso nas rotas:
 * { path: 'tenants', canActivate: [RoleGuard], data: { roles: ['SUPER_ADMIN'] } }
 * { path: 'users', canActivate: [RoleGuard], data: { roles: ['SUPER_ADMIN', 'ADMIN'] } }
 */
@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  canActivate(route: ActivatedRouteSnapshot): boolean | UrlTree {
    // Roles requeridas para esta rota
    const requiredRoles = route.data['roles'] as string[] | undefined;
    
    // Se não há roles requeridas, permite acesso
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    // Buscar roles do usuário
    const userRoles = this.authService.getUserRoles();
    
    // Verificar se tem pelo menos uma das roles requeridas
    const hasRole = requiredRoles.some(role => userRoles.includes(role));
    
    if (!hasRole) {
      console.warn('Access denied. Required roles:', requiredRoles, 'User roles:', userRoles);
      // Redirecionar para página de acesso negado ou home
      return this.router.parseUrl('/access-denied');
    }
    
    return true;
  }
}

/**
 * Guard específico para rotas que requerem ADMIN ou superior.
 */
@Injectable({ providedIn: 'root' })
export class AdminGuard implements CanActivate {
  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  canActivate(): boolean | UrlTree {
    const userRoles = this.authService.getUserRoles();
    
    if (!userRoles.includes('ADMIN') && !userRoles.includes('SUPER_ADMIN')) {
      return this.router.parseUrl('/');
    }
    
    return true;
  }
}

/**
 * Guard específico para rotas que requerem SUPER_ADMIN.
 */
@Injectable({ providedIn: 'root' })
export class SuperAdminGuard implements CanActivate {
  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  canActivate(): boolean | UrlTree {
    const userRoles = this.authService.getUserRoles();
    
    if (!userRoles.includes('SUPER_ADMIN')) {
      return this.router.parseUrl('/access-denied');
    }
    
    return true;
  }
}

