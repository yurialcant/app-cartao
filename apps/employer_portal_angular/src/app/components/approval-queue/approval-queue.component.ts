import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { EmployerService } from '../../services/employer.service';
import { ApprovalRequest } from '../../models/employee';

@Component({
  selector: 'app-approval-queue',
  templateUrl: './approval-queue.component.html',
  styleUrls: ['./approval-queue.component.css']
})
export class ApprovalQueueComponent implements OnInit {
  approvals: ApprovalRequest[] = [];
  loading = true;
  actionForm: FormGroup;
  selectedApprovalId: number | null = null;
  error: string | null = null;
  success: string | null = null;

  constructor(private employerService: EmployerService, private fb: FormBuilder) {
    this.actionForm = this.fb.group({
      note: ['', Validators.maxLength(500)],
      reason: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(200)]]
    });
  }

  ngOnInit(): void {
    this.loadApprovals();
  }

  loadApprovals(): void {
    this.employerService.getPendingApprovals().subscribe({
      next: (resp) => {
        this.approvals = resp.data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load approvals';
        this.loading = false;
      }
    });
  }

  selectApproval(id: number): void {
    this.selectedApprovalId = id;
    this.actionForm.reset();
    this.error = null;
  }

  approve(): void {
    if (!this.selectedApprovalId || this.actionForm.get('note')?.invalid) {
      this.error = 'Please fill required fields';
      return;
    }
    const { note } = this.actionForm.value;
    this.employerService.approveExpense(String(this.selectedApprovalId), { note: note || '' }).subscribe({
      next: () => {
        this.success = 'Approved successfully!';
        setTimeout(() => this.success = null, 3000);
        this.selectedApprovalId = null;
        this.actionForm.reset();
        this.loadApprovals();
      },
      error: () => {
        this.error = 'Failed to approve';
      }
    });
  }

  reject(): void {
    if (!this.selectedApprovalId || this.actionForm.invalid) {
      this.error = 'Please fill all required fields';
      return;
    }
    const { reason } = this.actionForm.value;
    if (!confirm('Are you sure you want to reject this expense?')) {
      return;
    }
    this.employerService.rejectExpense(String(this.selectedApprovalId), { reason }).subscribe({
      next: () => {
        this.success = 'Rejected successfully!';
        setTimeout(() => this.success = null, 3000);
        this.selectedApprovalId = null;
        this.actionForm.reset();
        this.loadApprovals();
      },
      error: () => {
        this.error = 'Failed to reject';
      }
    });
  }

  closeForm(): void {
    this.selectedApprovalId = null;
    this.actionForm.reset();
    this.error = null;
  }
}
