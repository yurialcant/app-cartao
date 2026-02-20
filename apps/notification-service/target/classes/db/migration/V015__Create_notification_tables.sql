-- V015__Create_notification_tables.sql
-- Create notification and messaging tables

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    user_id UUID NOT NULL REFERENCES persons(id),
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    data JSONB,
    read_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    template_key VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    body TEXT NOT NULL,
    variables TEXT[],
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_notifications_tenant_id ON notifications(tenant_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_read_at ON notifications(read_at);
CREATE INDEX idx_notifications_sent_at ON notifications(sent_at);

CREATE INDEX idx_notification_templates_tenant_id ON notification_templates(tenant_id);
CREATE INDEX idx_notification_templates_template_key ON notification_templates(template_key);

-- Sample data
INSERT INTO notification_templates (tenant_id, template_key, name, subject, body, variables) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'EXPENSE_APPROVED', 'Expense Approved', 'Your expense has been approved', 'Dear {{user_name}}, your expense of {{amount}} has been approved.', ARRAY['user_name', 'amount']),
('550e8400-e29b-41d4-a716-446655440000', 'EXPENSE_REJECTED', 'Expense Rejected', 'Your expense has been rejected', 'Dear {{user_name}}, your expense of {{amount}} has been rejected. Reason: {{reason}}', ARRAY['user_name', 'amount', 'reason']),
('550e8400-e29b-41d4-a716-446655440000', 'PAYMENT_RECEIVED', 'Payment Received', 'Payment received', 'Dear {{user_name}}, we have received your payment of {{amount}}.', ARRAY['user_name', 'amount']);