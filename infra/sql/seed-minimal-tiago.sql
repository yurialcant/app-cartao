-- SEED MINIMALISTA PARA TESTES - Tiago Tiede
-- Compatível com schema real do banco

-- Tenant
INSERT INTO tenants (id, name, status, created_at, updated_at)
VALUES ('tenant-flash', 'Flash Benefícios', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Usuário Tiago com UUID válido
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1'::uuid, 'tiago-keycloak-id', 'tiago.tiede@flash.com', 'Tiago Tiede', '12345678900', '11999887766', 'ACTIVE', 'tenant-flash', 'tiago.tiede', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET email = 'tiago.tiede@flash.com', updated_at = CURRENT_TIMESTAMP;

-- Carteira do Tiago (R$ 111,85 = 111.85)
INSERT INTO wallets (id, user_id, tenant_id, balance, currency, last_updated, version)
VALUES 
    ('wallet-tiago-001', 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1'::uuid::varchar, 'tenant-flash', 111.85, 'BRL', CURRENT_TIMESTAMP, 1)
ON CONFLICT (id) DO UPDATE SET balance = 111.85, last_updated = CURRENT_TIMESTAMP;

-- Merchants
INSERT INTO merchants (id, keycloak_id, name, cnpj, email, phone, mcc, status, tenant_id, category, created_at, updated_at)
VALUES 
    ('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1'::uuid, 'ikd-keycloak-id', 'IKD', '11.222.333/0001-44', 'ikd@merchants.com', '1133334444', '5812', 'ACTIVE', 'tenant-flash', 'RESTAURANT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1'::uuid, 'littlepaul-keycloak-id', 'LITTLE PAUL', '22.333.444/0001-55', 'littlepaul@merchants.com', '1133335555', '5812', 'ACTIVE', 'tenant-flash', 'RESTAURANT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (cnpj) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Admin
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1'::uuid, 'admin-keycloak-id', 'admin@flash.com', 'Admin Flash', '99999999999', '11999999999', 'ACTIVE', 'tenant-flash', 'admin.flash', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

-- Merchant User
INSERT INTO users (id, keycloak_id, email, full_name, cpf, phone, status, tenant_id, username, created_at, updated_at)
VALUES 
    ('e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1'::uuid, 'merchant-keycloak-id', 'merchant@flash.com', 'Merchant POS', '88888888888', '11988888888', 'ACTIVE', 'tenant-flash', 'merchant.pos', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (keycloak_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP;

COMMIT;

-- Ver resultados
SELECT 'USERS:' as tabela, COUNT(*) as total FROM users
UNION ALL
SELECT 'MERCHANTS:', COUNT(*) FROM merchants
UNION ALL
SELECT 'WALLETS:', COUNT(*) FROM wallets
UNION ALL
SELECT 'TENANTS:', COUNT(*) FROM tenants;

SELECT 'Usuário Tiago criado!' as status, full_name, email, username FROM users WHERE email = 'tiago.tiede@flash.com';
SELECT 'Saldo da carteira:' as status, id, balance, currency FROM wallets WHERE user_id = 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1'::uuid::varchar;
