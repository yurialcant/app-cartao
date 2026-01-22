import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <div class="layout">
      <nav class="sidebar">
        <div class="logo">
          <h2>Admin</h2>
        </div>
        <ul>
          <li><a routerLink="/dashboard" routerLinkActive="active">Dashboard</a></li>
          <li><a routerLink="/users" routerLinkActive="active">Usuários</a></li>
          <li><a routerLink="/merchants" routerLinkActive="active">Merchants</a></li>
          <li><a routerLink="/topups" routerLinkActive="active">Top-ups</a></li>
          <li><a routerLink="/reconciliation" routerLinkActive="active">Conciliação</a></li>
          <li><a routerLink="/disputes" routerLinkActive="active">Disputas</a></li>
          <li><a routerLink="/risk" routerLinkActive="active">Risco</a></li>
          <li><a routerLink="/support" routerLinkActive="active">Suporte</a></li>
          <li><a routerLink="/audit" routerLinkActive="active">Auditoria</a></li>
        </ul>
      </nav>
      <main class="content">
        <ng-content></ng-content>
      </main>
    </div>
  `,
  styles: [`
    .layout {
      display: flex;
      height: 100vh;
    }
    .sidebar {
      width: 220px;
      background: linear-gradient(135deg, #1a237e 0%, #3949ab 100%);
      padding: 20px;
      color: white;
    }
    .logo h2 {
      margin: 0 0 30px 0;
      padding-bottom: 15px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
    }
    .sidebar ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    .sidebar li {
      margin: 5px 0;
    }
    .sidebar a {
      text-decoration: none;
      color: rgba(255,255,255,0.8);
      display: block;
      padding: 10px 15px;
      border-radius: 8px;
      transition: all 0.2s;
    }
    .sidebar a:hover, .sidebar a.active {
      background: rgba(255,255,255,0.15);
      color: white;
    }
    .content {
      flex: 1;
      padding: 30px;
      overflow-y: auto;
      background: #f5f5f5;
    }
  `]
})
export class LayoutComponent {}
