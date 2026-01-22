import { Injectable } from '@angular/core';
import { CanActivate, Router, UrlTree } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private router: Router) {}

  canActivate(): boolean | UrlTree {
    const roles = (localStorage.getItem('roles') || '').split(',');
    if (!roles.includes('EMPLOYER')) {
      return this.router.parseUrl('/');
    }
    return true;
  }
}
