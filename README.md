# POS Benefits App

A Flutter mobile application for POS terminals in the Benefits Platform.

## Features

- **Terminal Authentication**: Secure terminal-based authentication
- **Payment Processing**: Support for credit cards, debit cards, contactless, and QR codes
- **Transaction History**: View recent transactions and status
- **Terminal Management**: Monitor terminal status and capabilities
- **Offline Support**: Basic offline transaction queuing

## Getting Started

1. **Prerequisites**
   - Flutter SDK (3.0.0+)
   - Android/iOS device with NFC support (for contactless payments)
   - Camera permissions (for QR code scanning)

2. **Installation**
   ```bash
   cd apps/app-pos-flutter
   flutter pub get
   flutter build apk  # or flutter build ios
   ```

3. **Running the App**
   ```bash
   flutter run
   ```

## Architecture

- **State Management**: Provider pattern
- **Navigation**: Go Router
- **Payment Processing**: Integration with payment orchestrator
- **NFC/Contactless**: nfc_manager package
- **QR Scanning**: qr_code_scanner package

## Screens

- **Login Screen**: Terminal authentication
- **POS Screen**: Main payment processing interface
- **Transaction History**: List of processed transactions
- **Settings**: Terminal configuration and information

## API Integration

The app integrates with the Benefits Platform backend services:
- Merchant Service (terminal management)
- Payment Orchestrator (transaction processing)
- Support Service (transaction logging)

## Configuration

Update the API base URL in `lib/services/pos_service.dart` to match your backend deployment.

## Permissions

Add these permissions to your AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />
```