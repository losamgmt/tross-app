# Test File Split Execution Plan

**Date:** October 17, 2025  
**Status:** Ready to Execute  
**Estimated Time:** 2-3 hours

---

## 🎯 Objective

Split 6 large test files (4,150+ lines total) into 18 focused files (~240 lines each) using consistent 3-part pattern:

- `.crud.test.js` - CRUD operations
- `.validation.test.js` - Validation & constraints
- `.{feature}.test.js` - Specialized features

---

## 📋 Execution Order

### Priority 1: Model Tests (Foundation)

1. User.test.js (847 lines → 3 files)
2. Role.test.js (597 lines → 3 files)

### Priority 2: Route Tests (API Layer)

3. users.test.js (648 lines → 3 files)
4. roles.test.js (789 lines → 3 files)
5. auth.test.js (703 lines → 3 files)

### Priority 3: Service Tests

6. audit-service.test.js (569 lines → 3 files)

---

## 📄 File 1: User.test.js Split

**Current:** `backend/__tests__/unit/db/User.test.js` (847 lines)

**Split Into:**

### 1. `User.crud.test.js` (~300 lines)

```javascript
// Methods: create, createFromAuth0, findOrCreate, findById, findByAuth0Id, getAll, update, delete
describe("User Model - CRUD Operations") -
  describe("create()") -
  describe("createFromAuth0()") -
  describe("findOrCreate()") -
  describe("findById()") -
  describe("findByAuth0Id()") -
  describe("getAll()") -
  describe("update()") -
  describe("delete()");
```

### 2. `User.validation.test.js` (~300 lines)

```javascript
// Validation: Required fields, email format, constraints, error handling
describe('User Model - Validation')
  - describe('create() validation')
    - Missing email
    - Invalid email format
    - Duplicate email
  - describe('update() validation')
    - Invalid fields
    - Email conflicts
  - describe('Error handling')
    - Database errors
    - Constraint violations
```

### 3. `User.relationships.test.js` (~250 lines)

```javascript
// Relationships: Role assignment, foreign keys, joins
describe('User Model - Relationships')
  - describe('setRole()')
    - Set role successfully
    - Invalid role
    - Clear role (null)
  - describe('Role queries')
    - Find users by role
    - Role joins
    - Cascade behavior
```

---

## 📄 File 2: Role.test.js Split

**Current:** `backend/__tests__/unit/models/Role.test.js` (597 lines)

**Split Into:**

### 1. `Role.crud.test.js` (~200 lines)

```javascript
describe("Role Model - CRUD Operations") -
  describe("create()") -
  describe("findById()") -
  describe("findByName()") -
  describe("getAll()") -
  describe("update()") -
  describe("delete()");
```

### 2. `Role.validation.test.js` (~200 lines)

```javascript
describe('Role Model - Validation')
  - describe('Protected roles')
    - Cannot delete admin/manager/etc
    - Cannot update protected roles
  - describe('Name validation')
    - Unique name constraint
    - Required fields
  - describe('Error handling')
```

### 3. `Role.relationships.test.js` (~200 lines)

```javascript
describe('Role Model - Relationships')
  - describe('getUsersByRole()')
  - describe('User count queries')
  - describe('Cascade behavior')
    - Delete role with users (should fail)
```

---

## 📄 File 3: users.test.js Split

**Current:** `backend/__tests__/unit/routes/users.test.js` (648 lines)

**Split Into:**

### 1. `users.crud.test.js` (~250 lines)

```javascript
describe("Users Routes - CRUD") -
  describe("GET /api/users") -
  describe("GET /api/users/:id") -
  describe("POST /api/users") -
  describe("PUT /api/users/:id") -
  describe("DELETE /api/users/:id");
```

### 2. `users.validation.test.js` (~200 lines)

```javascript
describe('Users Routes - Validation')
  - describe('Input validation')
    - Invalid email
    - Missing required fields
  - describe('Error responses')
    - 400 Bad Request
    - 404 Not Found
  - describe('Business rules')
```

