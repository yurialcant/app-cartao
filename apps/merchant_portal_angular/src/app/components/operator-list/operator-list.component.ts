import { Component, OnInit } from '@angular/core';
import { MerchantService } from '../../services/merchant.service';

@Component({
  selector: 'app-operator-list',
  templateUrl: './operator-list.component.html',
  styleUrls: ['./operator-list.component.css']
})
export class OperatorListComponent implements OnInit {
  operators: any[] = [];
  loading = true;

  constructor(private merchantService: MerchantService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.merchantService.getOperators().subscribe({
      next: (ops) => {
        this.operators = ops;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }
}
