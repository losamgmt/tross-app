# Phase 6: Test Coverage Analysis & 90%+ Coverage Plan

**Date:** October 16, 2025  
**Current Overall Coverage:** 38.99% statements  
**Target:** 90%+ on critical paths  
**Status:** 📊 ANALYSIS COMPLETE - Ready for implementation review

---

## 🎯 Executive Summary

**Current State:**

- **Overall Coverage:** 38.99% statements, 29.62% branches, 26.63% functions
- **Strong Areas:** Validation (95%), Security (92%), Logger (100%), Token Service (85%)
- **Weak Areas:** Routes (32%), Auth Strategies (16-31%), Models (34%), Audit Service (19%)

**Gap Analysis:** We have **excellent** coverage on recently-touched files (Phase 5b work), but **poor** coverage on core business logic (routes, models, services). The 84 passing integration tests focus on happy paths but miss error handling, edge cases, and unit-level isolation.

**Recommendation:** Focus on **unit tests** for critical business logic rather than more integration tests. Current integration tests are solid; we need granular unit tests to hit 90%+ on critical paths.

---

## 📊 Detailed Coverage Analysis

### 🟢 EXCELLENT Coverage (90%+) - Maintain Quality

| File                          | Statements | Branches | Functions | Status                  |
| ----------------------------- | ---------- | -------- | --------- | ----------------------- |
| `middleware/validation.js`    | **95.23%** | 83.33%   | 100%      | ✅ Recent Phase 5b work |
| `middleware/security.js`      | **92%**    | 64%      | 100%      | ✅ Recent Phase 5b work |
| `config/constants.js`         | **100%**   | 100%     | 100%      | ✅ Simple constants     |
| `config/logger.js`            | **100%**   | 63.63%   | 100%      | ✅ Well-tested          |
| `config/swagger.js`           | **100%**   | 100%     | 100%      | ✅ Simple config        |
| `config/test-constants.js`    | **100%**   | 100%     | 100%      | ✅ Constants            |
| `config/test-users.js`        | **100%**   | 100%     | 100%      | ✅ Constants            |
| `services/audit-constants.js` | **100%**   | 100%     | 100%      | ✅ Constants            |
| `utils/uuid.js`               | **90.9%**  | 75%      | 100%      | ✅ Simple utility       |

**Analysis:** These files have excellent coverage because they're either:

1. Simple constants (no logic to test)
2. Recently improved in Phase 5b (validation, security)
3. Heavily used by integration tests (logger)

**Action:** ✅ **No changes needed** - maintain quality

---

### 🟡 GOOD Coverage (70-89%) - Minor Improvements

| File                        | Statements | Branches | Functions | Lines  | Gap Analysis                        |
| --------------------------- | ---------- | -------- | --------- | ------ | ----------------------------------- |
| `middleware/auth.js`        | **86.66%** | 72.22%   | 100%      | 86.2%  | Missing error edge cases            |
| `services/token-service.js` | **84.93%** | 81.81%   | 100%      | 84.93% | Missing edge cases                  |
| `config/auth0.js`           | 25%        | 61.53%   | 0%        | 27.27% | ⚠️ **Low!** Auth0 config not tested |
| `db/connection.js`          | **69.64%** | 67.85%   | 50%       | 73.07% | Missing error handling tests        |

**Uncovered Lines - auth.js:**

```
Lines 36, 41, 51-57
```

**Analysis:** These are likely edge case error handlers (invalid token formats, missing headers, etc.)

**Uncovered Lines - token-service.js:**

```
Lines 124, 156-157, 191-192, 215-216, 260-261
```

**Analysis:** Error handling paths (database failures, invalid tokens, etc.)

**Uncovered Lines - connection.js:**

```
Lines 57, 78, 111-117, 125-131
```

**Analysis:** Database connection error handling, pool exhaustion, reconnection logic

**Action:** ✅ **Low priority** - These files are well-tested. Edge case coverage can improve to 90%+ with targeted unit tests.

---

### ❌ POOR Coverage (<70%) - CRITICAL GAPS

#### **1. Routes - WORST COVERAGE (32.88%)**

