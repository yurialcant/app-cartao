import { Component, OnInit } from '@angular/core';
import { MerchantService } from '../../services/merchant.service';

@Component({
  selector: 'app-merchant-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  sales: any = {};
  operators: any = {};
  loading = true;

  constructor(private merchantService: MerchantService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.merchantService.getSalesDashboard().subscribe({
      next: (s) => {
        this.sales = s;
        this.merchantService.getOperatorsDashboard().subscribe({
          next: (o) => {
            this.operators = o;
            this.loading = false;
          },
          error: () => (this.loading = false)
        });
      },
      error: () => (this.loading = false)
    });
  }
}
