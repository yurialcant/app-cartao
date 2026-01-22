import { Component, OnInit } from '@angular/core';
import { RouterOutlet, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.component.html',
  styles: [`
    .app-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }

    .main-content {
      flex: 1;
      padding: 0;
    }

    .navbar-nav .nav-link.active {
      font-weight: bold;
    }
  `]
})
export class AppComponent implements OnInit {
  title = 'Employer Portal';

  constructor(private authService: AuthService, private router: Router) {}

  ngOnInit() {
    // Check if user is logged in on app start
    if (!this.isLoggedIn()) {
      this.router.navigate(['/login']);
    }
  }

  isLoggedIn(): boolean {
    return this.authService.isLoggedIn();
  }

  logout() {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