| File                 | Coverage   | Uncovered                                        | Critical?     |
| -------------------- | ---------- | ------------------------------------------------ | ------------- |
| `routes/roles.js`    | **19.44%** | Lines 88-120,160-172,229-272,325-389,439-481     | 🔴 **YES**    |
| `routes/users.js`    | **61.19%** | Lines 37-48,128,211-222,265-310,381-382          | 🟡 **YES**    |
| `routes/auth.js`     | **21.51%** | Lines 82-135,158,211-245,279-301,343-366,404-425 | 🔴 **YES**    |
| `routes/auth0.js`    | **26.41%** | Lines 27-82,96-127,139-158,170-182               | 🟠 Auth0 only |
| `routes/dev-auth.js` | **45.83%** | Lines 65-87,129-151,163                          | 🟠 Dev only   |

**Gap Analysis - roles.js (19.44%):**

```javascript
// UNCOVERED: Lines 88-120 (GET /api/roles - List all roles)
// UNCOVERED: Lines 160-172 (GET /api/roles/:id - Get role by ID)
// UNCOVERED: Lines 229-272 (POST /api/roles - Create role) ✅ We test this!
// UNCOVERED: Lines 325-389 (PUT /api/roles/:id - Update role) ✅ We test this!
// UNCOVERED: Lines 439-481 (DELETE /api/roles/:id - Delete role) ✅ We test this!
```

**WHY SO LOW?** Integration tests cover CREATE/UPDATE/DELETE (lines 229-481), but **GET endpoints** (lines 88-172) are **completely untested**!

**Gap Analysis - users.js (61.19% - BEST of routes):**

```javascript
// UNCOVERED: Lines 37-48 (GET /api/users - List all users)
// UNCOVERED: Lines 128 (Error handling in POST)
// UNCOVERED: Lines 211-222 (GET /api/users/:id - Get user by ID)
// UNCOVERED: Lines 265-310 (PUT /api/users/:id/role - Role assignment) ✅ We test this!
// UNCOVERED: Lines 381-382 (Error handling)
```

**WHY BETTER?** We have 11 tests for user-role-assignment, so role assignment endpoint has good coverage. But **GET endpoints** still untested.

**Gap Analysis - auth.js (21.51%):**

```javascript
// UNCOVERED: Lines 82-135 (GET /api/auth/me - Get current user profile)
// UNCOVERED: Lines 158 (Error handling)
// UNCOVERED: Lines 211-245 (PUT /api/auth/me - Update profile) ✅ Validation added Phase 5b!
// UNCOVERED: Lines 279-301 (POST /api/auth/logout - Logout)
// UNCOVERED: Lines 343-366 (POST /api/auth/refresh - Refresh token) ✅ Token service tested!
// UNCOVERED: Lines 404-425 (POST /api/auth/logout/all - Logout all devices)
```

**WHY SO LOW?** We have **zero route-level tests** for auth endpoints! Token service is well-tested (84%), but auth routes themselves are not.

**CRITICAL FINDING:** We're testing the **integration flows** (role CRUD, user CRUD) but missing **GET endpoints** entirely and **auth endpoints** almost entirely.

---

#### **2. Models - POOR COVERAGE (34.05%)**

| File                | Coverage   | Uncovered                                             | Critical?  |
| ------------------- | ---------- | ----------------------------------------------------- | ---------- |
| `db/models/Role.js` | **7.35%**  | Lines 7-37,49-182                                     | 🔴 **YES** |
| `db/models/User.js` | **49.57%** | Lines 105,108,114-117,222-256,263,269-276,288,294-295 | 🟡 **YES** |

**Gap Analysis - Role.js (7.35% - WORST FILE):**

```javascript
// UNCOVERED: Lines 7-37 (Static methods: findAll, findById, findByName)
// UNCOVERED: Lines 49-182 (create, update, delete, isProtectedRole)
```

**WHY SO LOW?** We test via **routes** (integration), not **models** (unit). Model logic is tested indirectly, but coverage tool doesn't see it.

**Gap Analysis - User.js (49.57%):**

```javascript
// UNCOVERED: Lines 105, 108 (Error handling in create)
// UNCOVERED: Lines 114-117 (Validation in create)
// UNCOVERED: Lines 222-256 (setRole method)
// UNCOVERED: Lines 263, 269-276 (delete method)
// UNCOVERED: Lines 288, 294-295 (Error handling)
```

