import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AdminService } from '../../services/admin.service';
import { Tenant, TenantConfigKV } from '../../models/tenant';

@Component({
  selector: 'app-tenant-list',
  templateUrl: './tenant-list.component.html',
  styleUrls: ['./tenant-list.component.css']
})
export class TenantListComponent implements OnInit {
  tenants: Tenant[] = [];
  loading = true;
  form: FormGroup;
  configs: TenantConfigKV[] = [];
  error: string | null = null;
  success: string | null = null;

  constructor(private adminService: AdminService, private fb: FormBuilder) {
    this.form = this.fb.group({
      code: ['', [Validators.required, Validators.minLength(3)]],
      name: ['', [Validators.required, Validators.minLength(5)]],
      active: [true]
    });
  }

  ngOnInit(): void {
    this.loadTenants();
  }

  loadTenants(): void {
    this.adminService.getTenantConfigs('default').subscribe({
      next: (resp) => {
        this.configs = resp.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load tenants';
        this.loading = false;
      }
    });
  }

  editTenant(tenant: Tenant): void {
    this.form.patchValue(tenant);
  }

  saveTenant(): void {
    if (this.form.invalid) {
      this.error = 'Please fill all required fields correctly';
      return;
    }
    
    const { code, name } = this.form.value;
    const kv: TenantConfigKV = { key: `tenant:${code}:name`, value: name };
    
    this.adminService.setConfig(kv).subscribe({
      next: () => {
        this.success = 'Tenant saved successfully!';
        this.form.reset({ active: true });
        setTimeout(() => this.success = null, 3000);
        this.loadTenants();
      },
      error: () => {
        this.error = 'Failed to save tenant';
      }
    });
  }
  
  resetForm(): void {
    this.form.reset({ active: true });
    this.error = null;
  }
}
}
