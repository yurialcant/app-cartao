import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';
import { environment } from '../../../environments/environment';

interface Tenant {
  id: string;
  name: string;
  domain: string;
  programType: string;
  status: string;
  usersCount: number;
  employersCount: number;
  merchantsCount: number;
  planName: string;
  createdAt: Date;
}

@Component({
  selector: 'app-tenants',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  template: `
    <div class="container-fluid py-4">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 mb-0">Tenants</h1>
          <p class="text-muted mb-0">Gerenciamento de clientes white-label</p>
        </div>
        <button class="btn btn-primary" (click)="openCreateModal()" *ngIf="isSuperAdmin">
          <i class="bi bi-plus-lg me-2"></i>Novo Tenant
        </button>
      </div>

      <!-- Alert para ADMIN não super -->
      <div class="alert alert-info" *ngIf="!isSuperAdmin">
        <i class="bi bi-info-circle me-2"></i>
        Você está visualizando apenas o seu tenant. Contate um Super Admin para gerenciar outros tenants.
      </div>

      <!-- Stats Cards -->
      <div class="row g-3 mb-4" *ngIf="isSuperAdmin">
        <div class="col-md-3">
          <div class="card bg-primary text-white">
            <div class="card-body">
              <h6 class="card-title mb-0">Total Tenants</h6>
              <h2 class="mb-0">{{ tenants.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-success text-white">
            <div class="card-body">
              <h6 class="card-title mb-0">Ativos</h6>
              <h2 class="mb-0">{{ getCountByStatus('ACTIVE') }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-warning text-dark">
            <div class="card-body">
              <h6 class="card-title mb-0">Pendentes</h6>
              <h2 class="mb-0">{{ getCountByStatus('PENDING') }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="card bg-secondary text-white">
            <div class="card-body">
              <h6 class="card-title mb-0">Inativos</h6>
              <h2 class="mb-0">{{ getCountByStatus('INACTIVE') }}</h2>
            </div>
          </div>
        </div>
      </div>

      <!-- Filtros -->
      <div class="card mb-4" *ngIf="isSuperAdmin">
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <input type="text" class="form-control" placeholder="Buscar por nome ou domínio..."
                     [(ngModel)]="searchTerm" (input)="filterTenants()">
            </div>
            <div class="col-md-3">
              <select class="form-select" [(ngModel)]="programTypeFilter" (change)="filterTenants()">
                <option value="">Todos os Programas</option>
                <option value="PAT">PAT Restrito</option>
                <option value="FLEX">Benefício Flex</option>
                <option value="DIGITAL">Conta Digital</option>
              </select>
            </div>
            <div class="col-md-3">
              <select class="form-select" [(ngModel)]="statusFilter" (change)="filterTenants()">
                <option value="">Todos os Status</option>
                <option value="ACTIVE">Ativo</option>
                <option value="PENDING">Pendente</option>
                <option value="INACTIVE">Inativo</option>
                <option value="SUSPENDED">Suspenso</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div *ngIf="loading" class="text-center py-5">
        <div class="spinner-border text-primary"></div>
      </div>

      <!-- Tabela de Tenants -->
      <div class="card" *ngIf="!loading">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Tenant</th>
                <th>Domínio</th>
                <th>Programa</th>
                <th>Usuários</th>
                <th>Status</th>
                <th class="text-end">Ações</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let tenant of filteredTenants">
                <td>
                  <div class="d-flex align-items-center">
                    <div class="avatar-sm bg-primary text-white rounded-circle me-2 d-flex align-items-center justify-content-center"
                         style="width: 36px; height: 36px;">
                      {{ tenant.name.charAt(0).toUpperCase() }}
                    </div>
                    <div>
                      <strong>{{ tenant.name }}</strong>
                      <br>
                      <small class="text-muted">{{ tenant.planName || 'Sem plano' }}</small>
                    </div>
                  </div>
                </td>
                <td>
                  <code>{{ tenant.domain }}</code>
                </td>
                <td>
                  <span class="badge" [ngClass]="{
                    'bg-info': tenant.programType === 'PAT',
                    'bg-success': tenant.programType === 'FLEX',
                    'bg-primary': tenant.programType === 'DIGITAL'
                  }">
                    {{ getProgramTypeLabel(tenant.programType) }}
                  </span>
                </td>
                <td>
                  <div class="d-flex flex-column">
                    <small><strong>{{ tenant.usersCount || 0 }}</strong> usuários</small>
                    <small class="text-muted">{{ tenant.employersCount || 0 }} empresas</small>
                  </div>
                </td>
                <td>
                  <span class="badge" [ngClass]="{
                    'bg-success': tenant.status === 'ACTIVE',
                    'bg-warning text-dark': tenant.status === 'PENDING',
                    'bg-secondary': tenant.status === 'INACTIVE',
                    'bg-danger': tenant.status === 'SUSPENDED'
                  }">
                    {{ getStatusLabel(tenant.status) }}
                  </span>
                </td>
                <td class="text-end">
                  <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" (click)="viewTenant(tenant)"
                            title="Visualizar">
                      <i class="bi bi-eye"></i>
                    </button>
                    <button class="btn btn-outline-secondary" (click)="editTenant(tenant)"
                            title="Editar" *ngIf="canEdit(tenant)">
                      <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-outline-info" [routerLink]="['/features']"
                            [queryParams]="{tenant: tenant.id}" title="Features">
                      <i class="bi bi-flag"></i>
                    </button>
                    <button class="btn btn-outline-danger" (click)="deactivateTenant(tenant)"
                            title="Desativar" *ngIf="isSuperAdmin && tenant.status === 'ACTIVE'">
                      <i class="bi bi-x-circle"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Empty State -->
      <div *ngIf="!loading && filteredTenants.length === 0" class="text-center py-5">
        <i class="bi bi-building display-1 text-muted"></i>
        <h4 class="mt-3">Nenhum tenant encontrado</h4>
      </div>

      <!-- Modal Criar/Editar Tenant -->
      <div class="modal fade" id="tenantModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">{{ editingTenant ? 'Editar' : 'Novo' }} Tenant</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Nome *</label>
                  <input type="text" class="form-control" [(ngModel)]="tenantForm.name"
                         placeholder="Nome do cliente">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Domínio *</label>
                  <input type="text" class="form-control" [(ngModel)]="tenantForm.domain"
                         placeholder="cliente.benefits.local">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Tipo de Programa *</label>
                  <select class="form-select" [(ngModel)]="tenantForm.programType">
                    <option value="PAT">PAT Restrito</option>
                    <option value="FLEX">Benefício Flex</option>
                    <option value="DIGITAL">Conta Digital</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Status</label>
                  <select class="form-select" [(ngModel)]="tenantForm.status">
                    <option value="ACTIVE">Ativo</option>
                    <option value="PENDING">Pendente</option>
                    <option value="INACTIVE">Inativo</option>
                  </select>
                </div>
                <div class="col-12">
                  <hr>
                  <h6>Branding</h6>
                </div>
                <div class="col-md-4">
                  <label class="form-label">Cor Primária</label>
                  <input type="color" class="form-control form-control-color w-100" 
                         [(ngModel)]="tenantForm.primaryColor">
                </div>
                <div class="col-md-4">
                  <label class="form-label">Cor Secundária</label>
                  <input type="color" class="form-control form-control-color w-100"
                         [(ngModel)]="tenantForm.secondaryColor">
                </div>
                <div class="col-md-4">
                  <label class="form-label">Nome do App</label>
                  <input type="text" class="form-control" [(ngModel)]="tenantForm.appName"
                         placeholder="Nome exibido no app">
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
              <button type="button" class="btn btn-primary" (click)="saveTenant()">
                {{ editingTenant ? 'Salvar' : 'Criar' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .avatar-sm {
      font-weight: bold;
      font-size: 14px;
    }
  `]
})
export class TenantsComponent implements OnInit {
  tenants: Tenant[] = [];
  filteredTenants: Tenant[] = [];
  
