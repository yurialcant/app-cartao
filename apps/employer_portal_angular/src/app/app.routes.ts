import { Routes } from '@angular/router';
import { AuthGuard } from './guards/auth.guard';
import { RoleGuard } from './guards/role.guard';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { EmployeesComponent } from './pages/employees/employees.component';
import { TopupsComponent } from './pages/topups/topups.component';
import { PoliciesComponent } from './pages/policies/policies.component';
import { FinancialComponent } from './pages/financial/financial.component';
import { ReportsComponent } from './pages/reports/reports.component';
import { LoginComponent } from './pages/login/login.component';
import { BatchUploadComponent } from './pages/batch-upload/batch-upload.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'employees', component: EmployeesComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'batch-upload', component: BatchUploadComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'topups', component: TopupsComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'policies', component: PoliciesComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'financial', component: FinancialComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: 'reports', component: ReportsComponent, canActivate: [AuthGuard, RoleGuard] },
  { path: '**', redirectTo: '/dashboard' }
];
