import { Routes } from '@angular/router';
import { AuthGuard } from './guards/auth.guard';
import { RoleGuard, AdminGuard, SuperAdminGuard } from './guards/role.guard';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { UsersComponent } from './pages/users/users.component';
import { MerchantsComponent } from './pages/merchants/merchants.component';
import { TopupsComponent } from './pages/topups/topups.component';
import { ReconciliationComponent } from './pages/reconciliation/reconciliation.component';
import { DisputesComponent } from './pages/disputes/disputes.component';
import { RiskComponent } from './pages/risk/risk.component';
import { SupportComponent } from './pages/support/support.component';
import { AuditComponent } from './pages/audit/audit.component';
import { TenantsComponent } from './pages/tenants/tenants.component';
import { FeaturesComponent } from './pages/features/features.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  
  // Dashboard - acessível para ADMIN e SUPER_ADMIN
  { 
    path: 'dashboard', 
    component: DashboardComponent, 
    canActivate: [AuthGuard, AdminGuard] 
  },
  
  // Tenants - SUPER_ADMIN pode gerenciar todos, ADMIN vê apenas o seu
  { 
    path: 'tenants', 
    component: TenantsComponent, 
    canActivate: [AuthGuard, AdminGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Feature Flags - SUPER_ADMIN e ADMIN
  { 
    path: 'features', 
    component: FeaturesComponent, 
    canActivate: [AuthGuard, AdminGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Usuários - SUPER_ADMIN e ADMIN
  { 
    path: 'users', 
    component: UsersComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Merchants - SUPER_ADMIN e ADMIN
  { 
    path: 'merchants', 
    component: MerchantsComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Topups - SUPER_ADMIN e ADMIN
  { 
    path: 'topups', 
    component: TopupsComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Reconciliação - SUPER_ADMIN e ADMIN
  { 
    path: 'reconciliation', 
    component: ReconciliationComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Disputas - SUPER_ADMIN e ADMIN
  { 
    path: 'disputes', 
    component: DisputesComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Risk - apenas SUPER_ADMIN
  { 
    path: 'risk', 
    component: RiskComponent, 
    canActivate: [AuthGuard, SuperAdminGuard],
    data: { roles: ['SUPER_ADMIN'] }
  },
  
  // Suporte - SUPER_ADMIN e ADMIN
  { 
    path: 'support', 
    component: SupportComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Audit - SUPER_ADMIN e ADMIN
  { 
    path: 'audit', 
    component: AuditComponent, 
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['SUPER_ADMIN', 'ADMIN'] }
  },
  
  // Página de acesso negado
  { 
    path: 'access-denied', 
    loadComponent: () => import('./pages/access-denied/access-denied.component').then(m => m.AccessDeniedComponent)
  },
  
  // Wildcard
  { path: '**', redirectTo: '/dashboard' }
];
