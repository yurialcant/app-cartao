import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AdminDashboardComponent } from './pages/admin-dashboard/admin-dashboard.component';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: AdminDashboardComponent },
  { path: 'tenants', loadChildren: () => import('./pages/tenants/tenants.module').then(m => m.TenantsModule) },
  { path: 'audit', loadChildren: () => import('./pages/audit/audit.module').then(m => m.AuditModule) },
  { path: 'config', loadChildren: () => import('./pages/config/config.module').then(m => m.ConfigModule) },
  { path: 'alerts', loadChildren: () => import('./pages/alerts/alerts.module').then(m => m.AlertsModule) },
  { path: '**', redirectTo: '/dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
