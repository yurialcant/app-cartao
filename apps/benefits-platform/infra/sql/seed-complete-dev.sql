-- =====================================================
-- SEED DE DESENVOLVIMENTO COMPLETO
-- =====================================================
-- Este script cria dados de demonstração para desenvolvimento local.
-- É IDEMPOTENTE - pode rodar várias vezes sem duplicar dados.

-- =====================================================
-- 1. TENANTS (2 empresas white-label)
-- =====================================================
INSERT INTO tenants (id, name, domain, active, program_type, feature_flags, created_at, updated_at)
VALUES 
    ('tenant-acme', 'ACME Corporation', 'acme.benefits.local', true, 'FLEX', 
     '{"ENABLE_VIRTUAL_CARD": true, "ENABLE_CORPORATE": true, "ENABLE_PARTNERS": true}',
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('tenant-globex', 'Globex Industries', 'globex.benefits.local', true, 'PAT',
     '{"ENABLE_VIRTUAL_CARD": true, "ENABLE_CORPORATE": false, "ENABLE_PARTNERS": true}',
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 2. TENANT BRANDINGS
-- =====================================================
INSERT INTO tenant_brandings (id, tenant_id, primary_color, secondary_color, logo_url, favicon_url, created_at)
VALUES 
    ('branding-acme', 'tenant-acme', '#E91E63', '#FF5722', '/assets/logos/acme.png', '/assets/favicons/acme.ico', CURRENT_TIMESTAMP),
    ('branding-globex', 'tenant-globex', '#4CAF50', '#8BC34A', '/assets/logos/globex.png', '/assets/favicons/globex.ico', CURRENT_TIMESTAMP)
ON CONFLICT (tenant_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 3. PLANOS
-- =====================================================
INSERT INTO plans (id, name, description, status, price_monthly, eligibility, limits, created_at)
VALUES 
    ('plan-basic', 'Plano Básico', 'Plano com funcionalidades essenciais', 'ACTIVE', 9.90,
     '{"minEmployees": 1}',
     '{"maxWallets": 3, "maxCardsVirtual": 1, "maxTransactionsPerMonth": 500}',
     CURRENT_TIMESTAMP),
    ('plan-full', 'Plano Completo', 'Plano com todas as funcionalidades', 'ACTIVE', 29.90,
     '{"minEmployees": 1}',
     '{"maxWallets": 10, "maxCardsVirtual": 5, "maxTransactionsPerMonth": 2000}',
     CURRENT_TIMESTAMP),
    ('plan-enterprise', 'Plano Enterprise', 'Plano customizado para grandes empresas', 'ACTIVE', NULL,
     '{"minEmployees": 100, "requiresApproval": true}',
     '{"maxWallets": -1, "maxCardsVirtual": -1, "maxTransactionsPerMonth": -1}',
     CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 4. MÓDULOS POR PLANO
-- =====================================================
-- Módulos do Plano Básico
INSERT INTO plan_modules (id, plan_id, module_type, display_name, description, icon_name, display_order, enabled, routes, ui_hints, created_at)
VALUES 
    ('mod-basic-wallet', 'plan-basic', 'WALLET', 'Carteiras', 'Gerencie seus saldos', 'wallet', 1, true,
     '["wallet_list", "wallet_detail"]',
     '{"showInHome": true, "color": "#4CAF50"}', CURRENT_TIMESTAMP),
    ('mod-basic-cards', 'plan-basic', 'CARDS', 'Cartões', 'Seus cartões de benefício', 'credit_card', 2, true,
     '["cards_list", "card_detail"]',
     '{"showInHome": true, "color": "#2196F3"}', CURRENT_TIMESTAMP),
    ('mod-basic-partners', 'plan-basic', 'PARTNERS', 'Parceiros', 'Ofertas exclusivas', 'local_offer', 3, true,
     '["partners_list", "partner_detail"]',
     '{"showInHome": true, "color": "#FF9800"}', CURRENT_TIMESTAMP),
    ('mod-basic-verification', 'plan-basic', 'VERIFICATION', 'Código de Verificação', 'Login no computador', 'verified_user', 4, true,
     '["verification_code"]',
     '{"showInHome": true, "color": "#9C27B0"}', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Módulos do Plano Completo (todos os básicos + extras)
INSERT INTO plan_modules (id, plan_id, module_type, display_name, description, icon_name, display_order, enabled, show_badge, badge_text, routes, ui_hints, created_at)
VALUES 
    ('mod-full-wallet', 'plan-full', 'WALLET', 'Carteiras', 'Gerencie seus saldos', 'wallet', 1, true, false, null,
     '["wallet_list", "wallet_detail", "wallet_transfer"]',
     '{"showInHome": true, "color": "#4CAF50"}', CURRENT_TIMESTAMP),
    ('mod-full-cards', 'plan-full', 'CARDS', 'Cartões', 'Seus cartões de benefício', 'credit_card', 2, true, false, null,
     '["cards_list", "card_detail", "card_virtual_create"]',
     '{"showInHome": true, "color": "#2196F3"}', CURRENT_TIMESTAMP),
    ('mod-full-corporate', 'plan-full', 'CORPORATE_SPEND', 'Cartão Corporativo', 'Despesas da empresa', 'business', 3, true, true, 'Novo',
     '["corporate_request", "corporate_expenses", "corporate_receipts"]',
     '{"showInHome": true, "color": "#673AB7"}', CURRENT_TIMESTAMP),
    ('mod-full-partners', 'plan-full', 'PARTNERS', 'Parceiros', 'Ofertas exclusivas', 'local_offer', 4, true, false, null,
     '["partners_list", "partner_detail"]',
     '{"showInHome": true, "color": "#FF9800"}', CURRENT_TIMESTAMP),
    ('mod-full-advance', 'plan-full', 'ADVANCE', 'Antecipar FGTS', 'Antecipe seu FGTS', 'attach_money', 5, true, true, 'Promo',
     '["advance_fgts"]',
     '{"showInHome": true, "color": "#00BCD4"}', CURRENT_TIMESTAMP),
    ('mod-full-loans', 'plan-full', 'LOANS', 'Meus Empréstimos', 'Empréstimos disponíveis', 'account_balance', 6, true, false, null,
     '["loans_list", "loan_simulate"]',
     '{"showInHome": true, "color": "#795548"}', CURRENT_TIMESTAMP),
    ('mod-full-nutrition', 'plan-full', 'NUTRITION', 'Flash Nutri', 'Programa nutricional', 'restaurant', 7, true, true, 'Novo',
     '["nutrition_program"]',
     '{"showInHome": true, "color": "#8BC34A"}', CURRENT_TIMESTAMP),
    ('mod-full-verification', 'plan-full', 'VERIFICATION', 'Código de Verificação', 'Login no computador', 'verified_user', 8, true, false, null,
     '["verification_code"]',
     '{"showInHome": true, "color": "#9C27B0"}', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 5. DEFINIÇÕES DE CARTEIRA
-- =====================================================
-- Carteiras do Plano Básico
INSERT INTO wallet_definitions (id, plan_id, wallet_type, display_name, description, currency, icon_name, color_hex, display_order, visible_in_home, mcc_allowed, daily_suggested_spend_enabled, enabled, created_at)
VALUES 
    ('wdef-basic-flex', 'plan-basic', 'FLEX', 'Benefício Flexível', 'Use em qualquer estabelecimento', 'BRL', 'account_balance_wallet', '#4CAF50', 1, true,
     null, true, true, CURRENT_TIMESTAMP),
    ('wdef-basic-meal', 'plan-basic', 'MEAL', 'Vale Refeição', 'Restaurantes e lanchonetes', 'BRL', 'restaurant', '#FF5722', 2, true,
     '[5411, 5812, 5813, 5814]', true, true, CURRENT_TIMESTAMP),
    ('wdef-basic-food', 'plan-basic', 'FOOD', 'Vale Alimentação', 'Supermercados e mercearias', 'BRL', 'shopping_cart', '#2196F3', 3, true,
     '[5411, 5422, 5441, 5451, 5462]', true, true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Carteiras do Plano Completo (mais opções)
INSERT INTO wallet_definitions (id, plan_id, wallet_type, display_name, description, currency, icon_name, color_hex, display_order, visible_in_home, mcc_allowed, daily_limit, monthly_limit, daily_suggested_spend_enabled, enabled, created_at)
VALUES 
    ('wdef-full-flex', 'plan-full', 'FLEX', 'Benefício Flexível', 'Use em qualquer estabelecimento', 'BRL', 'account_balance_wallet', '#4CAF50', 1, true,
     null, null, null, true, true, CURRENT_TIMESTAMP),
    ('wdef-full-meal', 'plan-full', 'MEAL', 'Vale Refeição', 'Restaurantes e lanchonetes', 'BRL', 'restaurant', '#FF5722', 2, true,
     '[5411, 5812, 5813, 5814]', null, null, true, true, CURRENT_TIMESTAMP),
    ('wdef-full-food', 'plan-full', 'FOOD', 'Vale Alimentação', 'Supermercados e mercearias', 'BRL', 'shopping_cart', '#2196F3', 3, true,
     '[5411, 5422, 5441, 5451, 5462]', null, null, true, true, CURRENT_TIMESTAMP),
    ('wdef-full-mobility', 'plan-full', 'MOBILITY', 'Mobilidade', 'Transporte e combustível', 'BRL', 'directions_car', '#9C27B0', 4, true,
     '[4111, 4121, 4131, 5541, 5542]', 200.00, null, false, true, CURRENT_TIMESTAMP),
    ('wdef-full-culture', 'plan-full', 'CULTURE', 'Cultura', 'Livros, cinema, shows', 'BRL', 'theater_comedy', '#E91E63', 5, true,
     '[5192, 5733, 5735, 5815, 7832, 7922, 7929, 7941]', null, null, false, true, CURRENT_TIMESTAMP),
    ('wdef-full-corporate', 'plan-full', 'CORPORATE', 'Conta Corporativa', 'Despesas da empresa', 'BRL', 'business_center', '#673AB7', 6, true,
     null, 1000.00, 5000.00, false, true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 6. PROGRAMAS DE CARTÃO
-- =====================================================
INSERT INTO card_programs (id, plan_id, name, card_type, display_name, card_brand, user_can_create, max_cards_per_user, default_daily_limit, features, linked_wallet_types, enabled, created_at)
VALUES 
    ('cprog-basic-physical', 'plan-basic', 'Cartão Físico Básico', 'PHYSICAL', 'Cartão Físico', 'MASTERCARD', false, 1, 2000.00,
     '["CONTACTLESS", "CHIP"]', '["FLEX", "MEAL", "FOOD"]', true, CURRENT_TIMESTAMP),
    ('cprog-basic-virtual', 'plan-basic', 'Cartão Virtual Básico', 'VIRTUAL', 'Cartão Virtual de Benefícios', 'MASTERCARD', true, 1, 1000.00,
     '["ONLINE", "TOKENIZATION"]', '["FLEX", "MEAL", "FOOD"]', true, CURRENT_TIMESTAMP),
    ('cprog-full-physical', 'plan-full', 'Cartão Físico Premium', 'PHYSICAL', 'Cartão Físico Premium', 'VISA', false, 1, 5000.00,
     '["CONTACTLESS", "CHIP", "INTERNATIONAL"]', '["FLEX", "MEAL", "FOOD", "MOBILITY", "CULTURE", "CORPORATE"]', true, CURRENT_TIMESTAMP),
    ('cprog-full-virtual', 'plan-full', 'Cartão Virtual Premium', 'VIRTUAL', 'Cartão Virtual', 'VISA', true, 5, 3000.00,
     '["ONLINE", "TOKENIZATION", "INTERNATIONAL"]', '["FLEX", "MEAL", "FOOD", "MOBILITY", "CULTURE", "CORPORATE"]', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 7. PARCEIROS E OFERTAS
-- =====================================================
INSERT INTO partner_catalogs (id, tenant_id, name, short_description, logo_url, banner_url, partner_type, category, redirect_url, cta_text, cta_url, display_order, is_featured, offer_info, tags, enabled, created_at)
VALUES 
    ('partner-fgts', null, 'Antecipe seu FGTS', 'Antecipe até 10 anos do seu FGTS com as melhores taxas', '/assets/partners/fgts.png', '/assets/banners/fgts-banner.jpg', 'FINANCIAL', 'credito',
     'https://partners.benefits.com/fgts', 'Antecipe Já', 'https://partners.benefits.com/fgts/apply', 1, true,
     '{"maxYears": 10, "minRate": "1.29%"}', '["fgts", "antecipacao", "credito"]', true, CURRENT_TIMESTAMP),
    ('partner-ifood', null, 'iFood', '10% de desconto no primeiro pedido', '/assets/partners/ifood.png', '/assets/banners/ifood-banner.jpg', 'MERCHANT', 'alimentacao',
     'https://www.ifood.com.br', 'Pedir Agora', 'https://www.ifood.com.br', 2, true,
     '{"discount": "10%", "firstOrderOnly": true}', '["alimentacao", "delivery", "restaurante"]', true, CURRENT_TIMESTAMP),
    ('partner-gympass', null, 'Gympass', 'Acesso a milhares de academias', '/assets/partners/gympass.png', '/assets/banners/gympass-banner.jpg', 'SERVICE', 'saude',
     'https://www.gympass.com', 'Saiba Mais', 'https://www.gympass.com/benefits', 3, false,
     '{"discount": "30%", "monthlyFee": true}', '["saude", "academia", "bem-estar"]', true, CURRENT_TIMESTAMP),
    ('partner-alura', null, 'Alura', 'Cursos de tecnologia com 20% off', '/assets/partners/alura.png', '/assets/banners/alura-banner.jpg', 'SERVICE', 'educacao',
     'https://www.alura.com.br', 'Estudar Agora', 'https://www.alura.com.br/benefits', 4, false,
     '{"discount": "20%", "courses": "1000+"}', '["educacao", "tecnologia", "cursos"]', true, CURRENT_TIMESTAMP),
    ('partner-nubank', null, 'Empréstimo Nubank', 'Empréstimo pessoal com taxa a partir de 1.49%', '/assets/partners/nubank.png', '/assets/banners/nubank-banner.jpg', 'FINANCIAL', 'credito',
     'https://nubank.com.br/emprestimo', 'Simular Agora', 'https://nubank.com.br/emprestimo/simular', 5, true,
     '{"minRate": "1.49%", "maxAmount": 50000}', '["emprestimo", "credito", "pessoal"]', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 8. FEATURE FLAGS GLOBAIS
-- =====================================================
INSERT INTO feature_flags (id, key, value, scope, scope_id, description, rollout_percentage, created_at)
VALUES 
    ('ff-virtual-card', 'ENABLE_VIRTUAL_CARD', true, 'GLOBAL', null, 'Habilita criação de cartão virtual', 100, CURRENT_TIMESTAMP),
    ('ff-corporate', 'ENABLE_CORPORATE_SPEND', true, 'GLOBAL', null, 'Habilita módulo corporativo', 100, CURRENT_TIMESTAMP),
    ('ff-partners', 'ENABLE_PARTNERS', true, 'GLOBAL', null, 'Habilita seção de parceiros', 100, CURRENT_TIMESTAMP),
    ('ff-verification', 'ENABLE_VERIFICATION_CODE', true, 'GLOBAL', null, 'Habilita código de verificação para web', 100, CURRENT_TIMESTAMP),
    ('ff-biometric', 'ENABLE_BIOMETRIC_LOGIN', true, 'GLOBAL', null, 'Habilita login biométrico', 100, CURRENT_TIMESTAMP),
    ('ff-advance-fgts', 'ENABLE_FGTS_ADVANCE', true, 'GLOBAL', null, 'Habilita antecipação de FGTS', 50, CURRENT_TIMESTAMP),
    ('ff-nutrition', 'ENABLE_NUTRITION_PROGRAM', true, 'GLOBAL', null, 'Habilita programa nutricional', 30, CURRENT_TIMESTAMP)
ON CONFLICT (key, scope, scope_id) DO UPDATE SET value = EXCLUDED.value, updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 9. ATRIBUIÇÃO DE PLANOS AOS TENANTS
-- =====================================================
INSERT INTO plan_assignments (id, plan_id, tenant_id, employer_id, status, assigned_at, created_at)
VALUES 
    ('pa-acme-full', 'plan-full', 'tenant-acme', null, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('pa-globex-basic', 'plan-basic', 'tenant-globex', null, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 10. USUÁRIOS DE TESTE
-- =====================================================
INSERT INTO users (id, keycloakid, email, name, cpf, phone, status, createdat, updatedat)
VALUES 
    ('user-001', 'user1-keycloak-id', 'user1@test.com', 'João Silva', '123.456.789-00', '11999990001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('user-002', 'user2-keycloak-id', 'user2@test.com', 'Maria Santos', '987.654.321-00', '11999990002', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('user-003', 'user3-keycloak-id', 'user3@test.com', 'Pedro Oliveira', '456.789.123-00', '11999990003', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updatedat = CURRENT_TIMESTAMP;

-- =====================================================
-- 11. MERCHANTS DE TESTE
-- =====================================================
INSERT INTO merchants (id, keycloakid, name, cnpj, email, phone, mcc, status, kybstatus, createdat, updatedat)
VALUES 
    ('merchant-001', 'merchant1-keycloak-id', 'Restaurante Bom Sabor', '11.222.333/0001-81', 'contato@bomsabor.com', '1133330001', '5812', 'ACTIVE', 'APPROVED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('merchant-002', 'merchant2-keycloak-id', 'Supermercado Central', '22.333.444/0001-82', 'contato@central.com', '1133330002', '5411', 'ACTIVE', 'APPROVED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updatedat = CURRENT_TIMESTAMP;

-- =====================================================
-- 12. WALLETS DOS USUÁRIOS (com saldo)
-- =====================================================
INSERT INTO wallets (id, user_id, tenant_id, wallet_type, balance, currency, status, created_at, updated_at)
VALUES 
    -- User 1 - ACME (plano full)
    ('wallet-001-flex', 'user-001', 'tenant-acme', 'FLEX', 1500.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-001-meal', 'user-001', 'tenant-acme', 'MEAL', 800.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-001-food', 'user-001', 'tenant-acme', 'FOOD', 600.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-001-corporate', 'user-001', 'tenant-acme', 'CORPORATE', 0.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    -- User 2 - Globex (plano basic)
    ('wallet-002-flex', 'user-002', 'tenant-globex', 'FLEX', 500.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('wallet-002-meal', 'user-002', 'tenant-globex', 'MEAL', 300.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    -- User 3 - Sem saldo
    ('wallet-003-flex', 'user-003', 'tenant-acme', 'FLEX', 0.00, 'BRL', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET balance = EXCLUDED.balance, updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- 13. TRANSAÇÕES DE EXEMPLO
-- =====================================================
INSERT INTO transactions (id, tenant_id, user_id, wallet_id, merchant_id, amount, type, status, description, createdat)
VALUES 
    -- Créditos (topups)
    ('txn-credit-001', 'tenant-acme', 'user-001', 'wallet-001-flex', null, 2000.00, 'CREDIT', 'COMPLETED', 'Crédito mensal - Flexível', CURRENT_TIMESTAMP - INTERVAL '30 days'),
    ('txn-credit-002', 'tenant-acme', 'user-001', 'wallet-001-meal', null, 1000.00, 'CREDIT', 'COMPLETED', 'Crédito mensal - VR', CURRENT_TIMESTAMP - INTERVAL '30 days'),
    -- Débitos (pagamentos)
    ('txn-debit-001', 'tenant-acme', 'user-001', 'wallet-001-flex', 'merchant-001', -45.90, 'DEBIT', 'COMPLETED', 'Restaurante Bom Sabor', CURRENT_TIMESTAMP - INTERVAL '2 days'),
    ('txn-debit-002', 'tenant-acme', 'user-001', 'wallet-001-meal', 'merchant-001', -32.50, 'DEBIT', 'COMPLETED', 'Restaurante Bom Sabor', CURRENT_TIMESTAMP - INTERVAL '1 day'),
    ('txn-debit-003', 'tenant-acme', 'user-001', 'wallet-001-food', 'merchant-002', -156.78, 'DEBIT', 'COMPLETED', 'Supermercado Central', CURRENT_TIMESTAMP - INTERVAL '5 hours'),
    ('txn-debit-004', 'tenant-acme', 'user-001', 'wallet-001-flex', 'merchant-002', -89.90, 'DEBIT', 'COMPLETED', 'Supermercado Central', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
    -- Estorno
    ('txn-refund-001', 'tenant-acme', 'user-001', 'wallet-001-flex', 'merchant-001', 15.00, 'REFUND', 'COMPLETED', 'Estorno parcial - Restaurante Bom Sabor', CURRENT_TIMESTAMP - INTERVAL '1 day'),
    -- Transações do user 2
    ('txn-credit-003', 'tenant-globex', 'user-002', 'wallet-002-flex', null, 600.00, 'CREDIT', 'COMPLETED', 'Crédito mensal', CURRENT_TIMESTAMP - INTERVAL '15 days'),
    ('txn-debit-005', 'tenant-globex', 'user-002', 'wallet-002-flex', 'merchant-001', -100.00, 'DEBIT', 'COMPLETED', 'Restaurante Bom Sabor', CURRENT_TIMESTAMP - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 14. CARTÕES DOS USUÁRIOS
-- =====================================================
INSERT INTO cards (id, user_id, tenant_id, card_type, card_brand, last_four, expiry_month, expiry_year, status, is_frozen, created_at)
VALUES 
    ('card-001-physical', 'user-001', 'tenant-acme', 'PHYSICAL', 'VISA', '4532', 12, 2028, 'ACTIVE', false, CURRENT_TIMESTAMP),
    ('card-001-virtual', 'user-001', 'tenant-acme', 'VIRTUAL', 'VISA', '8876', 6, 2027, 'ACTIVE', false, CURRENT_TIMESTAMP),
    ('card-002-physical', 'user-002', 'tenant-globex', 'PHYSICAL', 'MASTERCARD', '1234', 3, 2028, 'ACTIVE', false, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 15. PEDIDO CORPORATIVO PENDENTE
-- =====================================================
INSERT INTO corporate_requests (id, tenant_id, user_id, employer_id, request_type, amount, reason, status, created_at)
VALUES 
    ('corp-req-001', 'tenant-acme', 'user-001', 'employer-acme-001', 'BALANCE_REQUEST', 500.00, 'Viagem a trabalho - São Paulo', 'PENDING', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 16. DESPESA COM RECIBO PENDENTE
-- =====================================================
INSERT INTO expenses (id, tenant_id, user_id, transaction_id, amount, category, description, receipt_url, status, created_at)
VALUES 
    ('expense-001', 'tenant-acme', 'user-001', 'txn-debit-001', 45.90, 'ALIMENTACAO', 'Almoço com cliente', '/receipts/expense-001.jpg', 'SUBMITTED', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 17. TERMINAIS E OPERADORES
-- =====================================================
INSERT INTO terminals (id, merchantid, terminalid, name, location, status, createdat)
VALUES 
    ('terminal-001', 'merchant-001', 'TERM-001', 'Caixa 1', 'Entrada principal', 'ACTIVE', CURRENT_TIMESTAMP),
    ('terminal-002', 'merchant-002', 'TERM-002', 'Caixa Central', 'Corredor principal', 'ACTIVE', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

INSERT INTO operators (id, merchantid, terminalid, keycloakid, name, role, status, createdat)
VALUES 
    ('operator-001', 'merchant-001', 'terminal-001', 'operator1-keycloak-id', 'Carlos Operador', 'CASHIER', 'ACTIVE', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 18. DEVICES DO USUÁRIO
-- =====================================================
INSERT INTO devices (id, userid, deviceid, devicename, devicetype, osversion, appversion, istrusted, trustedat, lastseenAt, createdat)
VALUES 
    ('device-001', 'user-001', 'device-abc123', 'iPhone 14 Pro', 'IOS', '17.0', '1.5.0', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('device-002', 'user-001', 'device-def456', 'Samsung Galaxy S23', 'ANDROID', '14', '1.5.0', false, null, CURRENT_TIMESTAMP - INTERVAL '7 days', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

COMMIT;

-- =====================================================
-- FIM DO SEED
-- =====================================================
-- Para verificar os dados criados:
-- SELECT * FROM tenants;
-- SELECT * FROM plans;
-- SELECT * FROM plan_modules WHERE plan_id = 'plan-full';
-- SELECT * FROM wallet_definitions;
-- SELECT * FROM partner_catalogs WHERE is_featured = true;
-- SELECT * FROM users;
-- SELECT * FROM wallets WHERE user_id = 'user-001';
-- SELECT * FROM transactions WHERE user_id = 'user-001' ORDER BY createdat DESC;