### 3. `users.relationships.test.js` (~200 lines)

```javascript
describe('Users Routes - Relationships')
  - describe('PUT /api/users/:id/role')
    - Set role successfully
    - Invalid role
    - Authorization checks
```

---

## 📄 File 4: roles.test.js Split

**Current:** `backend/__tests__/unit/routes/roles.test.js` (789 lines)

**Split Into:**

### 1. `roles.crud.test.js` (~300 lines)

```javascript
describe("Roles Routes - CRUD") -
  describe("GET /api/roles") -
  describe("GET /api/roles/:id") -
  describe("POST /api/roles") -
  describe("PUT /api/roles/:id") -
  describe("DELETE /api/roles/:id");
```

### 2. `roles.validation.test.js` (~250 lines)

```javascript
describe('Roles Routes - Validation')
  - describe('Protected role validation')
    - Cannot delete admin
    - Cannot modify protected roles
  - describe('Input validation')
  - describe('Authorization checks')
    - Only admins can create/update/delete
```

### 3. `roles.relationships.test.js` (~240 lines)

```javascript
describe('Roles Routes - Relationships')
  - describe('GET /api/roles/:id/users')
    - List users with role
    - Empty role
    - Pagination
```

---

## 📄 File 5: auth.test.js Split

**Current:** `backend/__tests__/unit/routes/auth.test.js` (703 lines)

**Split Into:**

### 1. `auth.crud.test.js` (~250 lines)

```javascript
describe('Auth Routes - Profile Management')
  - describe('GET /api/auth/me')
    - Get current user
    - With role
  - describe('PUT /api/auth/me')
    - Update profile
    - Cannot change email
    - Cannot change role
```

### 2. `auth.validation.test.js` (~200 lines)

```javascript
describe('Auth Routes - Validation')
  - describe('Token validation')
    - Missing token
    - Invalid token
    - Expired token
  - describe('Permission checks')
    - User can only access own data
    - Admin override
```

### 3. `auth.sessions.test.js` (~250 lines)

```javascript
describe('Auth Routes - Session Management')
  - describe('POST /api/auth/refresh')
    - Refresh token successfully
    - Invalid refresh token
  - describe('POST /api/auth/logout')
  - describe('POST /api/auth/logout-all')
  - describe('GET /api/auth/sessions')
```

---

## 📄 File 6: audit-service.test.js Split

**Current:** `backend/__tests__/unit/services/audit-service.test.js` (569 lines)

**Split Into:**

### 1. `audit-service.crud.test.js` (~200 lines)

```javascript
describe('AuditService - Core Operations')
  - describe('log()')
    - Log with all fields
    - Required fields only
  - describe('logAction()')
    - Generic action logging
```

### 2. `audit-service.validation.test.js` (~200 lines)

```javascript
describe('AuditService - Validation')
  - describe('Input validation')
    - Missing required fields
    - Invalid action types
  - describe('Error handling')
    - Database errors
    - Malformed data
```

### 3. `audit-service.resources.test.js` (~170 lines)

```javascript
describe("AuditService - Resource Logging") -
  describe("User audits") -
  logUserCreated() -
  logUserUpdated() -
  logUserDeleted() -
  describe("Role audits") -
  logRoleCreated() -
  logRoleUpdated() -
  logRoleDeleted();
```

---

## ✅ Success Criteria

- [ ] All 18 new test files created
- [ ] All 6 original files deleted
- [ ] All tests still pass (313/313 unit tests)
- [ ] No file exceeds 300 lines
- [ ] Consistent naming (.crud, .validation, .{feature})
- [ ] Proper test isolation (each file runs independently)

---

## 🚀 Execution Strategy

1. **Create new files** with extracted tests
2. **Run tests** to verify each new file works
3. **Delete old file** only after new files pass
4. **Verify full suite** still passes

**Start with User.test.js as pilot** - if successful, apply pattern to others.

---

**Ready to proceed?**
