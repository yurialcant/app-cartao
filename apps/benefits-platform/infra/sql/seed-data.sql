-- Script SQL para popular dados de teste
-- Execute após criar as tabelas

-- Limpar dados existentes (opcional)
-- TRUNCATE TABLE transactions CASCADE;
-- TRUNCATE TABLE wallets CASCADE;

-- Inserir wallets para user1 (ID do Keycloak)
-- Substitua 'b9a3fdb4-688c-41c7-b705-bcc0e322c022' pelo ID real do user1 no Keycloak
INSERT INTO wallets (id, "userId", type, balance, currency, "lastUpdated")
VALUES 
    ('550e8400-e29b-41d4-a716-446655440001', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'VR', 500.00, 'BRL', NOW()),
    ('550e8400-e29b-41d4-a716-446655440002', 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'VA', 300.00, 'BRL', NOW())
ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, "lastUpdated" = NOW();

-- Inserir transações de exemplo para user1
-- Status: CREATED, PENDING, APPROVED, DECLINED, CAPTURED, SETTLED, REVERSED, REFUNDED, DISPUTED
INSERT INTO transactions (id, "userId", type, amount, merchant, description, "createdAt", status, reference, "walletId", "walletType")
VALUES 
    -- Transações aprovadas recentes
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 25.50, 'Padaria XYZ', 'Pão e café da manhã', NOW() - INTERVAL '2 hours', 'APPROVED', 'REF-001', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 45.00, 'Farmácia Saúde', 'Medicamentos', NOW() - INTERVAL '5 hours', 'APPROVED', 'REF-002', '550e8400-e29b-41d4-a716-446655440002', 'VA'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 80.00, 'Restaurante Bom Sabor', 'Almoço', NOW() - INTERVAL '1 day', 'APPROVED', 'REF-003', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    
    -- Transação pendente
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 120.00, 'Supermercado Central', 'Compras do mês', NOW() - INTERVAL '30 minutes', 'PENDING', 'REF-004', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    
    -- Transação negada
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 600.00, 'Loja de Eletrônicos', 'Produto caro', NOW() - INTERVAL '3 days', 'DECLINED', 'REF-005', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    
    -- Transação reembolsada
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 50.00, 'Pet Shop', 'Ração para cachorro', NOW() - INTERVAL '7 days', 'REFUNDED', 'REF-006', '550e8400-e29b-41d4-a716-446655440002', 'VA'),
    
    -- Topup (crédito)
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'TOPUP', 500.00, 'Empresa', 'Crédito mensal VR', NOW() - INTERVAL '10 days', 'SETTLED', 'REF-007', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'TOPUP', 300.00, 'Empresa', 'Crédito mensal VA', NOW() - INTERVAL '10 days', 'SETTLED', 'REF-008', '550e8400-e29b-41d4-a716-446655440002', 'VA'),
    
    -- Mais transações para histórico
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 15.00, 'Padaria XYZ', 'Café', NOW() - INTERVAL '2 days', 'APPROVED', 'REF-009', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 35.00, 'Farmácia Saúde', 'Vitamina C', NOW() - INTERVAL '3 days', 'APPROVED', 'REF-010', '550e8400-e29b-41d4-a716-446655440002', 'VA'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 90.00, 'Restaurante Bom Sabor', 'Jantar', NOW() - INTERVAL '4 days', 'APPROVED', 'REF-011', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 200.00, 'Supermercado Central', 'Compras semanais', NOW() - INTERVAL '5 days', 'APPROVED', 'REF-012', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 12.00, 'Padaria XYZ', 'Pão de forma', NOW() - INTERVAL '6 days', 'APPROVED', 'REF-013', '550e8400-e29b-41d4-a716-446655440001', 'VR'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 28.00, 'Farmácia Saúde', 'Analgésico', NOW() - INTERVAL '7 days', 'APPROVED', 'REF-014', '550e8400-e29b-41d4-a716-446655440002', 'VA'),
    (gen_random_uuid(), 'b9a3fdb4-688c-41c7-b705-bcc0e322c022', 'DEBIT', 65.00, 'Restaurante Bom Sabor', 'Almoço executivo', NOW() - INTERVAL '8 days', 'APPROVED', 'REF-015', '550e8400-e29b-41d4-a716-446655440001', 'VR');

-- Atualizar saldo das wallets baseado nas transações
UPDATE wallets 
SET balance = (
    SELECT COALESCE(SUM(
        CASE 
            WHEN type = 'DEBIT' THEN -amount
            WHEN type IN ('CREDIT', 'TOPUP') THEN amount
            ELSE 0
        END
    ), 0)
    FROM transactions 
    WHERE transactions."userId" = wallets."userId" 
    AND transactions."walletId" = wallets.id::text
    AND transactions.status IN ('APPROVED', 'SETTLED')
),
"lastUpdated" = NOW()
WHERE "userId" = 'b9a3fdb4-688c-41c7-b705-bcc0e322c022';
