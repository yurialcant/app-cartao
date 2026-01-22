import { Component, OnInit } from '@angular/core';
import { AdminService } from '../../services/admin.service';

@Component({
  selector: 'app-audit-log',
  templateUrl: './audit-log.component.html',
  styleUrls: ['./audit-log.component.css']
})
export class AuditLogComponent implements OnInit {
  auditLogs: any[] = [];
  loading = true;
  entityType = '';
  entityId = '';

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadAuditLogs();
  }

  loadAuditLogs(): void {
    this.loading = true;
    this.adminService.getEntityAuditLog(this.entityType, this.entityId ? parseInt(this.entityId) : null)
      .subscribe({
        next: (logs) => {
          this.auditLogs = logs;
          this.loading = false;
        },
        error: (err) => {
          console.error('Error loading audit logs:', err);
          this.loading = false;
        }
      });
  }

  filter(): void {
    this.loadAuditLogs();
  }
}
