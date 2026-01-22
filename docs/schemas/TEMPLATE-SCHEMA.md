# Database Schema Template

**Service**: [Service Name]  
**Database**: PostgreSQL 16  
**Encoding**: UTF-8  

---

## Tables

### `[table_name]`

**Description**: [What this table stores]

**Columns**:

| Column | Type | Nullable | Default | Index | Description |
|--------|------|----------|---------|-------|-------------|
| `[id_field]` | `UUID` | NO | `gen_random_uuid()` | PK | Primary key |
| `tenant_id` | `UUID` | NO | - | IDX | Tenant isolation |
| `created_at` | `TIMESTAMPTZ` | NO | `now()` | IDX | Creation timestamp |
| `created_by` | `VARCHAR(255)` | NO | - | - | Creator user_id |
| `updated_at` | `TIMESTAMPTZ` | YES | - | - | Last update |
| `updated_by` | `VARCHAR(255)` | YES | - | - | Last updater |
| `[business_field]` | `[TYPE]` | [YES\|NO] | - | [IDX\|-] | Field description |
| `version` | `INT` | NO | `1` | - | Optimistic lock |
| `correlation_id` | `UUID` | YES | - | - | Request tracing |
| `metadata_json` | `JSONB` | YES | `'{}'::jsonb` | - | Flexible storage |

**Example**:

```sql
CREATE TABLE [table_name] (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_by VARCHAR(255) NOT NULL,
  updated_at TIMESTAMPTZ,
  updated_by VARCHAR(255),
  [business_fields],
  version INT NOT NULL DEFAULT 1,
  correlation_id UUID,
  metadata_json JSONB DEFAULT '{}'::jsonb,
  
  CONSTRAINT fk_tenant FOREIGN KEY (tenant_id) 
    REFERENCES tenant(tenant_id) ON DELETE CASCADE,
  
  INDEX idx_tenant_created ON tenant_id, created_at DESC
);
```

---

## Indexes

```sql
-- Tenant isolation + filtering
CREATE INDEX idx_[table]_tenant_created 
  ON [table](tenant_id, created_at DESC);

-- Business logic
CREATE INDEX idx_[table]_status 
  ON [table](tenant_id, status) 
  WHERE status IN ('ACTIVE', 'PENDING');

-- Full text search (if needed)
CREATE INDEX idx_[table]_name_fts 
  ON [table] USING GIN (to_tsvector('portuguese', name));
```

---

## Relationships

```
[table_name] (N) ──→ tenant (1)
[table_name] (N) ──→ [other_table] (1)
```

---

## Constraints

- **Primary Key**: `[id_field]`
- **Foreign Keys**: 
  - `tenant_id` → `tenant.tenant_id`
  - `[other_id]` → `[other_table].[other_id]`
- **Unique**: [fields if needed]
- **Check**: [business rules if needed]

---

## Views (if needed)

```sql
CREATE VIEW [view_name] AS
SELECT 
  t.id,
  t.tenant_id,
  t.[field1],
  t.[field2]
FROM [table] t
WHERE t.status = 'ACTIVE';
```

---

## Stored Procedures / Functions (if needed)

```sql
CREATE FUNCTION [function_name](
  p_tenant_id UUID,
  p_[param] TYPE
) RETURNS TABLE (
  result_field TYPE
) AS $$
BEGIN
  RETURN QUERY
  SELECT [fields]
  FROM [table]
  WHERE tenant_id = p_tenant_id;
END;
$$ LANGUAGE plpgsql;
```

---

## Seed Data

```sql
INSERT INTO [table_name] 
  (tenant_id, created_by, [field1], [field2])
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'system', 'value1', 'value2');
```

---

## Migration Notes

**Created**: YYYY-MM-DD  
**Status**: [DRAFT | APPROVED | DEPLOYED]  
**Migration Script**: [filename]  

---

## Monitoring Queries

```sql
-- Table size
SELECT 
  pg_size_pretty(pg_total_relation_size('[table_name]')) AS size;

-- Row count
SELECT COUNT(*) FROM [table_name];

-- Slow queries
SELECT * FROM pg_stat_statements 
WHERE query LIKE '%[table_name]%' 
ORDER BY mean_exec_time DESC;

-- Index usage
SELECT * FROM pg_stat_user_indexes 
WHERE relname = '[table_name]' 
ORDER BY idx_scan DESC;
```

---

## Backup / Recovery

**Backup Strategy**: [Daily full + hourly incremental]  
**Retention**: [30 days]  
**Recovery Time Objective**: [< 1 hour]  