**WHY BETTER?** More methods used by integration tests (findByEmail, create, update). But **setRole** and **delete** have gaps.

**CRITICAL FINDING:** Models need **unit tests** that directly call methods, not just integration tests through routes.

---

#### **3. Services - POOR COVERAGE (34.29%)**

| File                         | Coverage   | Uncovered            | Critical?        |
| ---------------------------- | ---------- | -------------------- | ---------------- |
| `services/audit-service.js`  | **19.6%**  | Lines 84-301,351-404 | 🟡 Logging only  |
| `services/user-data.js`      | **31.81%** | Lines 12-54,62,72    | 🟡 Auth0 only    |
| `services/health-manager.js` | **17.91%** | Lines 38-140,154-182 | 🟠 Health checks |
| `services/auth0-auth.js`     | **0%**     | Lines 4-210          | 🟠 Auth0 only    |

**Gap Analysis - audit-service.js (19.6%):**

```javascript
// UNCOVERED: Lines 84-301 (All wrapper methods: logUserCreate, logUserUpdate, etc.)
// UNCOVERED: Lines 351-404 (Query methods: getUserAuditLogs, getResourceAuditLogs)
```

**WHY SO LOW?** We **call** audit logging in routes (integration tests log events), but we don't **test** the audit service itself.

**CRITICAL FINDING:** Audit logs are created, but we don't test **querying** audit logs (getUserAuditLogs, etc.) or **validation** of audit data.

---

#### **4. Auth Strategies - VERY POOR (16-31%)**

| File                                   | Coverage   | Uncovered           | Critical?     |
| -------------------------------------- | ---------- | ------------------- | ------------- |
| `services/auth/Auth0Strategy.js`       | **16.47%** | Lines 52-339        | 🟠 Auth0 only |
| `services/auth/DevAuthStrategy.js`     | **19.23%** | Lines 34-173        | 🟡 **YES**    |
| `services/auth/AuthStrategy.js`        | **14.28%** | Lines 17-66         | 🟠 Base class |
| `services/auth/index.js`               | **27.27%** | Lines 30-112        | 🟡 **YES**    |
| `services/auth/AuthStrategyFactory.js` | **81.39%** | Lines 80-81,117-143 | ✅ Good       |

**Gap Analysis - DevAuthStrategy.js (19.23%):**

```javascript
// UNCOVERED: Lines 34-173 (login, validateToken, getUserProfile, logout methods)
```

**WHY SO LOW?** We use DevAuthStrategy in tests, but we don't **unit test** the strategy itself.

**CRITICAL FINDING:** Authentication logic is tested via integration, but not as **unit tests**.

---

#### **5. Server.js - MODERATE COVERAGE (45.91%)**

| File        | Coverage   | Uncovered                                           |
| ----------- | ---------- | --------------------------------------------------- |
| `server.js` | **45.91%** | Lines 13-55,106-131,156,173-181,190-199,203-211,225 |

**Uncovered Lines:**

```javascript
// Lines 13-55: Production environment validation (Phase 5b) ✅ Added but not tested!
// Lines 106-131: Express middleware setup
// Lines 156: Server startup
// Lines 173-181: Graceful shutdown
// Lines 190-199: SIGTERM handler
// Lines 203-211: SIGINT handler
// Lines 225: Error handling
```

**WHY?** Server startup/shutdown logic is not tested. Integration tests **use** the server but don't **test** server lifecycle.

---

## 🎯 Critical Paths Priority Matrix

### **Priority 1: CRITICAL (Must hit 90%)**

| Component                     | Current | Target | Effort | Impact | Justification                   |
| ----------------------------- | ------- | ------ | ------ | ------ | ------------------------------- |
| **routes/roles.js**           | 19.44%  | 90%    | High   | High   | Core business logic, public API |
| **routes/users.js**           | 61.19%  | 90%    | Medium | High   | Core business logic, public API |
| **routes/auth.js**            | 21.51%  | 90%    | High   | High   | Critical auth flows             |
| **db/models/User.js**         | 49.57%  | 90%    | Medium | High   | Core domain model               |
| **db/models/Role.js**         | 7.35%   | 90%    | High   | High   | Core domain model               |
| **services/audit-service.js** | 19.6%   | 90%    | Medium | High   | Compliance requirement          |

