import { Component } from '@angular/core';

@Component({
  selector: 'app-reports',
  templateUrl: './reports.component.html',
  styleUrls: ['./reports.component.css']
})
export class ReportsComponent {
  // TODO: Implement export logic integrated with reconciliation-service reports
  export(format: string) {
    console.log('Export report as', format);
  }
}
