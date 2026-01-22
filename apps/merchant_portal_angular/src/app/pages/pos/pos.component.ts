import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-pos',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="pos-page">
      <h1>🛒 Terminal de Ponto de Venda (POS)</h1>
      
      <div class="pos-container">
        <!-- Painel de Itens -->
        <div class="items-panel">
          <h2>Produtos</h2>
          
          <div class="search-box">
            <input type="text" placeholder="Código/Nome do produto..." [(ngModel)]="productSearch" (ngModelChange)="filterProducts()">
          </div>

          <div class="products-list">
            <div *ngFor="let product of filteredProducts" class="product-card" (click)="addToCart(product)">
              <div class="product-name">{{ product.name }}</div>
              <div class="product-price">{{ product.price | currency:'BRL' }}</div>
              <button class="btn-add">+ Adicionar</button>
            </div>
          </div>
        </div>

        <!-- Painel de Carrinho -->
        <div class="cart-panel">
          <h2>Carrinho</h2>
          
          <div *ngIf="cartItems.length === 0" class="empty-cart">
            <p>Carrinho vazio</p>
          </div>

          <div *ngIf="cartItems.length > 0" class="cart-items">
            <table class="cart-table">
              <thead>
                <tr>
                  <th>Produto</th>
                  <th>Qtd</th>
                  <th>Preço Unit</th>
                  <th>Subtotal</th>
                  <th>Ação</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let item of cartItems">
                  <td>{{ item.name }}</td>
                  <td>
                    <input type="number" [(ngModel)]="item.quantity" (ngModelChange)="updateCart()" min="1">
                  </td>
                  <td>{{ item.price | currency:'BRL' }}</td>
                  <td>{{ (item.price * item.quantity) | currency:'BRL' }}</td>
                  <td>
                    <button (click)="removeFromCart(item.id)" class="btn-remove">🗑️</button>
                  </td>
                </tr>
              </tbody>
            </table>

            <div class="cart-totals">
              <div class="total-row">
                <span>Subtotal:</span>
                <span>{{ subtotal | currency:'BRL' }}</span>
              </div>
              <div class="total-row">
                <span>Desconto:</span>
                <input type="number" [(ngModel)]="discount" (ngModelChange)="updateCart()" min="0" max="100" class="discount-input">%
              </div>
              <div class="total-row total">
                <span>Total:</span>
                <span>{{ total | currency:'BRL' }}</span>
              </div>
            </div>

            <div class="payment-section">
              <h3>Forma de Pagamento</h3>
              <div class="payment-options">
                <button 
                  *ngFor="let method of paymentMethods" 
                  [class.selected]="selectedPaymentMethod === method"
                  (click)="selectPaymentMethod(method)"
                  class="payment-btn">
                  {{ method }}
                </button>
              </div>
            </div>

            <div class="action-buttons">
              <button (click)="processPayment()" class="btn-pay">Processar Pagamento</button>
              <button (click)="clearCart()" class="btn-cancel">Cancelar</button>
            </div>
          </div>
        </div>
      </div>

      <!-- Payment Modal -->
      <div *ngIf="showPaymentModal" class="modal-overlay" (click)="closePaymentModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <h2>Confirmar Pagamento</h2>
          
          <div class="payment-summary">
            <div class="summary-row">
              <span>Valor Total:</span>
              <span class="amount">{{ total | currency:'BRL' }}</span>
            </div>
            <div class="summary-row">
              <span>Forma de Pagamento:</span>
              <span>{{ selectedPaymentMethod }}</span>
            </div>
            <div class="summary-row">
              <span>Itens:</span>
              <span>{{ cartItems.length }}</span>
            </div>
          </div>

          <div *ngIf="showQRCode" class="qr-code-section">
            <p>Escaneie o QR Code para pagar:</p>
            <div class="qr-placeholder">
              [QR CODE - 123456789]
            </div>
          </div>

          <div class="modal-actions">
            <button (click)="confirmPayment()" class="btn-confirm" [disabled]="processing">
              {{ processing ? 'Processando...' : 'Confirmar' }}
            </button>
            <button (click)="closePaymentModal()" class="btn-cancel" [disabled]="processing">Cancelar</button>
          </div>
        </div>
      </div>

      <!-- Success Modal -->
      <div *ngIf="showSuccessModal" class="modal-overlay" (click)="closeSuccessModal()">
        <div class="modal-content success">
          <h2>✅ Pagamento Realizado com Sucesso!</h2>
          
          <div class="success-details">
            <div class="detail-row">
              <span>ID da Transação:</span>
              <span class="tx-id">{{ lastTransactionId }}</span>
            </div>
            <div class="detail-row">
              <span>Valor:</span>
              <span>{{ total | currency:'BRL' }}</span>
            </div>
            <div class="detail-row">
              <span>Hora:</span>
              <span>{{ lastTransactionTime | date:'HH:mm:ss' }}</span>
            </div>
          </div>

          <button (click)="newTransaction()" class="btn-new">Nova Transação</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .pos-page {
      padding: 2rem;
      background: #f5f5f5;
      min-height: 100vh;
    }

    h1 {
      color: #333;
      margin-bottom: 1.5rem;
    }

    .pos-container {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 2rem;
      max-width: 1400px;
      margin: 0 auto;
    }

    @media (max-width: 1024px) {
      .pos-container {
        grid-template-columns: 1fr;
      }
    }

    .items-panel, .cart-panel {
      background: white;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    h2 {
      color: #333;
      margin-top: 0;
      margin-bottom: 1.5rem;
      font-size: 1.3rem;
    }

    .search-box {
      margin-bottom: 1rem;
    }

    .search-box input {
      width: 100%;
      padding: 0.75rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 1rem;
    }

    .products-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
      gap: 1rem;
      max-height: 500px;
      overflow-y: auto;
    }

    .product-card {
      background: #f9f9f9;
      border: 2px solid #e0e0e0;
      border-radius: 4px;
      padding: 1rem;
      cursor: pointer;
      transition: all 0.3s ease;
      text-align: center;
    }

    .product-card:hover {
      border-color: #667eea;
      box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
    }

    .product-name {
      font-weight: 600;
      color: #333;
      margin-bottom: 0.5rem;
      font-size: 0.9rem;
      word-break: break-word;
    }

    .product-price {
      color: #667eea;
      font-weight: bold;
      margin-bottom: 0.75rem;
      font-size: 1.1rem;
    }

    .btn-add {
      width: 100%;
      padding: 0.5rem;
      background: #4CAF50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 0.85rem;
      font-weight: 600;
    }

    .btn-add:hover {
      background: #45a049;
    }

    .empty-cart {
      text-align: center;
      padding: 2rem;
      color: #999;
      font-size: 1.1rem;
    }

    .cart-table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 1.5rem;
    }

    .cart-table th {
      background: #f0f0f0;
      padding: 0.75rem;
      text-align: left;
      font-weight: 600;
      border-bottom: 2px solid #ddd;
    }

    .cart-table td {
      padding: 0.75rem;
      border-bottom: 1px solid #eee;
    }

    .cart-table input {
      width: 60px;
      padding: 0.5rem;
      border: 1px solid #ddd;
      border-radius: 4px;
      text-align: center;
    }

    .btn-remove {
      background: none;
      border: none;
      cursor: pointer;
      font-size: 1.2rem;
    }

    .cart-totals {
      background: #f9f9f9;
      padding: 1rem;
      border-radius: 4px;
      margin-bottom: 1.5rem;
    }

    .total-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 0.75rem;
      font-size: 0.95rem;
    }

    .total-row.total {
      font-size: 1.2rem;
      font-weight: bold;
      color: #667eea;
      border-top: 2px solid #ddd;
      padding-top: 0.75rem;
    }

    .discount-input {
      width: 80px;
      padding: 0.25rem;
      border: 1px solid #ddd;
      border-radius: 4px;
    }

    .payment-section {
      margin-bottom: 1.5rem;
    }

    .payment-section h3 {
      color: #333;
      margin-bottom: 1rem;
      font-size: 1rem;
    }

    .payment-options {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      gap: 0.75rem;
    }

    .payment-btn {
      padding: 0.75rem;
      border: 2px solid #ddd;
      background: white;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 600;
      transition: all 0.3s ease;
    }

    .payment-btn:hover {
      border-color: #667eea;
    }

    .payment-btn.selected {
      background: #667eea;
      color: white;
      border-color: #667eea;
    }

    .action-buttons {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 1rem;
    }

    .btn-pay {
      padding: 1rem;
      background: #4CAF50;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 1.1rem;
      font-weight: bold;
      cursor: pointer;
    }

    .btn-pay:hover {
      background: #45a049;
    }

    .btn-cancel {
      padding: 1rem;
      background: #999;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 1.1rem;
      font-weight: bold;
      cursor: pointer;
    }

    .btn-cancel:hover {
      background: #777;
    }

    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.6);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }

    .modal-content {
      background: white;
      padding: 2rem;
      border-radius: 8px;
      max-width: 500px;
      width: 90%;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .modal-content h2 {
      margin-top: 0;
      color: #333;
      margin-bottom: 1.5rem;
    }

    .modal-content.success {
      text-align: center;
    }

    .payment-summary {
      background: #f9f9f9;
      padding: 1.5rem;
      border-radius: 4px;
      margin-bottom: 1.5rem;
    }

    .summary-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 1rem;
      font-size: 1rem;
    }

    .summary-row .amount {
      font-weight: bold;
      color: #4CAF50;
      font-size: 1.3rem;
    }

    .qr-code-section {
      background: #f9f9f9;
      padding: 2rem;
      border-radius: 4px;
      margin-bottom: 1.5rem;
    }

    .qr-placeholder {
      background: white;
      border: 2px dashed #ddd;
      padding: 2rem;
      text-align: center;
      border-radius: 4px;
      margin-top: 1rem;
      font-family: monospace;
      color: #999;
    }

    .modal-actions {
      display: flex;
      gap: 1rem;
      margin-top: 1.5rem;
    }

    .btn-confirm, .modal-content .btn-cancel {
      flex: 1;
      padding: 0.75rem;
      border: none;
      border-radius: 4px;
      font-weight: 600;
      cursor: pointer;
      font-size: 1rem;
    }

    .btn-confirm {
      background: #4CAF50;
      color: white;
    }

    .btn-confirm:hover:not(:disabled) {
      background: #45a049;
    }

    .btn-confirm:disabled {
      background: #ccc;
      cursor: not-allowed;
    }

    .modal-content .btn-cancel {
      background: #999;
      color: white;
    }

    .modal-content .btn-cancel:hover:not(:disabled) {
      background: #777;
    }

    .success-details {
      background: #f0f8f4;
      padding: 1.5rem;
      border-radius: 4px;
      margin-bottom: 1.5rem;
      border-left: 4px solid #4CAF50;
    }

    .detail-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 0.75rem;
      font-size: 1rem;
    }

    .tx-id {
      font-family: monospace;
      color: #667eea;
      font-weight: 600;
    }

    .btn-new {
      width: 100%;
      padding: 1rem;
      background: #667eea;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 1rem;
      font-weight: bold;
      cursor: pointer;
    }

    .btn-new:hover {
      background: #5568d3;
    }
  `]
})
export class PosComponent implements OnInit {
  cartItems: any[] = [];
  products: any[] = [];
  filteredProducts: any[] = [];
  
  productSearch = '';
  discount = 0;
  selectedPaymentMethod = '';
  paymentMethods = ['VR', 'VA', 'FLEX', 'Débito', 'Crédito'];
  
  showPaymentModal = false;
  showSuccessModal = false;
  showQRCode = false;
  processing = false;
  
  subtotal = 0;
  total = 0;
  
  lastTransactionId = '';
  lastTransactionTime = new Date();

  constructor(private apiService: ApiService) {}
  
  ngOnInit() {
    this.loadProducts();
  }
  
  loadProducts() {
    // Mock data de produtos
    this.products = [
      { id: 'prod-001', name: 'Água Mineral', price: 2.50 },
      { id: 'prod-002', name: 'Suco Natural', price: 5.90 },
      { id: 'prod-003', name: 'Refrigerante', price: 4.50 },
      { id: 'prod-004', name: 'Sanduíche', price: 12.00 },
      { id: 'prod-005', name: 'Salada', price: 15.90 },
      { id: 'prod-006', name: 'Prato Quente', price: 28.00 },
      { id: 'prod-007', name: 'Doce', price: 8.50 },
      { id: 'prod-008', name: 'Café', price: 3.00 },
      { id: 'prod-009', name: 'Almoço Executivo', price: 35.00 },
      { id: 'prod-010', name: 'Sobremesa', price: 10.00 }
    ];
    this.filteredProducts = [...this.products];
  }
  
  filterProducts() {
    this.filteredProducts = this.products.filter(p =>
      p.name.toLowerCase().includes(this.productSearch.toLowerCase()) ||
      p.id.toLowerCase().includes(this.productSearch.toLowerCase())
    );
  }
  
  addToCart(product: any) {
    const existing = this.cartItems.find(item => item.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      this.cartItems.push({ ...product, quantity: 1 });
    }
    this.updateCart();
  }
  
  removeFromCart(productId: string) {
    this.cartItems = this.cartItems.filter(item => item.id !== productId);
    this.updateCart();
  }
  
  updateCart() {
    this.subtotal = this.cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const discountAmount = this.subtotal * (this.discount / 100);
    this.total = this.subtotal - discountAmount;
  }
  
  clearCart() {
    this.cartItems = [];
    this.discount = 0;
    this.selectedPaymentMethod = '';
    this.updateCart();
  }
  
  selectPaymentMethod(method: string) {
    this.selectedPaymentMethod = method;
    this.showQRCode = ['VR', 'VA', 'FLEX'].includes(method);
  }
  
  processPayment() {
    if (!this.selectedPaymentMethod) {
      alert('Selecione uma forma de pagamento!');
      return;
    }
    
    if (this.total <= 0) {
      alert('O carrinho está vazio!');
      return;
    }
    
    this.showPaymentModal = true;
  }
  
  confirmPayment() {
    this.processing = true;
    
    // Simular processamento de pagamento
    setTimeout(() => {
      this.lastTransactionId = 'txn-' + Math.random().toString(36).substr(2, 9).toUpperCase();
      this.lastTransactionTime = new Date();
      
      this.showPaymentModal = false;
      this.showSuccessModal = true;
      this.processing = false;
    }, 2000);
  }
  
  closePaymentModal() {
    if (!this.processing) {
      this.showPaymentModal = false;
    }
  }
  
  closeSuccessModal() {
    this.showSuccessModal = false;
  }
  
  newTransaction() {
    this.clearCart();
    this.showSuccessModal = false;
  }
}