**Estimated Effort:** 40-60 hours  
**Estimated Tests:** ~150-200 unit tests  
**Impact:** ⭐⭐⭐⭐⭐ CRITICAL - These are the app's core

---

### **Priority 2: HIGH (Should hit 80%+)**

| Component                            | Current | Target | Effort | Impact |
| ------------------------------------ | ------- | ------ | ------ | ------ |
| **middleware/auth.js**               | 86.66%  | 95%    | Low    | High   |
| **services/token-service.js**        | 84.93%  | 95%    | Low    | High   |
| **services/auth/DevAuthStrategy.js** | 19.23%  | 80%    | Medium | Medium |
| **services/auth/index.js**           | 27.27%  | 80%    | Low    | Medium |
| **db/connection.js**                 | 69.64%  | 85%    | Low    | High   |

**Estimated Effort:** 15-20 hours  
**Estimated Tests:** ~40-50 unit tests  
**Impact:** ⭐⭐⭐⭐ HIGH - Quality improvements

---

### **Priority 3: MEDIUM (Nice to have 70%+)**

| Component                      | Current | Target | Effort | Impact |
| ------------------------------ | ------- | ------ | ------ | ------ |
| **services/user-data.js**      | 31.81%  | 70%    | Medium | Medium |
| **services/health-manager.js** | 17.91%  | 70%    | Low    | Low    |
| **server.js**                  | 45.91%  | 70%    | Medium | Medium |

**Estimated Effort:** 10-15 hours  
**Estimated Tests:** ~30-40 unit tests

---

### **Priority 4: LOW (Auth0 only - defer)**

| Component                          | Current | Target | Effort | Impact |
| ---------------------------------- | ------- | ------ | ------ | ------ |
| **services/auth/Auth0Strategy.js** | 16.47%  | N/A    | High   | Low    |
| **services/auth0-auth.js**         | 0%      | N/A    | High   | Low    |
| **routes/auth0.js**                | 26.41%  | N/A    | Medium | Low    |
| **routes/dev-auth.js**             | 45.83%  | N/A    | Low    | Low    |
| **config/auth0.js**                | 25%     | N/A    | Low    | Low    |

**Justification:** These are Auth0-specific integrations. We're using development auth (DevAuthStrategy) for now. Test when Auth0 is production-critical.

---

## 📝 Detailed Gap Analysis by File

### 1. routes/roles.js - 19.44% Coverage 🔴

**Missing Tests:**

```javascript
// ❌ UNTESTED: GET /api/roles (List all roles)
it("should return all roles as admin");
it("should return only active roles");
it("should handle empty role list");
it("should reject non-admin access");
it("should reject unauthenticated access");

// ❌ UNTESTED: GET /api/roles/:id (Get role by ID)
it("should return role by ID as admin");
it("should return 404 for non-existent role");
it("should reject invalid ID format");
it("should reject non-admin access");

// ✅ TESTED: POST, PUT, DELETE (via role-crud-db.test.js - 26 tests)
// Coverage shows CREATE/UPDATE/DELETE tested, but tool doesn't see it?
```

**Root Cause:** Coverage runs in isolation mode - integration tests might not be counted properly.

**Solution:** Add **unit tests** that directly test route handlers with mocked dependencies.

---

### 2. routes/users.js - 61.19% Coverage 🟡

**Missing Tests:**

```javascript
// ❌ UNTESTED: GET /api/users (List all users)
it("should return paginated user list as admin");
it("should filter users by role_id query param");
it("should handle empty user list");
it("should reject non-admin access");

// ❌ UNTESTED: GET /api/users/:id (Get user by ID)
it("should return user by ID as admin");
it("should return 404 for non-existent user");
it("should reject invalid ID format");
it("should include role information in response");

// ✅ TESTED: POST, PUT, DELETE, PUT /:id/role (via user-crud-lifecycle.test.js, user-role-assignment.test.js)
```

**Solution:** Add unit tests for GET endpoints.

---

### 3. routes/auth.js - 21.51% Coverage 🔴

