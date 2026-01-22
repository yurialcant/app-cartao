-- V002__Insert_sample_data.sql
-- Sample data for development and testing

-- Insert sample persons for different tenants
INSERT INTO persons (person_id, tenant_id, created_at, updated_at, version) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'demo-tenant', NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440002', 'demo-tenant', NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440003', 'demo-tenant', NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440004', 'demo-tenant', NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440005', 'demo-tenant', NOW(), NOW(), 1);

-- Insert sample identity links
INSERT INTO identity_links (person_id, issuer, subject, tenant_id, verified, created_at, updated_at, version) VALUES
-- Lucas (Employer)
('550e8400-e29b-41d4-a716-446655440001', 'email', 'lucas@empresa.com', 'demo-tenant', true, NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440001', 'cpf', '12345678901', 'demo-tenant', true, NOW(), NOW(), 1),

-- Maria (Employee)
('550e8400-e29b-41d4-a716-446655440002', 'email', 'maria@empresa.com', 'demo-tenant', true, NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440002', 'cpf', '23456789012', 'demo-tenant', true, NOW(), NOW(), 1),

-- João (Employee)
('550e8400-e29b-41d4-a716-446655440003', 'email', 'joao@empresa.com', 'demo-tenant', true, NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440003', 'cpf', '34567890123', 'demo-tenant', true, NOW(), NOW(), 1),

-- Ana (Employee)
('550e8400-e29b-41d4-a716-446655440004', 'email', 'ana@empresa.com', 'demo-tenant', true, NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440004', 'cpf', '45678901234', 'demo-tenant', true, NOW(), NOW(), 1),

-- Pedro (Employee)
('550e8400-e29b-41d4-a716-446655440005', 'email', 'pedro@empresa.com', 'demo-tenant', true, NOW(), NOW(), 1),
('550e8400-e29b-41d4-a716-446655440005', 'cpf', '56789012345', 'demo-tenant', true, NOW(), NOW(), 1);