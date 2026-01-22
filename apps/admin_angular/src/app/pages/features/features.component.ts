import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';
import { environment } from '../../../environments/environment';

interface FeatureFlag {
  key: string;
  enabled: boolean;
  scope: string;
  scopeId: string;
  description: string;
  rolloutPercentage: number;
}

interface Tenant {
  id: string;
  name: string;
}

@Component({
  selector: 'app-features',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="container-fluid py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 mb-0">Feature Flags</h1>
          <p class="text-muted mb-0">Gerenciar funcionalidades por tenant</p>
        </div>
        <button class="btn btn-primary" (click)="openCreateModal()">
          <i class="bi bi-plus-lg me-2"></i>Nova Feature
        </button>
      </div>

      <!-- Filtros -->
      <div class="card mb-4">
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4" *ngIf="isSuperAdmin">
              <label class="form-label">Tenant</label>
              <select class="form-select" [(ngModel)]="selectedTenantId" (change)="loadFeatures()">
                <option value="">Todos os Tenants</option>
                <option *ngFor="let tenant of tenants" [value]="tenant.id">
                  {{ tenant.name }}
                </option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Buscar</label>
              <input type="text" class="form-control" placeholder="Buscar por chave..."
                     [(ngModel)]="searchTerm" (input)="filterFeatures()">
            </div>
            <div class="col-md-4">
              <label class="form-label">Status</label>
              <select class="form-select" [(ngModel)]="statusFilter" (change)="filterFeatures()">
                <option value="">Todos</option>
                <option value="enabled">Habilitados</option>
                <option value="disabled">Desabilitados</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div *ngIf="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Carregando...</span>
        </div>
      </div>

      <!-- Lista de Features -->
      <div class="row g-3" *ngIf="!loading">
        <div class="col-md-6 col-lg-4" *ngFor="let feature of filteredFeatures">
          <div class="card h-100" [class.border-success]="feature.enabled" 
               [class.border-secondary]="!feature.enabled">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <div>
                  <h5 class="card-title mb-1">{{ formatFeatureKey(feature.key) }}</h5>
                  <code class="small text-muted">{{ feature.key }}</code>
                </div>
                <div class="form-check form-switch">
                  <input class="form-check-input" type="checkbox" 
                         [checked]="feature.enabled"
                         (change)="toggleFeature(feature)"
                         [id]="'toggle-' + feature.key">
                </div>
              </div>
              
              <p class="card-text text-muted small mb-3">
                {{ feature.description || 'Sem descrição' }}
              </p>

              <div class="d-flex justify-content-between align-items-center">
                <span class="badge" [class.bg-success]="feature.enabled" 
                      [class.bg-secondary]="!feature.enabled">
                  {{ feature.enabled ? 'Habilitado' : 'Desabilitado' }}
                </span>
                <span class="badge bg-info" *ngIf="feature.rolloutPercentage < 100">
                  {{ feature.rolloutPercentage }}% rollout
                </span>
              </div>
            </div>
            <div class="card-footer bg-transparent">
              <small class="text-muted">
                Scope: {{ feature.scope }} | {{ feature.scopeId }}
              </small>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div *ngIf="!loading && filteredFeatures.length === 0" class="text-center py-5">
        <i class="bi bi-flag display-1 text-muted"></i>
        <h4 class="mt-3">Nenhuma feature encontrada</h4>
        <p class="text-muted">Crie sua primeira feature flag para começar.</p>
      </div>

      <!-- Modal Criar Feature (simplificado) -->
      <div class="modal fade" id="createFeatureModal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">Nova Feature Flag</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Chave</label>
                <input type="text" class="form-control" [(ngModel)]="newFeature.key"
                       placeholder="Ex: VR_ENABLED">
                <small class="text-muted">Use UPPER_SNAKE_CASE</small>
              </div>
              <div class="mb-3">
                <label class="form-label">Descrição</label>
                <input type="text" class="form-control" [(ngModel)]="newFeature.description"
                       placeholder="Descrição da feature">
              </div>
              <div class="mb-3">
                <label class="form-label">Tenant</label>
                <select class="form-select" [(ngModel)]="newFeature.scopeId">
                  <option *ngFor="let tenant of tenants" [value]="tenant.id">
                    {{ tenant.name }}
                  </option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Rollout (%)</label>
                <input type="number" class="form-control" [(ngModel)]="newFeature.rolloutPercentage"
                       min="0" max="100">
              </div>
              <div class="form-check">
                <input type="checkbox" class="form-check-input" [(ngModel)]="newFeature.enabled"
                       id="newFeatureEnabled">
                <label class="form-check-label" for="newFeatureEnabled">Habilitado</label>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
              <button type="button" class="btn btn-primary" (click)="createFeature()">Criar</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .form-switch .form-check-input {
      width: 3em;
      height: 1.5em;
      cursor: pointer;
    }
    .card {
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    .card:hover {
      box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
    }
  `]
})
export class FeaturesComponent implements OnInit {
  features: FeatureFlag[] = [];
  filteredFeatures: FeatureFlag[] = [];
  tenants: Tenant[] = [];
  
  loading = false;
  selectedTenantId = '';
  searchTerm = '';
  statusFilter = '';
  
  isSuperAdmin = false;

  newFeature: Partial<FeatureFlag> = {
    key: '',
    enabled: false,
    scope: 'TENANT',
    scopeId: '',
    description: '',
    rolloutPercentage: 100
  };

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.isSuperAdmin = this.authService.isSuperAdmin();
    this.selectedTenantId = this.authService.getTenantId();
    this.loadTenants();
    this.loadFeatures();
  }

  loadTenants(): void {
    if (this.isSuperAdmin) {
      this.http.get<Tenant[]>(`${environment.apiUrl}/api/v1/tenants`)
        .subscribe({
          next: (tenants) => this.tenants = tenants,
          error: () => {
            // Fallback com dados mock
            this.tenants = [
              { id: 'tenant-default', name: 'Demo' },
              { id: 'tenant-acme', name: 'ACME Corp' }
            ];
          }
        });
    } else {
      this.tenants = [{ id: this.selectedTenantId, name: 'Meu Tenant' }];
    }
  }

  loadFeatures(): void {
    this.loading = true;
    const tenantId = this.selectedTenantId || this.authService.getTenantId();
    
    this.http.get<Record<string, boolean>>(`${environment.apiUrl}/api/v1/tenants/${tenantId}/features`)
      .subscribe({
        next: (featuresMap) => {
          this.features = Object.entries(featuresMap).map(([key, enabled]) => ({
            key,
            enabled,
            scope: 'TENANT',
            scopeId: tenantId,
            description: this.getFeatureDescription(key),
            rolloutPercentage: 100
          }));
          this.filterFeatures();
          this.loading = false;
        },
        error: () => {
          // Fallback com dados mock
          this.features = this.getMockFeatures(tenantId);
          this.filterFeatures();
          this.loading = false;
        }
      });
  }

  filterFeatures(): void {
    this.filteredFeatures = this.features.filter(f => {
      const matchesSearch = !this.searchTerm || 
        f.key.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        f.description?.toLowerCase().includes(this.searchTerm.toLowerCase());
      
      const matchesStatus = !this.statusFilter ||
        (this.statusFilter === 'enabled' && f.enabled) ||
        (this.statusFilter === 'disabled' && !f.enabled);
      
      return matchesSearch && matchesStatus;
    });
  }

  toggleFeature(feature: FeatureFlag): void {
    const newValue = !feature.enabled;
    
    this.http.put<FeatureFlag>(
      `${environment.apiUrl}/api/v1/tenants/${feature.scopeId}/features/${feature.key}`,
      { enabled: newValue, description: feature.description }
    ).subscribe({
      next: () => {
        feature.enabled = newValue;
        console.log(`Feature ${feature.key} toggled to ${newValue}`);
      },
      error: (err) => {
        console.error('Error toggling feature:', err);
        // Revert visually
        feature.enabled = !newValue;
      }
    });
  }

  formatFeatureKey(key: string): string {
    return key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }

  getFeatureDescription(key: string): string {
    const descriptions: Record<string, string> = {
      'VR_ENABLED': 'Vale Refeição habilitado',
      'VA_ENABLED': 'Vale Alimentação habilitado',
      'VT_ENABLED': 'Vale Transporte habilitado',
      'FLEX_WALLET': 'Carteira flexível',
      'PIX_PAYMENT': 'Pagamentos via PIX',
      'VIRTUAL_CARD': 'Cartão virtual',
      'PHYSICAL_CARD': 'Cartão físico',
      'CASHBACK': 'Programa de cashback',
      'QR_PAYMENT': 'Pagamento via QR Code',
      'NOTIFICATIONS': 'Notificações push'
    };
    return descriptions[key] || '';
  }

  getMockFeatures(tenantId: string): FeatureFlag[] {
    return [
      { key: 'VR_ENABLED', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Vale Refeição', rolloutPercentage: 100 },
      { key: 'VA_ENABLED', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Vale Alimentação', rolloutPercentage: 100 },
      { key: 'VT_ENABLED', enabled: false, scope: 'TENANT', scopeId: tenantId, description: 'Vale Transporte', rolloutPercentage: 100 },
      { key: 'PIX_PAYMENT', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Pagamento PIX', rolloutPercentage: 100 },
      { key: 'VIRTUAL_CARD', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Cartão Virtual', rolloutPercentage: 100 },
      { key: 'PHYSICAL_CARD', enabled: false, scope: 'TENANT', scopeId: tenantId, description: 'Cartão Físico', rolloutPercentage: 100 },
      { key: 'CASHBACK', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Cashback', rolloutPercentage: 50 },
      { key: 'NOTIFICATIONS', enabled: true, scope: 'TENANT', scopeId: tenantId, description: 'Notificações', rolloutPercentage: 100 }
    ];
  }

  openCreateModal(): void {
    this.newFeature = {
      key: '',
      enabled: false,
      scope: 'TENANT',
      scopeId: this.selectedTenantId || this.authService.getTenantId(),
      description: '',
      rolloutPercentage: 100
    };
    // Abrir modal (Bootstrap)
    const modal = new (window as any).bootstrap.Modal(document.getElementById('createFeatureModal'));
    modal.show();
  }

  createFeature(): void {
    if (!this.newFeature.key) return;
    
    this.http.post<FeatureFlag>(`${environment.apiUrl}/api/v1/features`, {
      key: this.newFeature.key.toUpperCase().replace(/\s+/g, '_'),
      scope: this.newFeature.scope,
      scopeId: this.newFeature.scopeId,
      enabled: this.newFeature.enabled,
      description: this.newFeature.description,
      rolloutPercentage: this.newFeature.rolloutPercentage
    }).subscribe({
      next: () => {
        this.loadFeatures();
        // Fechar modal
        const modal = (window as any).bootstrap.Modal.getInstance(document.getElementById('createFeatureModal'));
        modal?.hide();
      },
      error: (err) => console.error('Error creating feature:', err)
    });
  }
}