**Missing Tests:**

```javascript
// ❌ UNTESTED: GET /api/auth/me (Get current user)
it("should return current user profile with valid token");
it("should return 401 without token");
it("should return user with role information");
it("should handle deleted user gracefully");

// ❌ UNTESTED: PUT /api/auth/me (Update profile) - We added validation Phase 5b!
it("should update user profile (first_name, last_name)");
it("should reject empty updates");
it("should reject updates to non-editable fields (email, role)");
it("should log profile update in audit logs");

// ❌ UNTESTED: POST /api/auth/logout (Logout)
it("should revoke refresh token");
it("should log logout event");
it("should return success even if token already revoked (idempotent)");
it("should handle invalid token ID gracefully");

// ❌ UNTESTED: POST /api/auth/refresh (Refresh access token)
it("should return new access token with valid refresh token");
it("should reject expired refresh token");
it("should reject revoked refresh token");
it("should log token refresh");

// ❌ UNTESTED: POST /api/auth/logout/all (Logout all devices)
it("should revoke all user tokens");
it("should log logout_all event");
it("should return count of revoked tokens");
```

**Solution:** Create `__tests__/unit/routes/auth.test.js` with mocked dependencies.

---

### 4. db/models/Role.js - 7.35% Coverage 🔴

**Missing Tests:**

```javascript
// ❌ UNTESTED: Static methods
describe("Role.findAll()", () => {
  it("should return all roles");
  it("should handle database error");
});

describe("Role.findById()", () => {
  it("should return role by ID");
  it("should return null for non-existent ID");
  it("should handle database error");
});

describe("Role.findByName()", () => {
  it("should return role by name (case-insensitive)");
  it("should return null for non-existent name");
});

// ❌ UNTESTED: Instance methods
describe("Role.create()", () => {
  it("should create new role");
  it("should normalize name to lowercase");
  it("should reject duplicate name");
  it("should validate name pattern");
  it("should handle database error");
});

describe("Role.update()", () => {
  it("should update role name");
  it("should reject protected role updates (admin, client)");
  it("should reject duplicate name");
  it("should handle non-existent role");
});

describe("Role.delete()", () => {
  it("should delete role");
  it("should reject protected role deletion");
  it("should reject deletion of role with assigned users");
  it("should handle non-existent role");
});

describe("Role.isProtectedRole()", () => {
  it("should return true for admin");
  it("should return true for client");
  it("should return false for custom roles");
});
```

**Solution:** Create `__tests__/unit/models/Role.test.js` with mocked database.

---

### 5. db/models/User.js - 49.57% Coverage 🟡

**Missing Tests:**

```javascript
// ✅ TESTED: findByEmail, findByAuth0Id, create (via integration tests)

// ❌ UNTESTED: setRole method (Lines 222-256)
describe("User.setRole()", () => {
  it("should update user role");
  it("should validate role_id exists");
  it("should handle non-existent user");
  it("should handle non-existent role");
  it("should handle database error");
});

// ❌ UNTESTED: delete method (Lines 263, 269-276)
describe("User.delete()", () => {
  it("should soft delete user (set is_active=false)");
  it("should prevent admin self-deletion");
  it("should handle non-existent user");
  it("should handle database error");
});

// ❌ UNTESTED: Error handling in create (Lines 105, 108, 114-117)
describe("User.create() - Edge Cases", () => {
  it("should handle duplicate email gracefully");
  it("should validate email format");
  it("should reject missing required fields");
  it("should handle database constraint violations");
});
```

**Solution:** Create `__tests__/unit/models/User.test.js` with mocked database.

---

### 6. services/audit-service.js - 19.6% Coverage 🟡

**Missing Tests:**

```javascript
// ✅ TESTED: log() method (via integration tests - routes call audit logging)

// ❌ UNTESTED: Wrapper methods (Lines 84-301)
// Note: These are @deprecated, but still need testing for backwards compatibility
describe("Audit Service Wrapper Methods", () => {
  it("logUserCreate() should call log() with correct action");
  it("logUserUpdate() should call log() with correct action");
  it("logUserDelete() should call log() with correct action");
  it("logRoleCreate() should call log() with correct action");
  // ... etc for all 15 wrapper methods
});

// ❌ UNTESTED: Query methods (Lines 351-404)
describe("getUserAuditLogs()", () => {
  it("should return all audit logs for a user");
  it("should order by timestamp descending");
  it("should handle user with no logs");
  it("should handle database error");
});

describe("getResourceAuditLogs()", () => {
  it("should return all audit logs for a resource");
  it("should filter by resource_type and resource_id");
  it("should handle non-existent resource");
});

describe("getAuditLogsByAction()", () => {
  it("should return logs filtered by action type");
  it("should handle invalid action type");
});
```

