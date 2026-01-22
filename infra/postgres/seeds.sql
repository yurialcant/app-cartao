-- Seeds for Benefits Platform

-- Clear existing data (if needed)
-- TRUNCATE TABLE users CASCADE;
-- TRUNCATE TABLE tenants CASCADE;
-- TRUNCATE TABLE payment_methods CASCADE;
-- TRUNCATE TABLE transactions CASCADE;

-- Insert Tenants
INSERT INTO tenants (id, name, code, active, created_at) VALUES 
  (1, 'Default Tenant', 'default', true, NOW()),
  (2, 'Enterprise A', 'enterprise_a', true, NOW()),
  (3, 'Enterprise B', 'enterprise_b', true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert Users
INSERT INTO users (id, name, email, phone, document, user_type, tenant_id, active, created_at) VALUES
  (1, 'Admin User', 'admin@fintech.com', '11999999999', '12345678901234', 'ADMIN', 1, true, NOW()),
  (2, 'John Employee', 'john.employee@fintech.com', '11988888888', '12345678901235', 'EMPLOYEE', 1, true, NOW()),
  (3, 'Jane Merchant', 'jane.merchant@fintech.com', '11977777777', '12345678901236', 'MERCHANT', 1, true, NOW()),
  (4, 'Support User', 'support@fintech.com', '11966666666', '12345678901237', 'SUPPORT', 1, true, NOW()),
  (5, 'Finance User', 'finance@fintech.com', '11955555555', '12345678901238', 'FINANCE', 1, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert Payment Methods
INSERT INTO payment_methods (id, user_id, type, account_number, agency, bank_code, is_default, active, created_at) VALUES
  (1, 2, 'BANK_TRANSFER', '123456789', '0001', '001', true, true, NOW()),
  (2, 3, 'BANK_TRANSFER', '987654321', '0002', '033', true, true, NOW()),
  (3, 2, 'PIX', 'john@fintech.com', NULL, NULL, false, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert Transactions
INSERT INTO transactions (id, user_id, amount, status, transaction_type, description, reference_id, created_at, updated_at) VALUES
  (1, 2, 1500.00, 'COMPLETED', 'SALARY', 'Monthly salary deposit', 'REF-001', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
  (2, 2, 500.00, 'COMPLETED', 'BENEFIT', 'Meal voucher benefit', 'REF-002', NOW() - INTERVAL '15 days', NOW() - INTERVAL '15 days'),
  (3, 3, 2500.00, 'PENDING', 'REFUND', 'Refund request', 'REF-003', NOW() - INTERVAL '5 days', NOW()),
  (4, 2, 1000.00, 'COMPLETED', 'SALARY', 'Salary advance', 'REF-004', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day'),
  (5, 3, 3500.00, 'FAILED', 'SETTLEMENT', 'Settlement attempt', 'REF-005', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert Reconciliations
INSERT INTO reconciliations (id, user_id, status, period_start, period_end, total_amount, created_at) VALUES
  (1, 2, 'COMPLETED', '2024-01-01'::DATE, '2024-01-31'::DATE, 3000.00, NOW() - INTERVAL '30 days'),
  (2, 3, 'PENDING', '2024-02-01'::DATE, '2024-02-28'::DATE, 5000.00, NOW())
ON CONFLICT (id) DO NOTHING;

-- Insert Payment Processing Records
INSERT INTO payment_processing (id, payment_id, status, processing_date, retry_count, created_at) VALUES
  (1, 1, 'COMPLETED', NOW() - INTERVAL '30 days', 0, NOW() - INTERVAL '30 days'),
  (2, 3, 'PENDING', NOW(), 1, NOW() - INTERVAL '5 days'),
  (3, 5, 'FAILED', NOW(), 3, NOW())
ON CONFLICT (id) DO NOTHING;

-- Commit
COMMIT;
