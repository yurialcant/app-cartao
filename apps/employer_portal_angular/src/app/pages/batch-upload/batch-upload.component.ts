import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-batch-upload',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="batch-upload-page">
      <h1>Upload de Lote de Créditos</h1>

      <div class="upload-section" *ngIf="!uploadResult">
        <div class="file-upload">
          <label for="fileInput">Selecione o arquivo CSV:</label>
          <input type="file" id="fileInput" accept=".csv" (change)="onFileSelected($event)" #fileInput>
          <p class="file-info" *ngIf="selectedFile">{{ selectedFile.name }} ({{ selectedFile.size }} bytes)</p>
        </div>

        <div class="preview-section" *ngIf="csvData.length > 0">
          <h3>Pré-visualização dos Dados</h3>
          <div class="table-container">
            <table class="preview-table">
              <thead>
                <tr>
                  <th *ngFor="let header of csvHeaders">{{ header }}</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let row of csvData.slice(0, 5)">
                  <td *ngFor="let header of csvHeaders">{{ row[header] }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p class="preview-info">Mostrando primeiras 5 linhas de {{ csvData.length }} registros</p>
        </div>

        <div class="actions">
          <button (click)="processBatch()" [disabled]="!selectedFile || processing" class="primary-btn">
            {{ processing ? 'Processando...' : 'Processar Lote' }}
          </button>
          <button (click)="clearFile()" [disabled]="processing" class="secondary-btn">
            Limpar
          </button>
        </div>
      </div>

      <div class="result-section" *ngIf="uploadResult">
        <h2>Resultado do Upload</h2>

        <div class="result-summary" [ngClass]="uploadResult.status">
          <h3>{{ uploadResult.status === 'success' ? '✅ Sucesso' : '❌ Erro' }}</h3>
          <p>{{ uploadResult.message }}</p>
        </div>

        <div class="batch-details" *ngIf="uploadResult.batch">
          <h4>Detalhes do Lote</h4>
          <div class="details-grid">
            <div class="detail-item">
              <label>ID do Lote:</label>
              <span>{{ uploadResult.batch.batch_id }}</span>
            </div>
            <div class="detail-item">
              <label>Status:</label>
              <span>{{ uploadResult.batch.status }}</span>
            </div>
            <div class="detail-item">
              <label>Total de Itens:</label>
              <span>{{ uploadResult.batch.total_items }}</span>
            </div>
            <div class="detail-item">
              <label>Sucessos:</label>
              <span>{{ uploadResult.batch.items_succeeded || 0 }}</span>
            </div>
            <div class="detail-item">
              <label>Falhas:</label>
              <span>{{ uploadResult.batch.items_failed || 0 }}</span>
            </div>
          </div>
        </div>

        <div class="actions">
          <button (click)="resetUpload()" class="primary-btn">Novo Upload</button>
          <button (click)="viewBatchDetails()" *ngIf="uploadResult.batch" class="secondary-btn">
            Ver Detalhes
          </button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .batch-upload-page {
      padding: 2rem;
      max-width: 1200px;
      margin: 0 auto;
    }

    .upload-section, .result-section {
      background: white;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .file-upload {
      margin-bottom: 2rem;
    }

    .file-upload label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 500;
    }

    .file-upload input[type="file"] {
      padding: 0.5rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      width: 100%;
    }

    .file-info {
      margin-top: 0.5rem;
      color: #666;
      font-size: 0.9rem;
    }

    .preview-section {
      margin: 2rem 0;
    }

    .preview-info {
      margin-top: 1rem;
      color: #666;
      font-style: italic;
    }

    .table-container {
      max-height: 300px;
      overflow-y: auto;
      border: 1px solid #ddd;
      border-radius: 4px;
    }

    .preview-table {
      width: 100%;
      border-collapse: collapse;
    }

    .preview-table th,
    .preview-table td {
      padding: 0.5rem;
      text-align: left;
      border-bottom: 1px solid #ddd;
    }

    .preview-table th {
      background: #f5f5f5;
      font-weight: 600;
      position: sticky;
      top: 0;
    }

    .actions {
      margin-top: 2rem;
      display: flex;
      gap: 1rem;
    }

    .primary-btn, .secondary-btn {
      padding: 0.75rem 1.5rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
      transition: background-color 0.2s;
    }

    .primary-btn {
      background: #667eea;
      color: white;
    }

    .primary-btn:hover:not(:disabled) {
      background: #5a67d8;
    }

    .primary-btn:disabled {
      background: #ccc;
      cursor: not-allowed;
    }

    .secondary-btn {
      background: #e2e8f0;
      color: #4a5568;
    }

    .secondary-btn:hover:not(:disabled) {
      background: #cbd5e0;
    }

    .result-summary {
      padding: 1rem;
      border-radius: 4px;
      margin-bottom: 2rem;
    }

    .result-summary.success {
      background: #d4edda;
      border: 1px solid #c3e6cb;
      color: #155724;
    }

    .result-summary.error {
      background: #f8d7da;
      border: 1px solid #f5c6cb;
      color: #721c24;
    }

    .batch-details {
      margin-bottom: 2rem;
    }

    .details-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1rem;
      margin-top: 1rem;
    }

    .detail-item {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
    }

    .detail-item label {
      font-weight: 500;
      color: #666;
      font-size: 0.9rem;
    }

    .detail-item span {
      font-weight: 600;
    }
  `]
})
export class BatchUploadComponent implements OnInit {
  selectedFile: File | null = null;
  csvData: any[] = [];
  csvHeaders: string[] = [];
  processing = false;
  uploadResult: any = null;

  constructor(private apiService: ApiService) {}

  ngOnInit() {}

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      this.parseCSV(file);
    }
  }

  parseCSV(file: File) {
    const reader = new FileReader();
    reader.onload = (e) => {
      const csv = e.target?.result as string;
      const lines = csv.split('\n').filter(line => line.trim());

      if (lines.length > 0) {
        // First line is headers
        this.csvHeaders = lines[0].split(',').map(h => h.trim().replace(/"/g, ''));

        // Parse data rows
        this.csvData = lines.slice(1).map(line => {
          const values = line.split(',').map(v => v.trim().replace(/"/g, ''));
          const row: any = {};
          this.csvHeaders.forEach((header, index) => {
            row[header] = values[index] || '';
          });
          return row;
        });
      }
    };
    reader.readAsText(file);
  }

  processBatch() {
    if (!this.selectedFile || this.processing) return;

    this.processing = true;

    // Convert CSV data to batch format expected by API
    const batchItems = this.csvData.map(row => ({
      person_id: row.person_id || row.personId,
      wallet_id: row.wallet_id || row.walletId,
      amount: parseFloat(row.amount),
      description: row.description || `Batch credit upload`
    }));

    const batchRequest = {
      items: batchItems
    };

    // Use employer BFF endpoint
    this.apiService.createBatchCredit(batchRequest).subscribe({
      next: (result) => {
        this.processing = false;
        this.uploadResult = {
          status: 'success',
          message: 'Lote processado com sucesso!',
          batch: result
        };
      },
      error: (error) => {
        this.processing = false;
        this.uploadResult = {
          status: 'error',
          message: `Erro no processamento: ${error.error?.message || error.message}`,
          batch: null
        };
      }
    });
  }

  clearFile() {
    this.selectedFile = null;
    this.csvData = [];
    this.csvHeaders = [];
    const fileInput = document.getElementById('fileInput') as HTMLInputElement;
    if (fileInput) {
      fileInput.value = '';
    }
  }

  resetUpload() {
    this.clearFile();
    this.uploadResult = null;
  }

  viewBatchDetails() {
    if (this.uploadResult?.batch?.batch_id) {
      // Navigate to batch details page (would need routing implementation)
      console.log('Navigate to batch details:', this.uploadResult.batch.batch_id);
    }
  }
}