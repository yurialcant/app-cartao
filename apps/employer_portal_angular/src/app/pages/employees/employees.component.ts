import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-employees',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="employees-page">
      <h1>Gestão de Colaboradores</h1>
      
      <div class="actions">
        <button (click)="openCreateModal()" class="btn-primary">Novo Colaborador</button>
        <button (click)="openImportModal()" class="btn-secondary">Importar CSV</button>
      </div>

      <div class="filters">
        <input type="text" placeholder="Buscar por nome..." [(ngModel)]="searchText" (ngModelChange)="filterEmployees()">
        <select [(ngModel)]="statusFilter" (ngModelChange)="filterEmployees()">
          <option value="">Todos os Status</option>
          <option value="ACTIVE">Ativo</option>
          <option value="INACTIVE">Inativo</option>
        </select>
      </div>

      <div *ngIf="loading" class="loading">Carregando colaboradores...</div>
      
      <div *ngIf="!loading && employees.length === 0" class="no-data">
        Nenhum colaborador encontrado
      </div>

      <table *ngIf="!loading && employees.length > 0" class="employees-table">
        <thead>
          <tr>
            <th>Nome</th>
            <th>Email</th>
            <th>Posição</th>
            <th>Departamento</th>
            <th>CPF</th>
            <th>Status</th>
            <th>Data Admissão</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let emp of filteredEmployees">
            <td>{{ emp.name }}</td>
            <td>{{ emp.email }}</td>
            <td>{{ emp.position }}</td>
            <td>{{ emp.departmentName }}</td>
            <td>{{ emp.cpf }}</td>
            <td><span [class]="'status-' + emp.status.toLowerCase()">{{ emp.status }}</span></td>
            <td>{{ emp.hire_date | date:'dd/MM/yyyy' }}</td>
            <td class="actions-col">
              <button (click)="editEmployee(emp)" class="btn-edit">Editar</button>
              <button (click)="deleteEmployee(emp.id)" class="btn-delete">Deletar</button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Modal Create/Edit -->
      <div *ngIf="showModal" class="modal-overlay" (click)="closeModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <h2>{{ editingEmployee ? 'Editar Colaborador' : 'Novo Colaborador' }}</h2>
          
          <form (ngSubmit)="saveEmployee()">
            <div class="form-group">
              <label>Nome *</label>
              <input type="text" [(ngModel)]="formData.name" name="name" required>
            </div>

            <div class="form-group">
              <label>Email *</label>
              <input type="email" [(ngModel)]="formData.email" name="email" required>
            </div>

            <div class="form-group">
              <label>CPF *</label>
              <input type="text" [(ngModel)]="formData.cpf" name="cpf" placeholder="123.456.789-00" required>
            </div>

            <div class="form-group">
              <label>Posição *</label>
              <input type="text" [(ngModel)]="formData.position" name="position" required>
            </div>

            <div class="form-group">
              <label>Departamento *</label>
              <select [(ngModel)]="formData.department_id" name="department_id" required>
                <option value="">Selecione...</option>
                <option *ngFor="let dept of departments" [value]="dept.id">{{ dept.name }}</option>
              </select>
            </div>

            <div class="form-group">
              <label>Status</label>
              <select [(ngModel)]="formData.status" name="status">
                <option value="ACTIVE">Ativo</option>
                <option value="INACTIVE">Inativo</option>
              </select>
            </div>

            <div class="modal-actions">
              <button type="submit" class="btn-primary">{{ editingEmployee ? 'Atualizar' : 'Criar' }}</button>
              <button type="button" (click)="closeModal()" class="btn-secondary">Cancelar</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Import Modal -->
      <div *ngIf="showImportModal" class="modal-overlay" (click)="closeImportModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <h2>Importar Colaboradores</h2>
          <p>Faça upload de um arquivo CSV com as colunas: nome, email, cpf, posição, departamento_id</p>
          
          <input type="file" accept=".csv" (change)="onFileSelected($event)">
          
          <div class="modal-actions">
            <button (click)="importCSV()" class="btn-primary" [disabled]="!selectedFile">Importar</button>
            <button (click)="closeImportModal()" class="btn-secondary">Cancelar</button>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .employees-page {
      padding: 2rem;
      background: #f5f5f5;
      min-height: 100vh;
    }

    h1 {
      color: #333;
      margin-bottom: 2rem;
    }

    .actions {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .btn-primary, .btn-secondary, .btn-edit, .btn-delete {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.3s ease;
    }

    .btn-primary {
      background: #667eea;
      color: white;
    }

    .btn-primary:hover {
      background: #5568d3;
    }

    .btn-secondary {
      background: #ccc;
      color: #333;
    }

    .btn-secondary:hover {
      background: #bbb;
    }

    .btn-edit {
      background: #4CAF50;
      color: white;
      padding: 0.5rem 1rem;
      font-size: 0.9rem;
    }

    .btn-delete {
      background: #f44336;
      color: white;
      padding: 0.5rem 1rem;
      font-size: 0.9rem;
    }

    .filters {
      display: flex;
      gap: 1rem;
      margin-bottom: 2rem;
    }

    .filters input, .filters select {
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      flex: 1;
      font-size: 1rem;
    }

    .loading, .no-data {
      text-align: center;
      padding: 2rem;
      color: #666;
      font-size: 1.1rem;
    }

    .employees-table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      border-radius: 4px;
      overflow: hidden;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .employees-table th {
      background: #667eea;
      color: white;
      padding: 1rem;
      text-align: left;
      font-weight: 600;
    }

    .employees-table td {
      padding: 1rem;
      border-bottom: 1px solid #eee;
    }

    .employees-table tr:hover {
      background: #f9f9f9;
    }

    .status-active {
      color: #4CAF50;
      font-weight: 600;
    }

    .status-inactive {
      color: #f44336;
      font-weight: 600;
    }

    .actions-col {
      display: flex;
      gap: 0.5rem;
    }

    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }

    .modal-content {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      max-width: 600px;
      width: 90%;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }

    .modal-content h2 {
      margin-bottom: 1.5rem;
      color: #333;
    }

    .form-group {
      margin-bottom: 1rem;
    }

    .form-group label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 600;
      color: #333;
    }

    .form-group input, .form-group select {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 1rem;
      box-sizing: border-box;
    }

    .modal-actions {
      display: flex;
      gap: 1rem;
      margin-top: 2rem;
    }

    .modal-actions button {
      flex: 1;
      padding: 0.75rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 600;
    }
  `]
})
export class EmployeesComponent implements OnInit {
  employees: any[] = [];
  filteredEmployees: any[] = [];
  departments: any[] = [];
  
  loading = false;
  showModal = false;
  showImportModal = false;
  editingEmployee: any = null;
  
  searchText = '';
  statusFilter = '';
  selectedFile: File | null = null;
  
  formData = {
    name: '',
    email: '',
    cpf: '',
    position: '',
    department_id: '',
    status: 'ACTIVE'
  };

  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    this.loadEmployees();
    this.loadDepartments();
  }
  
  loadEmployees() {
    this.loading = true;
    // Aqui viria a chamada real à API
    // this.apiService.getEmployees().subscribe(...)
    // Por enquanto usando dados mock:
    this.employees = [
      {
        id: 'emp-001',
        name: 'João Silva',
        email: 'joao.silva@company.com',
        cpf: '123.456.789-00',
        position: 'Desenvolvedor',
        departmentName: 'TI',
        department_id: 'dept-001',
        status: 'ACTIVE',
        hire_date: new Date('2022-01-15')
      },
      {
        id: 'emp-002',
        name: 'Maria Santos',
        email: 'maria.santos@company.com',
        cpf: '987.654.321-00',
        position: 'Desenvolvedora Senior',
        departmentName: 'TI',
        department_id: 'dept-001',
        status: 'ACTIVE',
        hire_date: new Date('2021-06-20')
      },
      {
        id: 'emp-003',
        name: 'Carlos Oliveira',
        email: 'carlos.oliveira@company.com',
        cpf: '111.222.333-44',
        position: 'Gerente RH',
        departmentName: 'RH',
        department_id: 'dept-002',
        status: 'ACTIVE',
        hire_date: new Date('2023-03-10')
      }
    ];
    this.filteredEmployees = [...this.employees];
    this.loading = false;
  }
  
  loadDepartments() {
    // Dados mock de departamentos
    this.departments = [
      { id: 'dept-001', name: 'TI' },
      { id: 'dept-002', name: 'RH' },
      { id: 'dept-003', name: 'Financeiro' },
      { id: 'dept-004', name: 'Vendas' }
    ];
  }
  
  filterEmployees() {
    this.filteredEmployees = this.employees.filter(emp => {
      const matchesSearch = emp.name.toLowerCase().includes(this.searchText.toLowerCase()) ||
                           emp.email.toLowerCase().includes(this.searchText.toLowerCase());
      const matchesStatus = !this.statusFilter || emp.status === this.statusFilter;
      return matchesSearch && matchesStatus;
    });
  }
  
  openCreateModal() {
    this.editingEmployee = null;
    this.formData = { name: '', email: '', cpf: '', position: '', department_id: '', status: 'ACTIVE' };
    this.showModal = true;
  }
  
  editEmployee(emp: any) {
    this.editingEmployee = emp;
    this.formData = { ...emp };
    this.showModal = true;
  }
  
  closeModal() {
    this.showModal = false;
    this.editingEmployee = null;
    this.formData = { name: '', email: '', cpf: '', position: '', department_id: '', status: 'ACTIVE' };
  }
  
  saveEmployee() {
    if (!this.formData.name || !this.formData.email || !this.formData.cpf || !this.formData.position || !this.formData.department_id) {
      alert('Por favor, preencha todos os campos obrigatórios');
      return;
    }

    if (this.editingEmployee) {
      // Atualizar
      const index = this.employees.findIndex(e => e.id === this.editingEmployee.id);
      if (index !== -1) {
        this.employees[index] = { ...this.employees[index], ...this.formData };
      }
      alert('Colaborador atualizado com sucesso!');
    } else {
      // Criar
      const newEmployee = {
        id: 'emp-' + Date.now(),
        ...this.formData,
        hire_date: new Date()
      };
      this.employees.push(newEmployee);
      alert('Colaborador criado com sucesso!');
    }

    this.filteredEmployees = [...this.employees];
    this.closeModal();
  }
  
  deleteEmployee(id: string) {
    if (confirm('Tem certeza que deseja deletar este colaborador?')) {
      this.employees = this.employees.filter(e => e.id !== id);
      this.filteredEmployees = [...this.employees];
      alert('Colaborador deletado com sucesso!');
    }
  }
  
  openImportModal() {
    this.showImportModal = true;
  }
  
  closeImportModal() {
    this.showImportModal = false;
    this.selectedFile = null;
  }
  
  onFileSelected(event: any) {
    this.selectedFile = event.target.files[0];
  }
  
  importCSV() {
    if (!this.selectedFile) return;
    
    const reader = new FileReader();
    reader.onload = (e: any) => {
      const csv = e.target.result;
      const lines = csv.split('\n').filter((line: string) => line.trim());
      
      lines.forEach((line: string, index: number) => {
        if (index === 0) return; // Skip header
        const [name, email, cpf, position, department_id] = line.split(',').map((s: string) => s.trim());
        
        if (name && email) {
          const newEmployee = {
            id: 'emp-' + Date.now() + index,
            name,
            email,
            cpf,
            position,
            department_id,
            status: 'ACTIVE',
            departmentName: this.departments.find(d => d.id === department_id)?.name || department_id,
            hire_date: new Date()
          };
          this.employees.push(newEmployee);
        }
      });
      
      this.filteredEmployees = [...this.employees];
      alert(`${lines.length - 1} colaboradores importados com sucesso!`);
      this.closeImportModal();
    };
    reader.readAsText(this.selectedFile);
  }

  createEmployee() {
    // TODO: Abrir modal/form para criar colaborador
  }
}
