-- Seed: Tenant ORIGAMI (Master White-Label)
-- Idempotente: Pode rodar múltiplas vezes sem erro
-- UUID fixo para testes determinísticos

-- 1. TENANT
INSERT INTO tenants (
    id,
    name,
    slug,
    legal_name,
    tax_id,
    status,
    created_at,
    created_by,
    tenant_id
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Origami',
    'origami',
    'Origami Benefícios Ltda',
    '12345678000190',
    'ACTIVE',
    CURRENT_TIMESTAMP,
    '00000000-0000-0000-0000-000000000000'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid
) ON CONFLICT (id) DO NOTHING;

-- 2. TENANT BRANDING
INSERT INTO tenant_branding (
    id,
    tenant_id,
    primary_color,
    secondary_color,
    logo_url,
    favicon_url,
    app_name,
    support_email,
    support_phone,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '#3498db',
    '#2c3e50',
    'https://origami.example.com/logo.png',
    'https://origami.example.com/favicon.ico',
    'Origami',
    'suporte@origami.com.br',
    '+55 11 99999-9999',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 3. PLANS (Planos de benefícios)
INSERT INTO plans (
    id,
    tenant_id,
    name,
    code,
    description,
    status,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Plano Essencial',
    'ESSENCIAL',
    'Plano básico com benefícios alimentação e refeição',
    'ACTIVE',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440011'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Plano Premium',
    'PREMIUM',
    'Plano completo com todos os benefícios',
    'ACTIVE',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 4. PLAN MODULES (Módulos do plano)
INSERT INTO plan_modules (
    id,
    tenant_id,
    plan_id,
    module_name,
    module_code,
    enabled,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440020'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    'Vale Alimentação',
    'MEAL',
    true,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440021'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440010'::uuid,
    'Vale Refeição',
    'FOOD',
    true,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440022'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    '550e8400-e29b-41d4-a716-446655440011'::uuid,
    'Vale Transporte',
    'TRANSPORT',
    true,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 5. WALLET DEFINITIONS (Tipos de carteira por tenant)
INSERT INTO wallet_definitions (
    id,
    tenant_id,
    wallet_type,
    name,
    description,
    currency,
    allows_negative_balance,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440030'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'MEAL',
    'Alimentação',
    'Saldo para compras em supermercados',
    'BRL',
    false,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440031'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'FOOD',
    'Refeição',
    'Saldo para restaurantes e lanchonetes',
    'BRL',
    false,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440032'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'TRANSPORT',
    'Transporte',
    'Saldo para transporte público',
    'BRL',
    false,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 6. FEATURE FLAGS (Funcionalidades habilitadas)
INSERT INTO feature_flags (
    id,
    tenant_id,
    flag_name,
    flag_key,
    enabled,
    description,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440040'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'QR Code Payment',
    'qr_payment_enabled',
    true,
    'Permite pagamentos via QR Code',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440041'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Biometric Login',
    'biometric_login_enabled',
    true,
    'Login com biometria nos apps',
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440042'::uuid,
    '550e8400-e29b-41d4-a716-446655440000'::uuid,
    'Credit Batch',
    'credit_batch_enabled',
    true,
    'Permite lançamento em lote pelo empregador',
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- Verificação final
DO $$
BEGIN
    RAISE NOTICE '✅ Seed 01-tenant-origami.sql aplicado com sucesso';
    RAISE NOTICE 'Tenant: % (%)', 
        (SELECT name FROM tenants WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid),
        (SELECT slug FROM tenants WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid);
    RAISE NOTICE 'Planos: %', (SELECT COUNT(*) FROM plans WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);
    RAISE NOTICE 'Wallet Definitions: %', (SELECT COUNT(*) FROM wallet_definitions WHERE tenant_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);
END $$;
