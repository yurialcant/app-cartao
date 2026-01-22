import { Routes } from '@angular/router';
import { AuthGuard } from './guards/auth.guard';
import { RoleGuard } from './guards/role.guard';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { ReportsComponent } from './pages/reports/reports.component';
import { TransfersComponent } from './pages/transfers/transfers.component';
import { StoresComponent } from './pages/stores/stores.component';
import { OperatorsComponent } from './pages/operators/operators.component';
import { TerminalsComponent } from './pages/terminals/terminals.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'reports', component: ReportsComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'transfers', component: TransfersComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'stores', component: StoresComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'operators', component: OperatorsComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'terminals', component: TerminalsComponent, canActivate: [AuthGuard, RoleGuard] },
];