**Solution:** Create `__tests__/unit/services/audit-service.test.js` with mocked database.

---

### 7. middleware/auth.js - 86.66% Coverage ✅

**Missing Tests (Lines 36, 41, 51-57):**

```javascript
// ❌ UNTESTED: Edge cases
describe("authenticateToken() - Edge Cases", () => {
  it("should reject token without Bearer prefix");
  it("should reject empty Authorization header");
  it("should reject token with invalid signature");
  it("should reject token with missing sub claim");
  it("should reject token with invalid provider");
  it("should handle database error when fetching user");
});
```

**Solution:** Add to existing auth tests or create unit test file.

---

### 8. services/token-service.js - 84.93% Coverage ✅

**Missing Tests (Lines 124, 156-157, 191-192, 215-216, 260-261):**

```javascript
// ❌ UNTESTED: Error handling paths
describe("TokenService - Error Handling", () => {
  it("generateTokenPair() should handle database error");
  it("refreshAccessToken() should handle database query failure");
  it("revokeToken() should handle non-existent token");
  it("revokeAllUserTokens() should handle database error");
  it("cleanupExpiredTokens() should handle database error");
  it("getUserTokens() should handle database error");
});
```

**Solution:** Add to existing token service tests.

---

## 🚀 Implementation Roadmap

### **Phase 6a: Routes Unit Tests (Priority 1)**

**Effort:** 25-30 hours  
**Files:** 3 files (roles, users, auth)  
**Tests:** ~80-100 unit tests

**Approach:**

```javascript
// Example structure: __tests__/unit/routes/roles.test.js
const request = require("supertest");
const express = require("express");
const rolesRouter = require("../../../routes/roles");
const Role = require("../../../db/models/Role");
const auditService = require("../../../services/audit-service");

// Mock dependencies
jest.mock("../../../db/models/Role");
jest.mock("../../../services/audit-service");
jest.mock("../../../middleware/auth"); // Mock auth to control user context

describe("Routes: /api/roles", () => {
  describe("GET /api/roles", () => {
    it("should return all roles as admin", async () => {
      Role.findAll.mockResolvedValue([{ id: 1, name: "admin" }]);

      const res = await request(app)
        .get("/api/roles")
        .set("Authorization", "Bearer mock-admin-token")
        .expect(200);

      expect(res.body.data).toHaveLength(1);
      expect(Role.findAll).toHaveBeenCalled();
    });
  });
});
```

**Coverage Target:** 90% for all route files

---

### **Phase 6b: Models Unit Tests (Priority 1)**

**Effort:** 15-20 hours  
**Files:** 2 files (User, Role)  
**Tests:** ~50-60 unit tests

**Approach:**

```javascript
// Example: __tests__/unit/models/Role.test.js
const Role = require("../../../db/models/Role");
const db = require("../../../db/connection");

// Mock database
jest.mock("../../../db/connection", () => ({
  query: jest.fn(),
}));

describe("Role Model", () => {
  describe("findAll()", () => {
    it("should return all roles", async () => {
      db.query.mockResolvedValue({
        rows: [{ id: 1, name: "admin" }],
      });

      const roles = await Role.findAll();

      expect(roles).toHaveLength(1);
      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("SELECT * FROM roles"),
      );
    });
  });
});
```

**Coverage Target:** 90% for Role.js, 85% for User.js

---

### **Phase 6c: Services Unit Tests (Priority 1 & 2)**

**Effort:** 10-15 hours  
**Files:** audit-service, user-data, auth strategies  
**Tests:** ~40-50 unit tests

**Approach:**

