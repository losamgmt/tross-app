# Database Architecture & Schema Management

**Last Updated:** October 20, 2025  
**Status:** ✅ Production-Ready

## 🎯 Architectural Principles

### 1. **System-Level Fields (Universal)**

Every entity in TrossApp follows this pattern:

```sql
CREATE TABLE entity_name (
    id SERIAL PRIMARY KEY,                          -- Unique identifier
    name VARCHAR(X) UNIQUE NOT NULL,                -- Human-readable identifier
    -- ... entity-specific fields ...
    is_active BOOLEAN DEFAULT true,                 -- Soft delete capability
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Creation tracking
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Modification tracking
);
```

**Benefits:**

- ✅ Consistent deactivation pattern (soft deletes)
- ✅ Audit trail for all entities
- ✅ Easy filtering of active records
- ✅ Predictable API responses

### 2. **Single Source of Truth**

- **Master Schema:** `backend/schema.sql`
- **Applied To:** Both `trossapp_dev` (port 5433) and `trossapp_test` (port 5434)
- **Enforcement:** Automated via `backend/scripts/apply-schema.js`

### 3. **Migration Strategy**

- **Migrations:** `backend/migrations/*.sql`
- **Naming:** `001_description.sql`, `002_description.sql`, etc.
- **Idempotent:** Safe to run multiple times
- **Documented:** Each migration explains WHAT and WHY

## 📊 Current Schema

### **Roles Table**

```sql
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,        -- ✨ System-level field
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- ✨ System-level field
);
```

**Core Roles:**

1. `admin` - Full system access and user management
2. `manager` - Full data access, manages work orders and technicians
3. `dispatcher` - Medium access, assigns and schedules work orders
4. `technician` - Limited access, updates assigned work orders
5. `client` - Basic access, submits and tracks service requests

### **Users Table**

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,    -- Name equivalent
    auth0_id VARCHAR(255) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id INTEGER REFERENCES roles(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,        -- ✨ System-level field
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- ✨ System-level field
);
```

### **Audit Logs Table**

```sql
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(100),
    resource_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    result VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Refresh Tokens Table**

```sql
CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT true,        -- ✨ System-level field
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP,
    revoked_at TIMESTAMP
);
```

## 🔧 Database Management

### **Development Database**

- **Container:** `trossapp-postgres`
- **Port:** 5433
- **Database:** `trossapp_dev`
- **User:** `postgres` / `postgres`

### **Test Database**

- **Container:** `trossapp-postgres-test`
- **Port:** 5434
- **Database:** `trossapp_test`
- **User:** `test_user` / `test_password`

### **Commands**

#### Start Databases

```bash
npm run db:start          # Start dev database
npm run db:test:start     # Start test database
docker ps                 # Verify both running
```

#### Apply Schema (Both Databases)

```bash
node backend/scripts/apply-schema.js           # Apply to BOTH
node backend/scripts/apply-schema.js --dev-only   # Dev only
node backend/scripts/apply-schema.js --test-only  # Test only
```

#### Reset Databases (Clean Slate)

```bash
npm run db:reset          # Dev: Drop, recreate, apply schema
npm run db:test:reset     # Test: Drop, recreate, apply schema
```

#### Check Status

```bash
npm run db:status         # Check dev database health
docker ps                 # Check container health
```

## 🛡️ Schema Consistency Protection

### **1. Pre-Commit Hook (Future)**

```bash
# .git/hooks/pre-commit
# Verify schema.sql is syntactically valid
node backend/scripts/validate-schema.js
```

### **2. CI/CD Pipeline**

```yaml
# In .github/workflows/ci.yml
- name: Verify Schema Consistency
  run: |
    npm run db:test:start
    node backend/scripts/apply-schema.js --test-only
    npm run test:integration
```

### **3. Developer Workflow**

When adding a new table:

1. ✅ Update `backend/schema.sql` (single source of truth)
2. ✅ Add migration in `backend/migrations/` (for existing databases)
3. ✅ Run `node backend/scripts/apply-schema.js` (apply to both DBs)
4. ✅ Update backend models in `backend/db/models/`
5. ✅ Add tests for new entity

### **4. Automatic updated_at Triggers**

All tables with `updated_at` automatically maintain timestamps:

```sql
CREATE TRIGGER update_<table>_updated_at
    BEFORE UPDATE ON <table>
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## 🎨 Best Practices

### **Soft Deletes (is_active)**

Instead of `DELETE FROM users WHERE id = 1`:

```sql
UPDATE users SET is_active = false WHERE id = 1;
```

**Benefits:**

- ✅ Data preservation for audit trails
- ✅ Easy restoration if needed
- ✅ Maintains referential integrity
- ✅ Prevents orphaned foreign keys

### **Querying Active Records**

Always filter by `is_active` in queries:

```sql
SELECT * FROM users WHERE is_active = true;
SELECT * FROM roles WHERE is_active = true;
```

**Index Support:**

```sql
CREATE INDEX idx_users_active ON users(is_active);
CREATE INDEX idx_roles_active ON roles(is_active);
```

### **Foreign Key Protection**

```sql
role_id INTEGER REFERENCES roles(id) ON DELETE SET NULL
```

- If role is deleted, user's `role_id` becomes `NULL` (not orphaned)
- Application handles null role appropriately

## 📈 Future Enhancements

### **Phase 8: Production Hardening**

- [ ] Add `deleted_at` timestamp for soft delete auditing
- [ ] Implement database replication (read replicas)
- [ ] Add connection pooling with PgBouncer
- [ ] Set up automated backups with retention policy

### **Phase 9: Work Orders Module**

```sql
CREATE TABLE work_orders (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,           -- Name equivalent
    -- ... entity-specific fields ...
    is_active BOOLEAN DEFAULT true,        -- System-level field
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🚨 Emergency Procedures

### **Database Corrupted**

```bash
# 1. Stop containers
docker-compose down

# 2. Remove volumes (nuclear option)
docker volume prune -f

# 3. Restart with fresh schema
npm run db:start
npm run db:test:start
node backend/scripts/apply-schema.js

# 4. Verify
npm run db:status
```

### **Schema Drift Detected**

```bash
# Compare schemas between dev and test
docker exec trossapp-postgres pg_dump -U postgres -s trossapp_dev > dev_schema.sql
docker exec trossapp-postgres-test pg_dump -U test_user -s trossapp_test > test_schema.sql
diff dev_schema.sql test_schema.sql

# Fix: Reapply canonical schema
node backend/scripts/apply-schema.js
```

## 📚 Related Documentation

- [MVP Scope](./MVP_SCOPE.md)
- [Development Workflow](./DEVELOPMENT_WORKFLOW.md)
- [Testing Guide](./testing/COMPREHENSIVE_TESTING_GUIDE.md)

---

**Maintained by:** TrossApp Development Team  
**Review Cycle:** Every major schema change  
**Contact:** See [CONTRIBUTORS.md](../CONTRIBUTORS.md)
