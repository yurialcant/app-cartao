#!/usr/bin/env python3
"""
Mock User BFF Server for End-to-End Testing
Simulates complete user API for benefits platform testing
"""

import json
import uuid
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse

class MockUserBFFHandler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'  # Use HTTP/1.1 instead of default HTTP/1.0

    # Mock data as class variables
    mock_user = {
        "id": "user-1",
        "username": "tiago.tiede@flash.com",
        "name": "Tiago Tiede",
        "email": "tiago.tiede@flash.com",
        "document": "***.***.***-12",
        "phone": "+55 11 99999-9999",
        "status": "ACTIVE",
        "createdAt": "2024-01-15T10:30:00Z",
        "tenantId": "tenant-1"
    }

    mock_wallet_summary = {
        "balance": 750.50,
        "availableBalance": 750.50,
        "blockedBalance": 0.00,
        "wallets": [
            {
                "id": "wallet-vr",
                "type": "VR",
                "name": "Vale Refeição",
                "balance": 500.00,
                "availableBalance": 500.00,
                "blockedBalance": 0.00,
                "currency": "BRL",
                "status": "ACTIVE"
            },
            {
                "id": "wallet-va",
                "type": "VA",
                "name": "Vale Alimentação",
                "balance": 250.50,
                "availableBalance": 250.50,
                "blockedBalance": 0.00,
                "currency": "BRL",
                "status": "ACTIVE"
            }
        ]
    }

    mock_transactions = [
        {
            "id": "txn-1",
            "type": "PAYMENT",
            "amount": -25.00,
            "description": "Pagamento - Restaurante Sabor",
            "merchant": "Restaurante Sabor",
            "walletId": "wallet-vr",
            "walletType": "VR",
            "status": "COMPLETED",
            "createdAt": "2024-01-15T12:30:00Z",
            "reference": "REF001"
        }
    ]

    mock_card = {
        "id": "card-1",
        "type": "VIRTUAL",
        "number": "**** **** **** 1234",
        "holderName": "TIAGO TIEDE",
        "expiryMonth": 12,
        "expiryYear": 2026,
        "cvv": "***",
        "status": "ACTIVE",
        "limits": {
            "daily": 500.00,
            "monthly": 2000.00,
            "transaction": 200.00
        }
    }

    mock_notifications = [
        {
            "id": "notif-1",
            "title": "Bem-vindo ao Benefits!",
            "message": "Sua conta foi ativada com sucesso.",
            "type": "INFO",
            "read": False,
            "createdAt": "2024-01-15T10:30:00Z"
        }
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def log_message(self, format, *args):
        # Custom logging with timestamp
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f'[{timestamp}] {format % args}')

    def send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Request-Id')
        self.send_header('Content-Type', 'application/json')
        self.send_header('X-Request-Id', str(uuid.uuid4()))

    def send_json_response(self, status_code, data):
        self.send_response(status_code)
        self.send_cors_headers()
        self.end_headers()
        self.wfile.write(json.dumps(data, indent=2).encode('utf-8'))

    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        query = urllib.parse.parse_qs(parsed_path.query)

        self.send_cors_headers()

        # Health check
        if path == '/actuator/health':
            self.send_json_response(200, {"status": "UP"})

        # App config
        elif path == '/app/config':
            self.send_json_response(200, {
                "environment": "development",
                "version": "1.0.0",
                "features": ["wallet", "payments", "cards", "transactions"]
            })

        # User profile
        elif path == '/me':
            self.send_json_response(200, self.mock_user)

        # Wallet summary
        elif path == '/wallets/summary':
            self.send_json_response(200, self.mock_wallet_summary)

        # Transactions
        elif path == '/transactions':
            limit = int(query.get('limit', ['10'])[0])
            offset = int(query.get('offset', ['0'])[0])

            # Apply filters if provided
            filtered_transactions = self.mock_transactions

            if 'status' in query:
                status = query['status'][0]
                filtered_transactions = [t for t in filtered_transactions if t['status'] == status]

            if 'walletId' in query:
                wallet_id = query['walletId'][0]
                filtered_transactions = [t for t in filtered_transactions if t['walletId'] == wallet_id]

            # Paginate
            paginated = filtered_transactions[offset:offset + limit]

            response = {
                "items": paginated,
                "total": len(filtered_transactions),
                "limit": limit,
                "offset": offset
            }
            self.send_json_response(200, response)

        # Transaction by ID
        elif path.startswith('/transactions/'):
            txn_id = path.split('/')[-1]
            transaction = next((t for t in self.mock_transactions if t['id'] == txn_id), None)
            if transaction:
                self.send_json_response(200, transaction)
            else:
                self.send_json_response(404, {"error": "Transaction not found"})

        # Card info
        elif path == '/card':
            self.send_json_response(200, self.mock_card)

        # Card limits
        elif path == '/card/limits':
            self.send_json_response(200, self.mock_card['limits'])

        # Notifications
        elif path == '/notifications':
            limit = int(query.get('limit', ['20'])[0])
            unread_only = query.get('unreadOnly', ['false'])[0].lower() == 'true'

            filtered_notifications = self.mock_notifications
            if unread_only:
                filtered_notifications = [n for n in filtered_notifications if not n['read']]

            response = {
                "items": filtered_notifications[:limit],
                "total": len(filtered_notifications),
                "unreadCount": len([n for n in self.mock_notifications if not n['read']])
            }
            self.send_json_response(200, response)

        else:
            self.send_json_response(404, {"error": "Endpoint not found"})

    def do_POST(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path

        # Login
        if path == '/auth/login':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                request_data = json.loads(post_data.decode('utf-8'))

                username = request_data.get('username')
                password = request_data.get('password')

                # Mock authentication - simplified, no scope validation
                if username == "tiago.tiede@flash.com" and password == "senha123":
                    response = {
                        "access_token": f"mock-jwt-token-{uuid.uuid4()}",
                        "refresh_token": f"mock-refresh-token-{uuid.uuid4()}",
                        "token_type": "Bearer",
                        "expires_in": 3600,
                        "scope": "openid profile email"
                    }
                    self.send_json_response(200, response)
                else:
                    self.send_json_response(401, {"error": "Invalid credentials"})

            except Exception as e:
                self.send_json_response(400, {"error": f"Invalid request: {str(e)}"})

        # Refresh token
        elif path == '/auth/refresh':
            response = {
                "access_token": f"mock-jwt-token-{uuid.uuid4()}",
                "refresh_token": f"mock-refresh-token-{uuid.uuid4()}",
                "token_type": "Bearer",
                "expires_in": 3600,
                "scope": "openid profile email"
            }
            self.send_json_response(200, response)

        # Logout
        elif path == '/auth/logout':
            self.send_json_response(200, {"message": "Logged out successfully"})

        # QR validation
        elif path == '/payment/qr/validate':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                request_data = json.loads(post_data.decode('utf-8'))

                qr_data = request_data.get('qr_data', '')

                # Mock QR validation
                response = {
                    "valid": True,
                    "merchant": "Restaurante Sabor",
                    "amount": 25.00,
                    "qrId": f"qr-{uuid.uuid4()}",
                    "expiresAt": (datetime.now() + timedelta(minutes=5)).isoformat()
                }
                self.send_json_response(200, response)

            except Exception as e:
                self.send_json_response(400, {"error": f"Invalid QR data: {str(e)}"})

        # Process payment
        elif path == '/payments/process':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                request_data = json.loads(post_data.decode('utf-8'))

                # Create mock transaction
                new_transaction = {
                    "id": f"txn-{uuid.uuid4()}",
                    "type": "PAYMENT",
                    "amount": -request_data.get('amount', 0),
                    "description": f"Pagamento - {request_data.get('merchant', 'Comerciante')}",
                    "merchant": request_data.get('merchant', 'Comerciante'),
                    "walletId": request_data.get('wallet_id', 'wallet-vr'),
                    "walletType": "VR",
                    "status": "COMPLETED",
                    "createdAt": datetime.now().isoformat(),
                    "reference": f"REF{uuid.uuid4()[:8].upper()}"
                }

                self.mock_transactions.insert(0, new_transaction)

                response = {
                    "transactionId": new_transaction['id'],
                    "status": "COMPLETED",
                    "message": "Payment processed successfully"
                }
                self.send_json_response(200, response)

            except Exception as e:
                self.send_json_response(400, {"error": f"Invalid payment data: {str(e)}"})

        # Block card
        elif path == '/card/block':
            self.mock_card['status'] = 'BLOCKED'
            self.send_json_response(200, {"message": "Card blocked successfully"})

        # Unblock card
        elif path == '/card/unblock':
            self.mock_card['status'] = 'ACTIVE'
            self.send_json_response(200, {"message": "Card unblocked successfully"})

        # Generate transactions (dev endpoint)
        elif path == '/dev/transactions/generate':
            count = int(urllib.parse.parse_qs(parsed_path.query).get('count', ['100'])[0])

            # Generate mock transactions
            for i in range(count):
                txn = {
                    "id": f"txn-gen-{i+1}",
                    "type": "PAYMENT" if i % 3 != 0 else "TOPUP",
                    "amount": -25.00 if i % 3 != 0 else 100.00,
                    "description": f"Generated transaction {i+1}",
                    "merchant": f"Merchant {i+1}",
                    "walletId": "wallet-vr",
                    "walletType": "VR",
                    "status": "COMPLETED",
                    "createdAt": (datetime.now() - timedelta(days=i)).isoformat(),
                    "reference": f"GEN{i+1:04d}"
                }
                self.mock_transactions.append(txn)

            self.send_json_response(200, {"message": f"Generated {count} transactions"})

        else:
            self.send_json_response(404, {"error": "Endpoint not found"})

    def do_PUT(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path

        self.send_cors_headers()

        # Mark notification as read
        if path.startswith('/notifications/') and path.endswith('/read'):
            notif_id = path.split('/')[-2]
            notification = next((n for n in self.mock_notifications if n['id'] == notif_id), None)
            if notification:
                notification['read'] = True
                self.send_json_response(200, {"message": "Notification marked as read"})
            else:
                self.send_json_response(404, {"error": "Notification not found"})
        else:
            self.send_json_response(404, {"error": "Endpoint not found"})

    def do_OPTIONS(self):
        self.send_cors_headers()
        self.end_headers()

def run_server():
    server_address = ('', 8080)
    httpd = HTTPServer(server_address, MockUserBFFHandler)
    print("🚀 Mock User BFF Server running on port 8080")
    print("📊 Available endpoints:")
    print("  GET  /actuator/health")
    print("  GET  /app/config")
    print("  GET  /me")
    print("  GET  /wallets/summary")
    print("  GET  /transactions")
    print("  GET  /transactions/{id}")
    print("  GET  /card")
    print("  GET  /card/limits")
    print("  GET  /notifications")
    print("  POST /auth/login")
    print("  POST /auth/refresh")
    print("  POST /auth/logout")
    print("  POST /payment/qr/validate")
    print("  POST /payments/process")
    print("  POST /card/block")
    print("  POST /card/unblock")
    print("  PUT  /notifications/{id}/read")
    print("  POST /dev/transactions/generate")
    print("\nPress Ctrl+C to stop")
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()