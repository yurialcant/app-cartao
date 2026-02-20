-- Seed: Usuários e Wallets de Teste
-- Idempotente: Pode rodar múltiplas vezes sem erro
-- UUIDs fixos para testes E2E determinísticos

-- Tenant ID de referência
-- '550e8400-e29b-41d4-a716-446655440000'::uuid = ORIGAMI

-- 1. USUÁRIOS DE TESTE
-- Nota: Senhas hasheadas com bcrypt (custo 10)
-- Senha padrão para todos: "Pass@123" → $2a$10$...

INSERT INTO users (
    id,
    tenant_id,
    email,
    name,
    cpf,
    phone,
    status,
    email_verified,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440100'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'lucas@origami.com',
    'Lucas Origami',
    '12345678900',
    '+5511999999001',
    'ACTIVE',
    true,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440101'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'maria@origami.com',
    'Maria Silva',
    '98765432100',
    '+5511999999002',
    'ACTIVE',
    true,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440102'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'joao@origami.com',
    'João Santos',
    '11122233344',
    '+5511999999003',
    'ACTIVE',
    true,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 2. WALLETS (Carteiras) para cada usuário
-- Lucas: 3 carteiras (MEAL, FOOD, TRANSPORT)
INSERT INTO wallets (
    id,
    tenant_id,
    user_id,
    wallet_type,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440200'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440100'::uuid,
    'MEAL',
    'ACTIVE',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440100'::uuid,
    'FOOD',
    'ACTIVE',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440202'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440100'::uuid,
    'TRANSPORT',
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- Maria: 2 carteiras (MEAL, FOOD)
INSERT INTO wallets (
    id,
    tenant_id,
    user_id,
    wallet_type,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440203'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440101'::uuid,
    'MEAL',
    'ACTIVE',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440204'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440101'::uuid,
    'FOOD',
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- João: 1 carteira (MEAL)
INSERT INTO wallets (
    id,
    tenant_id,
    user_id,
    wallet_type,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440205'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440102'::uuid,
    'MEAL',
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 3. LEDGER ENTRIES (Lançamentos de exemplo)
-- Lucas MEAL wallet: Crédito inicial de R$ 500,00
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440300'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440200'::uuid,
    'CREDIT',
    500.00, -- R$ 500,00
    'Crédito inicial - Janeiro 2026',
    '550e8400-e29b-41d4-a716-446655440400',
    CURRENT_TIMESTAMP - INTERVAL '10 days'
) ON CONFLICT (id) DO NOTHING;

-- Lucas MEAL: Débito de R$ 45,50 (supermercado)
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440200'::uuid,
    'DEBIT',
    -45.50, -- R$ -45,50
    'Compra - Supermercado XYZ',
    '550e8400-e29b-41d4-a716-446655440401',
    CURRENT_TIMESTAMP - INTERVAL '5 days'
) ON CONFLICT (id) DO NOTHING;

-- Lucas MEAL: Débito de R$ 120,00 (supermercado)
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440302'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440200'::uuid,
    'DEBIT',
    -120.00, -- R$ -120,00
    'Compra - Mercado ABC',
    '550e8400-e29b-41d4-a716-446655440402',
    CURRENT_TIMESTAMP - INTERVAL '2 days'
) ON CONFLICT (id) DO NOTHING;

-- Lucas FOOD wallet: Crédito inicial de R$ 300,00
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440303'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    'CREDIT',
    300.00, -- R$ 300,00
    'Crédito inicial - Janeiro 2026',
    '550e8400-e29b-41d4-a716-446655440403',
    CURRENT_TIMESTAMP - INTERVAL '10 days'
) ON CONFLICT (id) DO NOTHING;

-- Lucas FOOD: Débito de R$ 28,90 (restaurante)
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440304'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440201'::uuid,
    'DEBIT',
    -28.90, -- R$ -28,90
    'Almoço - Restaurante Bom Sabor',
    '550e8400-e29b-41d4-a716-446655440404',
    CURRENT_TIMESTAMP - INTERVAL '1 day'
) ON CONFLICT (id) DO NOTHING;

-- Maria MEAL: Crédito inicial de R$ 600,00
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440305'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440203'::uuid,
    'CREDIT',
    600.00, -- R$ 600,00
    'Crédito inicial - Janeiro 2026',
    '550e8400-e29b-41d4-a716-446655440405',
    CURRENT_TIMESTAMP - INTERVAL '10 days'
) ON CONFLICT (id) DO NOTHING;

-- João MEAL: Crédito inicial de R$ 400,00
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440306'::uuid,
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440205'::uuid,
    'CREDIT',
    400.00, -- R$ 400,00
    'Crédito inicial - Janeiro 2026',
    '550e8400-e29b-41d4-a716-446655440406',
    CURRENT_TIMESTAMP - INTERVAL '10 days'
) ON CONFLICT (id) DO NOTHING;

-- Verificação final
DO $$
DECLARE
    user_count INT;
    wallet_count INT;
    ledger_count INT;
    total_balance_cents BIGINT;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000';
    SELECT COUNT(*) INTO wallet_count FROM wallets WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000';
    SELECT COUNT(*) INTO ledger_count FROM ledger_entries WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000';

    RAISE NOTICE '✅ Seed 02-users-wallets.sql aplicado com sucesso';
    RAISE NOTICE 'Usuários: %', user_count;
    RAISE NOTICE 'Wallets: %', wallet_count;
    RAISE NOTICE 'Ledger Entries: %', ledger_count;
END $$;
