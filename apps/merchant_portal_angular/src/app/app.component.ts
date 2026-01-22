import { Component } from '@angular/core';
import { RouterOutlet, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { LayoutComponent } from './components/layout/layout.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, RouterModule, LayoutComponent],
  template: `
    <div class="app-container">
      <app-layout>
        <router-outlet></router-outlet>
      </app-layout>
    </div>
  `,
  styles: [`
    .app-container {
      width: 100%;
      height: 100vh;
    }
  `]
})
export class AppComponent {
  title = 'Merchant Portal - Benefits Platform';
}
