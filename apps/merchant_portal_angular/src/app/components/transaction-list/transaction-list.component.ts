import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MerchantService } from '../../services/merchant.service';
import { Transaction, TransactionFilter } from '../../models/transaction';

@Component({
  selector: 'app-transaction-list',
  templateUrl: './transaction-list.component.html',
  styleUrls: ['./transaction-list.component.css']
})
export class TransactionListComponent implements OnInit {
  transactions: Transaction[] = [];
  loading = true;
  filterForm: FormGroup;
  error: string | null = null;
  page = 1;
  pageSize = 10;
  total = 0;

  statusOptions = ['PENDING', 'COMPLETED', 'FAILED', 'CANCELLED'];

  constructor(private merchantService: MerchantService, private fb: FormBuilder) {
    this.filterForm = this.fb.group({
      status: [''],
      from: ['', Validators.pattern(/^\d{4}-\d{2}-\d{2}$|^$/)],
      to: ['', Validators.pattern(/^\d{4}-\d{2}-\d{2}$|^$/)],
      pageSize: [10, [Validators.required, Validators.min(5), Validators.max(100)]]
    });
  }

  ngOnInit(): void {
    this.load();
    this.filterForm.valueChanges.subscribe(() => {
      this.page = 1; // Reset pagination when filter changes
      this.load();
    });
  }

  buildFilter(): TransactionFilter {
    const { status, from, to, pageSize } = this.filterForm.value;
    this.pageSize = pageSize;
    return {
      status: status || undefined,
      from: from || undefined,
      to: to || undefined,
      page: this.page,
      pageSize: this.pageSize,
    };
  }

  load(): void {
    this.loading = true;
    this.error = null;
    const filter = this.buildFilter();
    this.merchantService.getTransactions(filter).subscribe({
      next: (resp) => {
        this.transactions = resp.data;
        this.total = resp.data?.length ?? 0;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load transactions';
        this.loading = false;
      }
    });
  }

  onPageChange(delta: number): void {
    const next = this.page + delta;
    if (next < 1) return;
    this.page = next;
    this.load();
  }

  resetFilters(): void {
    this.filterForm.reset({ pageSize: 10 });
    this.page = 1;
  }

  exportCSV(): void {
    const csv = this.transactions.map(t => 
      `${t.id},${t.amount},${t.status},${t.timestamp}`
    ).join('\n');
    const element = document.createElement('a');
    element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv));
    element.setAttribute('download', 'transactions.csv');
    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  }
}
