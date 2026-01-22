-- V006__Insert_sample_merchants_and_terminals.sql
-- Sample data for F06 POS Authorize testing

-- Insert sample merchants
INSERT INTO merchants (id, tenant_id, merchant_id, name, status, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440000', 'MERCH001', 'Restaurante Sabor Caseiro', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440000', 'MERCH002', 'Loja de Conveniência 24h', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440000', 'MERCH003', 'Supermercado Popular', 'ACTIVE', NOW(), NOW());

-- Insert sample terminals for merchants
INSERT INTO terminals (id, merchant_id, terminal_id, location, status, created_at, updated_at) VALUES
-- Restaurante Sabor Caseiro terminals
('550e8400-e29b-41d4-a716-446655440101', '550e8400-e29b-41d4-a716-446655440006', 'TERM001', 'Mesa 1', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440102', '550e8400-e29b-41d4-a716-446655440006', 'TERM002', 'Mesa 2', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440103', '550e8400-e29b-41d4-a716-446655440006', 'TERM003', 'Balcão', 'ACTIVE', NOW(), NOW()),

-- Loja de Conveniência terminals
('550e8400-e29b-41d4-a716-446655440104', '550e8400-e29b-41d4-a716-446655440007', 'TERM101', 'Caixa 1', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440105', '550e8400-e29b-41d4-a716-446655440007', 'TERM102', 'Caixa 2', 'ACTIVE', NOW(), NOW()),

-- Supermercado terminals
('550e8400-e29b-41d4-a716-446655440106', '550e8400-e29b-41d4-a716-446655440008', 'TERM201', 'Caixa Express', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440107', '550e8400-e29b-41d4-a716-446655440008', 'TERM202', 'Caixa Principal', 'ACTIVE', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440108', '550e8400-e29b-41d4-a716-446655440008', 'TERM203', 'Self-Checkout 1', 'ACTIVE', NOW(), NOW());