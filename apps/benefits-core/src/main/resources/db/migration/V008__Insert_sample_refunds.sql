-- V008__Insert_sample_refunds.sql
-- Sample data for F07 Refund testing

-- Insert sample refund records
INSERT INTO refunds (
    id,
    tenant_id,
    person_id,
    wallet_id,
    original_transaction_id,
    amount,
    currency,
    reason,
    status,
    idempotency_key,
    authorization_code,
    processed_at,
    created_at,
    updated_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440500'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid, -- origami tenant
    '550e8400-e29b-41d4-a716-446655440001'::uuid, -- Lucas
    '550e8400-e29b-41d4-a716-446655440200'::uuid, -- MEAL wallet
    'AUTH001-ORIGINAL-12345',
    25.00,
    'BRL',
    'Cliente solicitou cancelamento',
    'APPROVED',
    'refund-test-001',
    'REF123456789',
    NOW(),
    NOW(),
    NOW()
), (
    '550e8400-e29b-41d4-a716-446655440501'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid, -- origami tenant
    '550e8400-e29b-41d4-a716-446655440001'::uuid, -- Lucas
    '550e8400-e29b-41d4-a716-446655440201'::uuid, -- FOOD wallet
    'AUTH002-ORIGINAL-67890',
    15.50,
    'BRL',
    'Produto fora de estoque',
    'APPROVED',
    'refund-test-002',
    'REF987654321',
    NOW(),
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Insert corresponding ledger entries for the refunds
INSERT INTO ledger_entries (
    id,
    tenant_id,
    wallet_id,
    entry_type,
    amount,
    description,
    reference_id,
    reference_type,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440600'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid, -- tenant_id as string
    '550e8400-e29b-41d4-a716-446655440200'::uuid, -- MEAL wallet
    'CREDIT',
    25.00,
    'Refund for transaction: AUTH001-ORIGINAL-12345',
    'REF_REF123456789',
    'REFUND',
    'COMPLETED',
    NOW()
), (
    '550e8400-e29b-41d4-a716-446655440601'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid, -- tenant_id as string
    '550e8400-e29b-41d4-a716-446655440201'::uuid, -- FOOD wallet
    'CREDIT',
    15.50,
    'Refund for transaction: AUTH002-ORIGINAL-67890',
    'REF_REF987654321',
    'REFUND',
    'COMPLETED',
    NOW()
) ON CONFLICT (id) DO NOTHING;