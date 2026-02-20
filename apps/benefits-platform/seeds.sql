-- =============================================================================
-- E2E TEST DATA - Benefits Platform Multi-Tenant
-- Modern Architecture: Spring Boot 3.5.9 + WebFlux + R2DBC + PostgreSQL
-- Single Data Source: benefits-core (8091)
-- Consumers: 5 BFFs + Flutter App + Admin Portal
-- =============================================================================

-- =============================================================================
-- 1. USERS (keycloak_id ÚNICO, sem campo 'role')
-- =============================================================================
INSERT INTO users (id, tenant_id, keycloak_id, email, username, full_name, cpf, status, created_at, updated_at)
VALUES
  -- User 1 - ID fixo para compatibilidade com Keycloak
  ('b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'default', 'keycloak-user1', 'user1@benefits.local', 'user1', 'João Silva', '12345678901', 'ACTIVE', NOW(), NOW()),
  -- User 2
  (gen_random_uuid(), 'default', 'keycloak-user2', 'user2@benefits.local', 'user2', 'Maria Santos', '98765432100', 'ACTIVE', NOW(), NOW()),
  -- Admin
  (gen_random_uuid(), 'default', 'keycloak-admin', 'admin@benefits.local', 'admin', 'Admin Sistema', '11111111111', 'ACTIVE', NOW(), NOW())
ON CONFLICT (keycloak_id) DO NOTHING;

-- =============================================================================
-- 2. MERCHANTS (UUID auto-gerado, sem campo 'email' obrigatório)
-- =============================================================================
INSERT INTO merchants (id, tenant_id, name, cnpj, email, mcc, category, status, created_at, updated_at)
VALUES
  (gen_random_uuid(), 'default', 'Restaurante Sabor', '11222333000181', 'restaurante@example.com', '5812', 'Restaurante', 'ACTIVE', NOW(), NOW()),
  (gen_random_uuid(), 'default', 'Supermercado BomPreço', '44555666000177', 'super@example.com', '5411', 'Supermercado', 'ACTIVE', NOW(), NOW()),
  (gen_random_uuid(), 'default', 'Farmácia Saúde', '77888999000166', 'farmacia@example.com', '5912', 'Farmácia', 'ACTIVE', NOW(), NOW())
ON CONFLICT (cnpj) DO NOTHING;

-- =============================================================================
-- 3. WALLETS (wallet_type é ENUM: VR, VA, VT, FLEX, CORPORATE)
-- =============================================================================
-- Buscar user_id do user1 (assumindo que Hibernate usou UUID string)
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM users WHERE keycloak_id = 'keycloak-user1' LIMIT 1;
  
  INSERT INTO wallets (id, tenant_id, user_id, wallet_type, balance, currency, status, created_at, last_updated)
  VALUES
    (gen_random_uuid(), 'default', v_user_id::text, 'VR', 500.00, 'BRL', 'ACTIVE', NOW(), NOW()),
    (gen_random_uuid(), 'default', v_user_id::text, 'VA', 300.00, 'BRL', 'ACTIVE', NOW(), NOW()),
    (gen_random_uuid(), 'default', v_user_id::text, 'FLEX', 1200.00, 'BRL', 'ACTIVE', NOW(), NOW())
  ON CONFLICT DO NOTHING;
END $$;

-- =============================================================================
-- 4. TRANSACTIONS (merchant é string, não FK)
-- =============================================================================
DO $$
DECLARE
  v_user_id UUID;
  v_wallet_id_vr UUID;
  v_wallet_id_va UUID;
BEGIN
  SELECT id INTO v_user_id FROM users WHERE keycloak_id = 'keycloak-user1' LIMIT 1;
  SELECT id INTO v_wallet_id_vr FROM wallets WHERE user_id = v_user_id::text AND wallet_type = 'VR' LIMIT 1;
  SELECT id INTO v_wallet_id_va FROM wallets WHERE user_id = v_user_id::text AND wallet_type = 'VA' LIMIT 1;
  
  -- Transações de DEBIT (pagamentos)
  INSERT INTO transactions (id, tenant_id, user_id, type, amount, merchant, description, wallet_id, wallet_type, status, created_at)
  VALUES
    (gen_random_uuid(), 'default', v_user_id::text, 'DEBIT', 45.50, 'Restaurante Sabor', 'Almoço executivo', v_wallet_id_vr::text, 'VR', 'APPROVED', NOW() - INTERVAL '2 days'),
    (gen_random_uuid(), 'default', v_user_id::text, 'DEBIT', 89.90, 'Supermercado BomPreço', 'Compras semanais', v_wallet_id_va::text, 'VA', 'APPROVED', NOW() - INTERVAL '1 day'),
    (gen_random_uuid(), 'default', v_user_id::text, 'DEBIT', 32.00, 'Restaurante Sabor', 'Lanche', v_wallet_id_vr::text, 'VR', 'APPROVED', NOW() - INTERVAL '3 hours')
  ON CONFLICT DO NOTHING;
  
  -- Transações de CREDIT (recarga)
  INSERT INTO transactions (id, tenant_id, user_id, type, amount, description, wallet_id, wallet_type, status, created_at)
  VALUES
    (gen_random_uuid(), 'default', v_user_id::text, 'TOPUP', 500.00, 'Recarga mensal VR', v_wallet_id_vr::text, 'VR', 'APPROVED', NOW() - INTERVAL '5 days'),
    (gen_random_uuid(), 'default', v_user_id::text, 'TOPUP', 300.00, 'Recarga mensal VA', v_wallet_id_va::text, 'VA', 'APPROVED', NOW() - INTERVAL '5 days')
  ON CONFLICT DO NOTHING;
END $$;
  (gen_random_uuid(), 'tenant-default', 'merchant-002', 'TRM-002-SUPER', 'ACTIVE', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 8. EMPLOYERS (para employer portal)
-- =============================================================================
INSERT INTO employers (id, tenant_id, name, cnpj, email, status, created_at, updated_at)
VALUES
  ('employer-001', 'tenant-default', 'Tech Solutions LTDA', '12.345.678/0001-90', 'hr@techsolutions.com.br', 'ACTIVE', NOW(), NOW()),
  ('employer-002', 'tenant-default', 'Industrial Ltda', '98.765.432/0001-10', 'rh@industrial.com.br', 'ACTIVE', NOW(), NOW()),
  ('employer-003', 'tenant-acme', 'ACME Corporation Brasil', '11.222.333/0001-44', 'resources@acme.com.br', 'ACTIVE', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 9. DEPARTMENTS (para employees)
-- =============================================================================
INSERT INTO departments (id, tenant_id, employer_id, name, manager_id, status, created_at, updated_at)
VALUES
  ('dept-001', 'tenant-default', 'employer-001', 'TI', 'user-001', 'ACTIVE', NOW(), NOW()),
  ('dept-002', 'tenant-default', 'employer-001', 'RH', 'user-002', 'ACTIVE', NOW(), NOW()),
  ('dept-003', 'tenant-default', 'employer-002', 'Produção', 'user-001', 'ACTIVE', NOW(), NOW()),
  ('dept-004', 'tenant-acme', 'employer-003', 'Vendas', 'user-002', 'ACTIVE', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 10. EMPLOYEES (para employer portal)
-- =============================================================================
INSERT INTO employees (id, tenant_id, employer_id, department_id, user_id, name, email, cpf, position, status, hire_date, created_at, updated_at)
VALUES
  ('emp-001', 'tenant-default', 'employer-001', 'dept-001', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'João Silva', 'joao.silva@techsolutions.com.br', '123.456.789-00', 'Desenvolvedor', 'ACTIVE', NOW() - INTERVAL '2 years', NOW(), NOW()),
  ('emp-002', 'tenant-default', 'employer-001', 'dept-001', 'user-001', 'Maria Santos', 'maria.santos@techsolutions.com.br', '987.654.321-00', 'Desenvolvedora Senior', 'ACTIVE', NOW() - INTERVAL '3 years', NOW(), NOW()),
  ('emp-003', 'tenant-default', 'employer-001', 'dept-002', 'user-002', 'Carlos Oliveira', 'carlos.oliveira@techsolutions.com.br', '111.222.333-44', 'Gerente RH', 'ACTIVE', NOW() - INTERVAL '1 year', NOW(), NOW()),
  ('emp-004', 'tenant-default', 'employer-002', 'dept-003', 'user-003', 'Ana Costa', 'ana.costa@industrial.com.br', '555.666.777-88', 'Supervisor Produção', 'ACTIVE', NOW() - INTERVAL '6 months', NOW(), NOW()),
  ('emp-005', 'tenant-acme', 'employer-003', 'dept-004', 'user-001', 'Pedro Rocha', 'pedro.rocha@acme.com.br', '999.000.111-22', 'Vendedor', 'ACTIVE', NOW() - INTERVAL '4 months', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 11. POLICIES (políticas de benefício)
-- =============================================================================
INSERT INTO policies (id, tenant_id, employer_id, name, description, benefit_type, annual_budget, status, created_at, updated_at)
VALUES
  ('policy-001', 'tenant-default', 'employer-001', 'Vale Refeição 2024', 'Política de vale refeição para todos os colaboradores', 'VR', 50000.00, 'ACTIVE', NOW(), NOW()),
  ('policy-002', 'tenant-default', 'employer-001', 'Vale Alimentação 2024', 'Política de vale alimentação para todos os colaboradores', 'VA', 30000.00, 'ACTIVE', NOW(), NOW()),
  ('policy-003', 'tenant-default', 'employer-001', 'Carteira Flex 2024', 'Carteira flexível para gastos diversos', 'FLEX', 20000.00, 'ACTIVE', NOW(), NOW()),
  ('policy-004', 'tenant-default', 'employer-002', 'Vale Refeição 2024', 'Política de vale refeição Industrial', 'VR', 80000.00, 'ACTIVE', NOW(), NOW()),
  ('policy-005', 'tenant-acme', 'employer-003', 'Pacote Completo ACME', 'Pacote com VR, VA e Flex para executivos', 'VR', 120000.00, 'ACTIVE', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 12. SAMPLE TRANSACTIONS
-- =============================================================================
INSERT INTO transactions (id, tenant_id, user_id, merchant_id, amount, status, type, description, created_at)
VALUES
  (gen_random_uuid(), 'tenant-default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'merchant-001', 45.50, 'APPROVED', 'PAYMENT', 'Almoço', NOW() - INTERVAL '2 days'),
  (gen_random_uuid(), 'tenant-default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'merchant-002', 156.80, 'APPROVED', 'PAYMENT', 'Compras supermercado', NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), 'tenant-default', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'merchant-001', 32.00, 'APPROVED', 'PAYMENT', 'Jantar', NOW()),
  (gen_random_uuid(), 'tenant-default', 'user-001', 'merchant-002', 250.00, 'APPROVED', 'PAYMENT', 'Compras supermercado', NOW() - INTERVAL '3 days'),
  (gen_random_uuid(), 'tenant-default', 'user-002', 'merchant-003', 89.90, 'APPROVED', 'PAYMENT', 'Farmácia - Medicamentos', NOW() - INTERVAL '1 day'),
  (gen_random_uuid(), 'tenant-acme', 'user-001', 'merchant-001', 120.00, 'APPROVED', 'PAYMENT', 'Almoço executivo', NOW())
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 13. FEATURE FLAGS
-- =============================================================================
INSERT INTO feature_flags (id, tenant_id, name, description, enabled, created_at, updated_at)
VALUES
  ('flag-001', 'tenant-default', 'ENABLE_TOPUP_BATCH', 'Habilitar recarga em lote', true, NOW(), NOW()),
  ('flag-002', 'tenant-default', 'ENABLE_QR_CODE', 'Habilitar pagamento por QR code', true, NOW(), NOW()),
  ('flag-003', 'tenant-default', 'ENABLE_EMPLOYEE_IMPORT', 'Habilitar importação de colaboradores', true, NOW(), NOW()),
  ('flag-004', 'tenant-default', 'ENABLE_SETTLEMENT', 'Habilitar liquidação de vendas', true, NOW(), NOW()),
  ('flag-005', 'tenant-acme', 'ENABLE_ALL_FEATURES', 'ACME com todas as features ativas', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 14. PLANS
-- =============================================================================
INSERT INTO plans (id, name, description, status, price_monthly, created_at, updated_at)
VALUES
  ('plan-basic', 'Básico', 'Plano básico com funcionalidades essenciais', 'ACTIVE', 19.90, NOW(), NOW()),
  ('plan-premium', 'Premium', 'Plano premium com todas as funcionalidades', 'ACTIVE', 49.90, NOW(), NOW()),
  ('plan-enterprise', 'Enterprise', 'Plano empresarial customizado', 'ACTIVE', 199.90, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET updated_at = NOW();

-- =============================================================================
-- FINAL VERIFICATION
-- =============================================================================
SELECT 'Seeds inseridos com sucesso!' as status;
SELECT 'Users count: ' || COUNT(*) FROM users;
SELECT 'Employers count: ' || COUNT(*) FROM employers;
SELECT 'Employees count: ' || COUNT(*) FROM employees;
SELECT 'Merchants count: ' || COUNT(*) FROM merchants;
SELECT 'Wallets count: ' || COUNT(*) FROM wallets;
SELECT 'Transactions count: ' || COUNT(*) FROM transactions;
SELECT 'Policies count: ' || COUNT(*) FROM policies;
SELECT 'Feature flags count: ' || COUNT(*) FROM feature_flags;
