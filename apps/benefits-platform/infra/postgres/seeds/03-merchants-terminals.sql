-- Seed: Merchants e Terminals para F06 POS Authorize
-- Idempotente: Pode rodar múltiplas vezes sem erro
-- UUIDs fixos para testes E2E determinísticos

-- Tenant ID de referência
-- '550e8400-e29b-41d4-a716-446655440000'::uuid = ORIGAMI

-- 1. MERCHANTS DE TESTE
INSERT INTO merchants (
    id,
    tenant_id,
    merchant_id,
    name,
    tax_id,
    mcc,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440300'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'MERCH001',
    'Restaurante Origami',
    '12345678000123',
    '5812', -- Restaurants
    'ACTIVE',
    CURRENT_TIMESTAMP
), (
    '550e8400-e29b-41d4-a716-446655440301'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'MERCH002',
    'Farmácia Central',
    '98765432000145',
    '5912', -- Drug Stores
    'ACTIVE',
    CURRENT_TIMESTAMP
), (
    '550e8400-e29b-41d4-a716-446655440302'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'MERCH003',
    'Posto de Gasolina ABC',
    '11223344000167',
    '5541', -- Service Stations
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 2. TERMINALS DE TESTE
INSERT INTO terminals (
    id,
    tenant_id,
    merchant_id,
    terminal_code,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440400'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440300'::uuid, -- Restaurante Origami
    'TERM001',
    'ACTIVE',
    CURRENT_TIMESTAMP
), (
    '550e8400-e29b-41d4-a716-446655440401'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440300'::uuid, -- Restaurante Origami
    'TERM002',
    'ACTIVE',
    CURRENT_TIMESTAMP
), (
    '550e8400-e29b-41d4-a716-446655440402'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440301'::uuid, -- Farmácia Central
    'TERM101',
    'ACTIVE',
    CURRENT_TIMESTAMP
), (
    '550e8400-e29b-41d4-a716-446655440403'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440302'::uuid, -- Posto ABC
    'TERM201',
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;