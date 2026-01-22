import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-access-denied',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="container d-flex flex-column align-items-center justify-content-center min-vh-100">
      <div class="text-center">
        <i class="bi bi-shield-x display-1 text-danger mb-4"></i>
        <h1 class="h2 mb-3">Acesso Negado</h1>
        <p class="text-muted mb-4">
          Você não tem permissão para acessar esta página.
          <br>
          Entre em contato com o administrador se acredita que isso é um erro.
        </p>
        <div class="d-flex gap-2 justify-content-center">
          <a routerLink="/dashboard" class="btn btn-primary">
            <i class="bi bi-house me-2"></i>Ir para Dashboard
          </a>
          <a routerLink="/login" class="btn btn-outline-secondary">
            <i class="bi bi-box-arrow-left me-2"></i>Fazer Login
          </a>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .min-vh-100 {
      min-height: 100vh;
    }
    .display-1 {
      font-size: 5rem;
    }
  `]
})
export class AccessDeniedComponent {}
