#!/usr/bin/env python3
"""
Mock Admin BFF Server
Simulates admin backend for frontend development
Port: 8083
"""

import json
import uuid
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

class MockAdminBFF(BaseHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.mock_users = [
            {
                "id": "user-1",
                "name": "João Silva",
                "email": "joao.silva@email.com",
                "document": "***.***.***-12",
                "status": "ACTIVE",
                "wallets": [
                    {"type": "VR", "balance": 500.00},
                    {"type": "VA", "balance": 300.00}
                ],
                "createdAt": "2024-01-15T10:30:00Z",
                "tenantId": "tenant-1"
            },
            {
                "id": "user-2",
                "name": "Maria Santos",
                "email": "maria.santos@email.com",
                "document": "***.***.***-34",
                "status": "ACTIVE",
                "wallets": [
                    {"type": "VR", "balance": 750.00}
                ],
                "createdAt": "2024-02-20T14:15:00Z",
                "tenantId": "tenant-1"
            },
            {
                "id": "user-3",
                "name": "Pedro Costa",
                "email": "pedro.costa@email.com",
                "document": "***.***.***-56",
                "status": "PENDING",
                "wallets": [
                    {"type": "VR", "balance": 0.00}
                ],
                "createdAt": "2024-03-10T09:45:00Z",
                "tenantId": "tenant-1"
            }
        ]

        self.mock_tenants = [
            {
                "id": "tenant-1",
                "name": "Empresa ABC Ltda",
                "domain": "abc.com",
                "status": "ACTIVE",
                "features": ["WALLET_VR", "WALLET_VA", "PHYSICAL_CARD"],
                "createdAt": "2024-01-01T00:00:00Z"
            },
            {
                "id": "tenant-2",
                "name": "Tech Solutions S.A.",
                "domain": "techsol.com",
                "status": "ACTIVE",
                "features": ["WALLET_VR", "DIGITAL_WALLET"],
                "createdAt": "2024-02-15T00:00:00Z"
            }
        ]

        self.mock_merchants = [
            {
                "id": "merchant-1",
                "name": "Restaurante Sabor",
                "cnpj": "**.* **.***.****-**",
                "category": "FOOD",
                "status": "ACTIVE",
                "balance": 2500.00,
                "createdAt": "2024-01-20T11:00:00Z",
                "tenantId": "tenant-1"
            },
            {
                "id": "merchant-2",
                "name": "Farmácia Saúde",
                "cnpj": "**.* **.***.****-**",
                "category": "HEALTH",
                "status": "ACTIVE",
                "balance": 1800.00,
                "createdAt": "2024-02-05T16:30:00Z",
                "tenantId": "tenant-1"
            }
        ]

        super().__init__(*args, **kwargs)

    def log_message(self, format, *args):
        # Custom logging with timestamp
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f'[{timestamp}] {format % args}')

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        query = parse_qs(parsed_path.query)

        self.send_cors_headers()

        # Health check
        if path == '/actuator/health':
            self.send_json_response(200, {"status": "UP"})

        # App config
        elif path == '/app/config':
            self.send_json_response(200, {
                "environment": "development",
                "version": "1.0.0",
                "features": ["admin-portal", "user-management", "merchant-management"]
            })

        # Users
        elif path == '/admin/users':
            self.send_json_response(200, self.mock_users)

        # Tenants
        elif path == '/admin/tenants':
            self.send_json_response(200, self.mock_tenants)

        # Merchants
        elif path == '/admin/merchants':
            self.send_json_response(200, self.mock_merchants)

        # Reconciliation
        elif path == '/admin/reconciliation':
            reconciliation_data = {
                "totalTransactions": 1250,
                "totalAmount": 45000.00,
                "pendingAmount": 2500.00,
                "reconciledAmount": 42500.00,
                "lastReconciliation": "2024-01-15T08:00:00Z"
            }
            self.send_json_response(200, reconciliation_data)

        # Disputes
        elif path == '/admin/disputes':
            disputes_data = [
                {
                    "id": "dispute-1",
                    "userId": "user-1",
                    "merchantId": "merchant-1",
                    "amount": 25.00,
                    "reason": "Produto não entregue",
                    "status": "OPEN",
                    "createdAt": "2024-01-14T10:00:00Z"
                }
            ]
            self.send_json_response(200, disputes_data)

        # Risk Analysis
        elif path == '/admin/risk':
            risk_data = {
                "highRiskUsers": 5,
                "suspiciousTransactions": 12,
                "blockedAmount": 1500.00,
                "riskScore": 2.3
            }
            self.send_json_response(200, risk_data)

        # Support Tickets
        elif path == '/admin/support/tickets':
            tickets_data = [
                {
                    "id": "ticket-1",
                    "userId": "user-1",
                    "subject": "Problema com cartão",
                    "status": "OPEN",
                    "priority": "HIGH",
                    "createdAt": "2024-01-14T15:30:00Z"
                }
            ]
            self.send_json_response(200, tickets_data)

        # Audit Logs
        elif path == '/admin/audit':
            audit_data = [
                {
                    "id": "audit-1",
                    "action": "USER_LOGIN",
                    "userId": "user-1",
                    "timestamp": "2024-01-15T09:00:00Z",
                    "details": "Login successful"
                }
            ]
            self.send_json_response(200, audit_data)

        else:
            self.send_json_response(404, {"error": "Endpoint not found"})

    def do_POST(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        self.send_cors_headers()

        # Create User
        if path == '/admin/users':
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                user_data = json.loads(post_data.decode('utf-8'))

                new_user = {
                    "id": f"user-{len(self.mock_users) + 1}",
                    "name": user_data.get('name', 'Novo Usuário'),
                    "email": user_data.get('email', 'novo@email.com'),
                    "document": user_data.get('document', '***.***.***-**'),
                    "status": "PENDING",
                    "wallets": [{"type": "VR", "balance": 0.00}],
                    "createdAt": datetime.now().isoformat(),
                    "tenantId": user_data.get('tenantId', 'tenant-1')
                }

                self.mock_users.append(new_user)
                self.send_json_response(201, new_user)

            except Exception as e:
                self.send_json_response(400, {"error": f"Invalid user data: {str(e)}"})

        # Topup for User
        elif path.startswith('/admin/topups/user/'):
            user_id = path.split('/')[-1]
            try:
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                topup_data = json.loads(post_data.decode('utf-8'))
                amount = topup_data.get('amount', 0)

                # Find user and update balance
                user = next((u for u in self.mock_users if u['id'] == user_id), None)
                if user:
                    # Add to VR wallet
                    vr_wallet = next((w for w in user['wallets'] if w['type'] == 'VR'), None)
                    if vr_wallet:
                        vr_wallet['balance'] += amount
                    else:
                        user['wallets'].append({"type": "VR", "balance": amount})

                    self.send_json_response(200, {"message": f"Topup of R$ {amount} successful"})
                else:
                    self.send_json_response(404, {"error": "User not found"})

            except Exception as e:
                self.send_json_response(400, {"error": f"Invalid topup data: {str(e)}"})

        # Onboard User
        elif path.startswith('/admin/users/') and path.endswith('/onboard'):
            user_id = path.split('/')[-2]
            user = next((u for u in self.mock_users if u['id'] == user_id), None)
            if user:
                user['status'] = 'ACTIVE'
                self.send_json_response(200, {"message": "User onboarded successfully"})
            else:
                self.send_json_response(404, {"error": "User not found"})

        else:
            self.send_json_response(404, {"error": "Endpoint not found"})

    def send_cors_headers(self):
        self.send_response(200)
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

    def do_OPTIONS(self):
        self.send_cors_headers()
        self.end_headers()

def run_server():
    server_address = ('', 8083)
    httpd = HTTPServer(server_address, MockAdminBFF)
    print("🚀 Mock Admin BFF Server running on port 8083")
    print("📊 Available endpoints:")
    print("  GET  /actuator/health")
    print("  GET  /app/config")
    print("  GET  /admin/users")
    print("  POST /admin/users")
    print("  POST /admin/users/{id}/onboard")
    print("  POST /admin/topups/user/{id}")
    print("  GET  /admin/tenants")
    print("  GET  /admin/merchants")
    print("  GET  /admin/reconciliation")
    print("  GET  /admin/disputes")
    print("  GET  /admin/risk")
    print("  GET  /admin/support/tickets")
    print("  GET  /admin/audit")
    print("\nPress Ctrl+C to stop")
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()