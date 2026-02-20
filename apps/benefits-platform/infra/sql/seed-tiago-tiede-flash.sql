-- ============================================
-- SEED COMPLETO BASEADO NOS SCREENSHOTS DO APP FLASH
-- Usuário: Tiago Tiede
-- ============================================

-- Tenant padrão
INSERT INTO tenants (id, name, status, created_at, updated_at)
VALUES 
    ('tenant-flash', 'Flash Benefícios', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Usuário: Tiago Tiede
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('user-tiago-tiede', 'tiago-keycloak-id', 'tiago.tiede@flash.com', 'Tiago Tiede', '12345678900', '11999887766', 'ACTIVE', 'tenant-flash', 'tiago.tiede', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Carteiras do Tiago (Flexível ACT 2026 com R$ 111,85)
INSERT INTO wallets (id, user_id, balance, currency, status, created_at, updated_at)
VALUES 
    ('wallet-tiago-flexivel', 'user-tiago-tiede', 11185, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-tiago-alimentacao', 'user-tiago-tiede', 0, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-tiago-refeicao', 'user-tiago-tiede', 0, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, updated_at = CURRENT_TIMESTAMP;

-- Benefício: Flexível ACT 2026
INSERT INTO benefit_programs (id, name, description, type, status, created_at, updated_at)
VALUES 
    ('benefit-flexivel-act-2026', 'Flexível ACT 2026', 'Benefício flexível para uso em alimentação, conveniência e parceiros', 'FLEXIBLE', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Associação do usuário ao benefício
INSERT INTO user_benefits (id, user_id, benefit_program_id, wallet_id, status, balance, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'user-tiago-tiede', 'benefit-flexivel-act-2026', 'wallet-tiago-flexivel', 'ACTIVE', 11185, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Cartão Físico: Tiago Tiede - Conta 625
INSERT INTO cards (id, user_id, card_number, card_brand, card_type, status, expiry_month, expiry_year, cvv, created_at, updated_at)
VALUES 
    ('card-tiago-fisico-625', 'user-tiago-tiede', '4532********0625', 'VISA', 'PHYSICAL', 'ACTIVE', 12, 2028, '123', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Cartão Virtual: **** 9501 (Val. 11/2030)
INSERT INTO cards (id, user_id, card_number, card_brand, card_type, status, expiry_month, expiry_year, cvv, created_at, updated_at)
VALUES 
    ('card-tiago-virtual-9501', 'user-tiago-tiede', '5412********9501', 'MASTERCARD', 'VIRTUAL', 'ACTIVE', 11, 2030, '456', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Merchants (estabelecimentos das transações)
INSERT INTO merchants (id, keycloak_id, name, document, mcc, status, created_at, updated_at)
VALUES 
    ('merchant-ikd', 'ikd-keycloak-id', 'IKD', '11.222.333/0001-44', '5812', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('merchant-little-paul', 'littlepaul-keycloak-id', 'LITTLE PAUL', '22.333.444/0001-55', '5812', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('merchant-bardolinogas', 'bardolinogas-keycloak-id', 'MP *BARDOLINOGAS TROBAR', '33.444.555/0001-66', '5542', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('merchant-google', 'google-keycloak-id', 'Google ANDROID TEMP', '44.555.666/0001-77', '5734', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('merchant-ze-delivery', 'zedelivery-keycloak-id', 'PG *ZE DELIVERY', '55.666.777/0001-88', '5813', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Transações (extrato do Tiago)
INSERT INTO transactions (id, user_id, wallet_id, merchant_id, amount, currency, type, status, description, transaction_date, created_at, updated_at)
VALUES 
    -- Hoje, 13 de janeiro: IKD -R$ 120,00 às 11:25
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-ikd', -12000, 'BRL', 'PURCHASE', 'COMPLETED', 'Benefício Flexível', '2026-01-13 11:25:00', '2026-01-13 11:25:00', '2026-01-13 11:25:00'),
    
    -- 11 de janeiro: LITTLE PAUL -R$ 38,00 às 23:30
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-little-paul', -3800, 'BRL', 'PURCHASE', 'COMPLETED', 'Benefício Flexível', '2026-01-11 23:30:00', '2026-01-11 23:30:00', '2026-01-11 23:30:00'),
    
    -- 11 de janeiro: MP *BARDOLINOGAS TROBAR -R$ 30,00 às 21:56
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-bardolinogas', -3000, 'BRL', 'PURCHASE', 'COMPLETED', 'Benefício Flexível', '2026-01-11 21:56:00', '2026-01-11 21:56:00', '2026-01-11 21:56:00'),
    
    -- 11 de janeiro: LITTLE PAUL -R$ 76,00 às 21:33
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-little-paul', -7600, 'BRL', 'PURCHASE', 'COMPLETED', 'Benefício Flexível', '2026-01-11 21:33:00', '2026-01-11 21:33:00', '2026-01-11 21:33:00'),
    
    -- 11 de janeiro: Google ANDROID TEMP -R$ 0,00 às 16:24 (transação gratuita/teste)
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-google', 0, 'BRL', 'AUTHORIZATION', 'COMPLETED', 'Benefício Flexível', '2026-01-11 16:24:00', '2026-01-11 16:24:00', '2026-01-11 16:24:00'),
    
    -- 11 de janeiro: PG *ZE DELIVERY -R$ 56,77 às 16:23
    (gen_random_uuid(), 'user-tiago-tiede', 'wallet-tiago-flexivel', 'merchant-ze-delivery', -5677, 'BRL', 'PURCHASE', 'COMPLETED', 'Benefício Flexível', '2026-01-11 16:23:00', '2026-01-11 16:23:00', '2026-01-11 16:23:00')
ON CONFLICT DO NOTHING;

-- Admin user
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('user-admin-flash', 'admin-keycloak-id', 'admin@flash.com', 'Admin Flash', '99999999999', '11999999999', 'ACTIVE', 'tenant-flash', 'admin.flash', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Merchant user (para testes de POS)
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('user-merchant-padaria', 'merchant-padaria-keycloak-id', 'padaria@flash.com', 'Padaria São Jorge', '88888888888', '11988888888', 'ACTIVE', 'tenant-flash', 'merchant.padaria', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Associar merchant user ao merchant
UPDATE merchants SET keycloak_id = 'merchant-padaria-keycloak-id' WHERE id = 'merchant-little-paul';

-- Device do Tiago (Samsung)
INSERT INTO devices (id, user_id, device_identifier, device_name, device_os, os_version, app_version, is_trusted, status, last_active_at, created_at, updated_at)
VALUES 
    (gen_random_uuid(), 'user-tiago-tiede', 'device-samsung-tiago', 'Samsung Galaxy S21', 'ANDROID', '13', '1.0.0', true, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

COMMIT;
