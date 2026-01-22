import { Component, OnInit } from '@angular/core';
import { MerchantService } from '../../services/merchant.service';

@Component({
  selector: 'app-terminal-list',
  templateUrl: './terminal-list.component.html',
  styleUrls: ['./terminal-list.component.css']
})
export class TerminalListComponent implements OnInit {
  terminals: any[] = [];
  loading = true;

  constructor(private merchantService: MerchantService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.merchantService.getTerminals().subscribe({
      next: (t) => {
        this.terminals = t;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }
}