  loading = false;
  searchTerm = '';
  programTypeFilter = '';
  statusFilter = '';
  
  isSuperAdmin = false;
  editingTenant: Tenant | null = null;
  
  tenantForm = {
    name: '',
    domain: '',
    programType: 'FLEX',
    status: 'ACTIVE',
    primaryColor: '#3B82F6',
    secondaryColor: '#10B981',
    appName: ''
  };

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.isSuperAdmin = this.authService.isSuperAdmin();
    this.loadTenants();
  }

  loadTenants(): void {
    this.loading = true;
    
    this.http.get<Tenant[]>(`${environment.apiUrl}/api/v1/tenants`)
      .subscribe({
        next: (tenants) => {
          this.tenants = tenants;
          this.filterTenants();
          this.loading = false;
        },
        error: () => {
          // Fallback mock
          this.tenants = this.getMockTenants();
          this.filterTenants();
          this.loading = false;
        }
      });
  }

  filterTenants(): void {
    this.filteredTenants = this.tenants.filter(t => {
      const matchesSearch = !this.searchTerm ||
        t.name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        t.domain.toLowerCase().includes(this.searchTerm.toLowerCase());
      
      const matchesProgram = !this.programTypeFilter || t.programType === this.programTypeFilter;
      const matchesStatus = !this.statusFilter || t.status === this.statusFilter;
      
      return matchesSearch && matchesProgram && matchesStatus;
    });
  }

  getCountByStatus(status: string): number {
    return this.tenants.filter(t => t.status === status).length;
  }

  getProgramTypeLabel(type: string): string {
    const labels: Record<string, string> = {
      'PAT': 'PAT Restrito',
      'FLEX': 'Flex',
      'DIGITAL': 'Conta Digital'
    };
    return labels[type] || type;
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {
      'ACTIVE': 'Ativo',
      'PENDING': 'Pendente',
      'INACTIVE': 'Inativo',
      'SUSPENDED': 'Suspenso'
    };
    return labels[status] || status;
  }

  canEdit(tenant: Tenant): boolean {
    if (this.isSuperAdmin) return true;
    return tenant.id === this.authService.getTenantId();
  }

  openCreateModal(): void {
    this.editingTenant = null;
    this.tenantForm = {
      name: '',
      domain: '',
      programType: 'FLEX',
      status: 'ACTIVE',
      primaryColor: '#3B82F6',
      secondaryColor: '#10B981',
      appName: ''
    };
    this.openModal();
  }

  editTenant(tenant: Tenant): void {
    this.editingTenant = tenant;
    this.tenantForm = {
      name: tenant.name,
      domain: tenant.domain,
      programType: tenant.programType,
      status: tenant.status,
      primaryColor: '#3B82F6',
      secondaryColor: '#10B981',
      appName: tenant.name
    };
    this.openModal();
  }

  viewTenant(tenant: Tenant): void {
    // TODO: Navegar para página de detalhes
    console.log('View tenant:', tenant);
  }

  saveTenant(): void {
    if (this.editingTenant) {
      this.http.put(`${environment.apiUrl}/api/v1/tenants/${this.editingTenant.id}`, this.tenantForm)
        .subscribe({
          next: () => {
            this.loadTenants();
            this.closeModal();
          },
          error: (err) => console.error('Error updating tenant:', err)
        });
    } else {
      this.http.post(`${environment.apiUrl}/api/v1/tenants`, this.tenantForm)
        .subscribe({
          next: () => {
            this.loadTenants();
            this.closeModal();
          },
          error: (err) => console.error('Error creating tenant:', err)
        });
    }
  }

  deactivateTenant(tenant: Tenant): void {
    if (!confirm(`Deseja realmente desativar o tenant "${tenant.name}"?`)) return;
    
    this.http.delete(`${environment.apiUrl}/api/v1/tenants/${tenant.id}`)
      .subscribe({
        next: () => this.loadTenants(),
        error: (err) => console.error('Error deactivating tenant:', err)
      });
  }

  private openModal(): void {
    const modal = new (window as any).bootstrap.Modal(document.getElementById('tenantModal'));
    modal.show();
  }

  private closeModal(): void {
    const modal = (window as any).bootstrap.Modal.getInstance(document.getElementById('tenantModal'));
    modal?.hide();
  }

  private getMockTenants(): Tenant[] {
    if (!this.isSuperAdmin) {
      return [{
        id: this.authService.getTenantId(),
        name: 'Meu Tenant',
        domain: 'mytenant.benefits.local',
        programType: 'FLEX',
        status: 'ACTIVE',
        usersCount: 150,
        employersCount: 3,
        merchantsCount: 25,
        planName: 'Premium',
        createdAt: new Date()
      }];
    }
    
    return [
      {
        id: 'tenant-default',
        name: 'Demo Company',
        domain: 'demo.benefits.local',
        programType: 'FLEX',
        status: 'ACTIVE',
        usersCount: 150,
        employersCount: 3,
        merchantsCount: 25,
        planName: 'Premium',
        createdAt: new Date()
      },
      {
        id: 'tenant-acme',
        name: 'ACME Corporation',
        domain: 'acme.benefits.local',
        programType: 'PAT',
        status: 'ACTIVE',
        usersCount: 500,
        employersCount: 1,
        merchantsCount: 0,
        planName: 'Enterprise',
        createdAt: new Date()
      },
      {
        id: 'tenant-startup',
        name: 'Tech Startup',
        domain: 'startup.benefits.local',
        programType: 'DIGITAL',
        status: 'PENDING',
        usersCount: 0,
        employersCount: 1,
        merchantsCount: 0,
        planName: 'Basic',
        createdAt: new Date()
      }
    ];
  }
}
