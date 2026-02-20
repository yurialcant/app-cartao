-- Bootstrap data - Dados iniciais para E2E testing

-- 1. Tenants
INSERT INTO tenants (id, name, domain, active, program_type) 
VALUES 
  ('default', 'Demo Company', 'demo.benefits.local', true, 'FLEX'),
  ('tenant-acme', 'ACME Corporation', 'acme.benefits.local', true, 'PAT')
ON CONFLICT (id) DO NOTHING;

-- 2. Users
INSERT INTO users (id, tenant_id, keycloak_id, email, username, full_name, cpf, status) 
VALUES 
  ('550e8400-e29b-41d4-a716-446655440001'::uuid, 'default', 'kc-admin-001', 'admin@flash.com', 'admin', 'Admin Sistema', '12345678901', 'ACTIVE'),
  ('550e8400-e29b-41d4-a716-446655440002'::uuid, 'default', 'kc-employer-001', 'employer@flash.com', 'employer', 'RH Company', '98765432100', 'ACTIVE'),
  ('550e8400-e29b-41d4-a716-446655440003'::uuid, 'default', 'kc-merchant-001', 'merchant@flash.com', 'merchant', 'Merchant Company', '55544433322', 'ACTIVE'),
  ('550e8400-e29b-41d4-a716-446655440004'::uuid, 'default', 'kc-user1-001', 'user1@flash.com', 'user1', 'João Silva', '11122233344', 'ACTIVE')
ON CONFLICT (keycloak_id) DO NOTHING;

-- 3. Merchants
INSERT INTO merchants (id, tenant_id, name, cnpj, email, mcc, category, status) 
VALUES 
  (gen_random_uuid(), 'default', 'Restaurante Sabor', '11222333000181', 'rest@example.com', '5812', 'Restaurante', 'ACTIVE'),
  (gen_random_uuid(), 'default', 'Supermercado BomPreço', '44555666000177', 'super@example.com', '5411', 'Supermercado', 'ACTIVE')
ON CONFLICT (cnpj) DO NOTHING;

-- 4. Employers
INSERT INTO employers (id, tenant_id, name, cnpj, email, status) 
VALUES 
  (gen_random_uuid(), 'default', 'Demo Company S.A.', '12345678000199', 'rh@demo.com', 'ACTIVE'),
  (gen_random_uuid(), 'default', 'Tech Startup', '98765432000188', 'rh@startup.com', 'ACTIVE')
ON CONFLICT (cnpj) DO NOTHING;

-- 5. Wallets
INSERT INTO wallets (id, tenant_id, user_id, type, balance, currency, status) 
VALUES 
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'VR', 500.00, 'BRL', 'ACTIVE'),
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'VA', 300.00, 'BRL', 'ACTIVE'),
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'FLEX', 1200.00, 'BRL', 'ACTIVE')
ON CONFLICT DO NOTHING;

-- 6. Transactions
INSERT INTO transactions (id, tenant_id, user_id, type, amount, merchant, description, status) 
VALUES 
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'DEBIT', 45.50, 'Restaurante Sabor', 'Almoço executivo', 'APPROVED'),
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'DEBIT', 89.90, 'Supermercado BomPreço', 'Compras semanais', 'APPROVED'),
  (gen_random_uuid(), 'default', '550e8400-e29b-41d4-a716-446655440004', 'CREDIT', 500.00, NULL, 'Recarga mensal VR', 'APPROVED')
ON CONFLICT DO NOTHING;

-- 7. Feature Flags
INSERT INTO feature_flags (id, key, value, scope, scope_id, description) 
VALUES 
  (gen_random_uuid(), 'VR_ENABLED', true, 'TENANT', 'default', 'Vale Refeição habilitado'),
  (gen_random_uuid(), 'VA_ENABLED', true, 'TENANT', 'default', 'Vale Alimentação habilitado'),
  (gen_random_uuid(), 'FLEX_WALLET', true, 'TENANT', 'default', 'Carteira Flex habilitada'),
  (gen_random_uuid(), 'VIRTUAL_CARD', true, 'GLOBAL', 'GLOBAL', 'Cartão virtual global'),
  (gen_random_uuid(), 'QR_PAYMENT', true, 'GLOBAL', 'GLOBAL', 'Pagamento QR Code global')
ON CONFLICT DO NOTHING;
