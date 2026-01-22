# Benefits User App

A Flutter mobile application for employees to manage their benefits, submit expenses, and track reimbursements.

## Features

- **Authentication**: Secure login with JWT tokens
- **Benefits Management**: View available benefits and balances
- **Expense Submission**: Submit expense reports with receipts
- **Expense Tracking**: Monitor expense approval status
- **Profile Management**: View and manage user profile

## Getting Started

1. **Prerequisites**
   - Flutter SDK (3.0.0+)
   - Android Studio or VS Code with Flutter extensions
   - Android/iOS device or emulator

2. **Installation**
   ```bash
   cd apps/app-user-flutter
   flutter pub get
   ```

3. **Running the App**
   ```bash
   flutter run
   ```

## Architecture

- **State Management**: Provider pattern
- **Navigation**: Go Router
- **Networking**: HTTP package
- **Local Storage**: Shared Preferences
- **Authentication**: JWT tokens

## Screens

- **Login Screen**: User authentication
- **Home Screen**: Dashboard with wallet balance and quick actions
- **Benefits Screen**: List of available benefits
- **Expense Screen**: Submit new expenses and view expense history
- **Profile Screen**: User profile information

## API Integration

The app integrates with the Benefits Platform backend services:
- Identity Service (authentication)
- Support BFF (benefits and expenses)
- Payment Orchestrator (wallet operations)

## Configuration

Update the API base URL in `lib/services/` files to match your backend deployment.