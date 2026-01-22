import { Component, OnInit } from '@angular/core';
import { AdminService } from '../../services/admin.service';

@Component({
  selector: 'app-config',
  templateUrl: './config.component.html',
  styleUrls: ['./config.component.css']
})
export class ConfigComponent implements OnInit {
  configs: any[] = [];
  loading = true;
  newConfig = { key: '', value: '', description: '' };

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadConfigs();
  }

  loadConfigs(): void {
    this.adminService.getConfig('').subscribe({
      next: (configs) => {
        this.configs = configs;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading configs:', err);
        this.loading = false;
      }
    });
  }

  saveConfig(): void {
    this.adminService.setConfig(this.newConfig.key, this.newConfig.value).subscribe({
      next: () => {
        this.loadConfigs();
        this.newConfig = { key: '', value: '', description: '' };
      },
      error: (err) => console.error('Error saving config:', err)
    });
  }

  deleteConfig(key: string): void {
    if (confirm(`Delete config ${key}?`)) {
      this.adminService.deleteConfig(key).subscribe({
        next: () => this.loadConfigs(),
        error: (err) => console.error('Error deleting config:', err)
      });
    }
  }
}