```javascript
// Example: __tests__/unit/services/audit-service.test.js
const auditService = require("../../../services/audit-service");
const db = require("../../../db/connection");

jest.mock("../../../db/connection");

describe("Audit Service", () => {
  describe("getUserAuditLogs()", () => {
    it("should return all logs for a user", async () => {
      db.query.mockResolvedValue({
        rows: [{ action: "user_create", timestamp: "2025-10-16" }],
      });

      const logs = await auditService.getUserAuditLogs(1);

      expect(logs).toHaveLength(1);
      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("WHERE user_id = $1"),
        [1],
      );
    });
  });
});
```

**Coverage Target:** 90% for audit-service, 80% for auth strategies

---

### **Phase 6d: Edge Cases & Error Handling (Priority 2)**

**Effort:** 10-12 hours  
**Files:** auth.js, token-service.js, connection.js  
**Tests:** ~30-40 unit tests

**Approach:**

```javascript
// Example: Add to existing tests
describe("authenticateToken() - Error Scenarios", () => {
  it("should handle database connection timeout", async () => {
    User.findByAuth0Id.mockRejectedValue(new Error("Connection timeout"));

    await request(app)
      .get("/api/auth/me")
      .set("Authorization", "Bearer valid-token")
      .expect(500);
  });
});
```

**Coverage Target:** 95% for auth.js, 95% for token-service.js

---

### **Phase 6e: Server Lifecycle Tests (Priority 3)**

**Effort:** 5-8 hours  
**Files:** server.js  
**Tests:** ~15-20 tests

**Approach:**

```javascript
// Example: __tests__/unit/server.test.js
describe("Server Lifecycle", () => {
  describe("Production Environment Validation", () => {
    it("should exit if JWT_SECRET is weak", () => {
      process.env.NODE_ENV = "production";
      process.env.JWT_SECRET = "dev-secret-key";

      expect(() => require("../../../server")).toThrow();
    });

    it("should start successfully with strong secrets", () => {
      process.env.NODE_ENV = "production";
      process.env.JWT_SECRET = "a".repeat(32);
      process.env.DB_PASSWORD = "b".repeat(12);

      expect(() => require("../../../server")).not.toThrow();
    });
  });
});
```

**Coverage Target:** 70% for server.js

---

## 📊 Expected Outcomes

### **After Phase 6a-6e Implementation:**

| Category                | Before | After    | Delta |
| ----------------------- | ------ | -------- | ----- |
| **Overall Statements**  | 38.99% | **~85%** | +46%  |
| **Overall Branches**    | 29.62% | **~75%** | +45%  |
| **Overall Functions**   | 26.63% | **~80%** | +53%  |
| **Routes**              | 32.88% | **~90%** | +57%  |
| **Models**              | 34.05% | **~88%** | +54%  |
| **Services (critical)** | 34.29% | **~85%** | +51%  |
| **Middleware**          | 83.87% | **~92%** | +8%   |

### **Test Count Projection:**

| Test Type             | Before              | After    | Delta        |
| --------------------- | ------------------- | -------- | ------------ |
| **Integration Tests** | 84                  | 84       | 0 (maintain) |
| **Unit Tests**        | ~20 (token service) | **~250** | +230         |
| **Total Tests**       | 104                 | **~334** | +230         |

### **Time Investment:**

| Phase              | Effort          | Tests Added    |
| ------------------ | --------------- | -------------- |
| **6a: Routes**     | 25-30h          | ~90 tests      |
| **6b: Models**     | 15-20h          | ~55 tests      |
| **6c: Services**   | 10-15h          | ~45 tests      |
| **6d: Edge Cases** | 10-12h          | ~35 tests      |
| **6e: Server**     | 5-8h            | ~20 tests      |
| **TOTAL**          | **65-85 hours** | **~245 tests** |

**Realistic Timeline:** 2-3 weeks of focused work (assuming 30-40 hours/week)

---

## 🎯 Success Criteria

### **Must Have (Critical Paths - 90%+):**

- ✅ `routes/roles.js` ≥ 90%
- ✅ `routes/users.js` ≥ 90%
- ✅ `routes/auth.js` ≥ 90%
- ✅ `db/models/Role.js` ≥ 90%
- ✅ `db/models/User.js` ≥ 90%
- ✅ `services/audit-service.js` ≥ 90%

