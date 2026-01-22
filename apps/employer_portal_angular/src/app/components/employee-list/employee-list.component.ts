import { Component, OnInit } from '@angular/core';
import { EmployerService } from '../../services/employer.service';

@Component({
  selector: 'app-employee-list',
  templateUrl: './employee-list.component.html',
  styleUrls: ['./employee-list.component.css']
})
export class EmployeeListComponent implements OnInit {
  employees: any[] = [];
  loading = true;

  constructor(private employerService: EmployerService) {}

  ngOnInit(): void {
    this.loadEmployees();
  }

  loadEmployees(): void {
    this.employerService.getEmployees().subscribe({
      next: (employees) => {
        this.employees = employees;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading employees:', err);
        this.loading = false;
      }
    });
  }

  viewEmployee(id: number): void {
    // TODO: Navigate to employee details
  }

  editEmployee(id: number): void {
    // TODO: Navigate to edit form
  }
}