### **Should Have (Important - 80%+):**

- ✅ `middleware/auth.js` ≥ 95%
- ✅ `services/token-service.js` ≥ 95%
- ✅ `services/auth/DevAuthStrategy.js` ≥ 80%
- ✅ `db/connection.js` ≥ 85%

### **Nice to Have (Optional - 70%+):**

- ✅ `server.js` ≥ 70%
- ✅ `services/user-data.js` ≥ 70%
- ✅ `services/health-manager.js` ≥ 70%

### **Defer (Auth0 only):**

- ⏸️ Auth0-specific files (test when Auth0 is production-critical)

---

## 💡 Testing Strategy

### **1. Unit Tests > Integration Tests**

**Current:** 84 integration tests, ~20 unit tests  
**Target:** 84 integration tests (maintain), ~250 unit tests (add)

**Why?** Integration tests are **slow** and test **happy paths**. Unit tests are **fast** and test **edge cases**.

### **2. Mock Dependencies Aggressively**

```javascript
// ✅ GOOD: Unit test with mocked database
jest.mock("../../../db/connection");
const Role = require("../../../db/models/Role");

// ❌ BAD: Integration test that hits real database (slow!)
const Role = require("../../../db/models/Role");
await setupTestDatabase(); // Creates real DB connection
```

### **3. Test Error Paths, Not Just Happy Paths**

```javascript
// ✅ GOOD: Tests both success and failure
it("should create role with valid data");
it("should reject duplicate role name");
it("should reject invalid role name pattern");
it("should handle database connection timeout");

// ❌ BAD: Only tests success
it("should create role");
```

### **4. Follow AAA Pattern**

```javascript
// Arrange
const mockRole = { id: 1, name: "test" };
Role.findById.mockResolvedValue(mockRole);

// Act
const result = await Role.findById(1);

// Assert
expect(result).toEqual(mockRole);
expect(Role.findById).toHaveBeenCalledWith(1);
```

### **5. Use Test Constants (Single Source of Truth)**

```javascript
// ✅ GOOD: Uses test constants
const { TEST_ROLES } = require("../../../config/test-constants");
expect(role.name).toBe(TEST_ROLES.UNIQUE_COORDINATOR);

// ❌ BAD: Hardcoded strings
expect(role.name).toBe("test_coordinator");
```

---

## 🔄 Continuous Improvement

### **After Phase 6 Completion:**

1. **Add Coverage Gates to CI/CD**

   ```yaml
   # .github/workflows/test.yml
   - name: Run tests with coverage
     run: npm run test:coverage
   - name: Check coverage thresholds
     run: |
       npx jest --coverage --coverageThreshold='{
         "global": {
           "statements": 85,
           "branches": 75,
           "functions": 80,
           "lines": 85
         }
       }'
   ```

2. **Monitor Coverage Trends**
   - Use CodeCov or Coveralls for visualization
   - Block PRs that decrease coverage

3. **Require Tests for New Features**
   - PR template includes "Tests added?" checkbox
   - Code review checklist includes coverage check

---

## 📝 Conclusion

**Current State:** 38.99% overall coverage, strong integration tests (84/84 passing), weak unit tests  
**Root Cause:** Testing via integration (routes → models → DB) instead of unit (mock dependencies)  
**Solution:** Add **~250 unit tests** across routes, models, and services  
**Effort:** 65-85 hours over 2-3 weeks  
**Outcome:** **~85% overall coverage** with 90%+ on critical paths

**Critical Paths Identified:**

1. 🔴 Routes (32% → 90%) - GET endpoints completely untested
2. 🔴 Models (34% → 88%) - Need direct unit tests, not just via routes
3. 🟡 Audit Service (19% → 90%) - Query methods untested
4. 🟡 Auth Routes (21% → 90%) - Profile, logout, refresh untested

**Ready for Implementation:** All gaps identified, test structure defined, effort estimated. Next step is Phase 6 implementation (requires approval).

---

**Phase 6 Status:** ✅ ANALYSIS COMPLETE - Ready for implementation review  
**Next Phase:** 6a-6e Implementation (upon approval)  
**Overall Progress:** 7/15 phases complete (47%) + Phase 6 analysis done
