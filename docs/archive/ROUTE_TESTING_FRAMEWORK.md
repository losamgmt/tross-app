# Route Testing Framework

**Created:** October 17, 2025  
**Purpose:** Establish DRY, modular test patterns for RESTful route testing

## Philosophy

> **"Code should be optimized for testability FIRST, then tests should test that code."**

We don't chase coverage of poorly structured code. Instead:

1. **Refactor** code to follow SRP and be testable
2. **Extract** reusable utilities from route handlers
3. **Test** utilities and routes separately with clear boundaries
4. **Reuse** test patterns across similar routes

## Architecture Pattern

### Layer Separation

```
┌─────────────────────────────────────────────────────────────┐
│                     ROUTE LAYER                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  routes/roles.js  │  routes/users.js  │  routes/auth │  │
│  │                                                        │  │
│  │  Responsibilities:                                     │  │
│  │  • Request/response handling                           │  │
│  │  • Middleware composition                              │  │
│  │  • Delegate to models & services                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   UTILITY LAYER                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  utils/request-helpers.js                             │  │
│  │                                                        │  │
│  │  • getClientIp(req)                                    │  │
│  │  • getUserAgent(req)                                   │  │
│  │  • getAuditMetadata(req)                               │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    MODEL LAYER                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  db/models/Role.js  │  db/models/User.js             │  │
│  │                                                        │  │
│  │  • Database operations                                 │  │
│  │  • Business logic                                      │  │
│  │  • Data validation                                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Testing Strategy

**Each layer is tested independently:**

1. **Utility Tests** (`__tests__/unit/utils/`)
   - Pure function testing
   - No mocks needed (except for edge cases)
   - 100% coverage achievable and expected

2. **Model Tests** (`__tests__/unit/models/`)
   - Mock database connection
   - Test business logic in isolation
   - 100% coverage target

3. **Route Tests** (`__tests__/unit/routes/`)
   - Mock models, services, middleware, utilities
   - Test HTTP request/response handling
   - Test middleware composition
   - 95-100% coverage target

4. **Integration Tests** (`__tests__/integration/`)
   - Real database (test instance)
   - Full stack testing
   - Verify layer interactions

## Example: Request Helper Extraction

### ❌ Before (Untestable)

```javascript
// routes/roles.js - INLINE logic makes testing difficult
await auditService.logRoleCreation(
  req.dbUser.id,
  newRole.id,
  newRole.name,
  req.ip || req.connection.remoteAddress, // ← Hard to test both branches
  req.headers["user-agent"], // ← Mixed concerns
);
```

**Problems:**

- IP extraction logic embedded in route
- `||` operator creates branch coverage gaps
- Can't test extraction logic independently
- Violates SRP (route shouldn't know about IP extraction)

### ✅ After (Testable & SRP-compliant)

**Step 1: Extract utility**

```javascript
// utils/request-helpers.js
function getClientIp(req) {
  return req.ip || req.connection?.remoteAddress || "unknown";
}

function getUserAgent(req) {
  return req.headers["user-agent"];
}
```

**Step 2: Use in route**

```javascript
// routes/roles.js - Clean, testable
const { getClientIp, getUserAgent } = require("../utils/request-helpers");

await auditService.logRoleCreation(
  req.dbUser.id,
  newRole.id,
  newRole.name,
  getClientIp(req), // ← Testable utility function
  getUserAgent(req), // ← Testable utility function
);
```

**Step 3: Test utility separately**

```javascript
// __tests__/unit/utils/request-helpers.test.js
describe("getClientIp()", () => {
  test("should return req.ip when available", () => {
    const req = {
      ip: "192.168.1.100",
      connection: { remoteAddress: "10.0.0.1" },
    };
    expect(getClientIp(req)).toBe("192.168.1.100");
  });

  test("should fallback to connection.remoteAddress", () => {
    const req = { ip: undefined, connection: { remoteAddress: "10.0.0.1" } };
    expect(getClientIp(req)).toBe("10.0.0.1");
  });

  test('should return "unknown" when both missing', () => {
    const req = { ip: undefined, connection: null };
    expect(getClientIp(req)).toBe("unknown");
  });
});
```

**Step 4: Test route with mocked utility**

```javascript
// __tests__/unit/routes/roles.test.js
jest.mock("../../../utils/request-helpers");

beforeEach(() => {
  getClientIp.mockReturnValue("192.168.1.1");
  getUserAgent.mockReturnValue("jest-test-agent");
});

test("should log audit with correct metadata", async () => {
  // ... test code ...
  expect(auditService.logRoleCreation).toHaveBeenCalledWith(
    1,
    4,
    "manager",
    "192.168.1.1", // ← From mocked getClientIp
    "jest-test-agent", // ← From mocked getUserAgent
  );
});
```

## Benefits Achieved

✅ **100% Coverage** on both utility and route  
✅ **SRP Compliance** - Each function has one responsibility  
✅ **Testability** - Clean interfaces, easy mocking  
✅ **Reusability** - Utility usable in users, auth, etc.  
✅ **Maintainability** - Change IP logic in one place  
✅ **No Test Gymnastics** - Tests are straightforward

## Route Test Pattern

### Standard Structure

```javascript
describe("routes/[resource].js", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Setup standard mocks
  });

  describe("GET /api/[resource]", () => {
    test("should return all [resources] successfully", async () => {
      // Arrange - Setup mocks
      // Act - Make request
      // Assert - Verify response
    });

    test("should return 500 on database error", async () => {
      // Arrange - Mock error
      // Act - Make request
      // Assert - Verify error response
    });
  });

  describe("GET /api/[resource]/:id", () => {
    test("should return [resource] when found", async () => {
      /* ... */
    });
    test("should return 404 when not found", async () => {
      /* ... */
    });
    test("should return 500 on database error", async () => {
      /* ... */
    });
  });

  describe("POST /api/[resource]", () => {
    test("should create [resource] successfully and log audit", async () => {
      /* ... */
    });
    test("should return 400 when validation fails", async () => {
      /* ... */
    });
    test("should return 409 on duplicate", async () => {
      /* ... */
    });
    test("should return 500 on database error", async () => {
      /* ... */
    });
  });

  describe("PUT /api/[resource]/:id", () => {
    test("should update [resource] successfully and log audit", async () => {
      /* ... */
    });
    test("should return 404 when not found", async () => {
      /* ... */
    });
    test("should return 400 on validation error", async () => {
      /* ... */
    });
    test("should return 409 on duplicate", async () => {
      /* ... */
    });
    test("should return 500 on database error", async () => {
      /* ... */
    });
  });

  describe("DELETE /api/[resource]/:id", () => {
    test("should delete [resource] successfully and log audit", async () => {
      /* ... */
    });
    test("should return 400 when constrained", async () => {
      /* ... */
    });
    test("should return 404 when not found", async () => {
      /* ... */
    });
    test("should return 500 on database error", async () => {
      /* ... */
    });
  });

  describe("Middleware Integration", () => {
    test("should require authentication", async () => {
      /* ... */
    });
    test("should require admin role", async () => {
      /* ... */
    });
    test("should validate input", async () => {
      /* ... */
    });
  });

  describe("Edge Cases", () => {
    test("should handle undefined returns", async () => {
      /* ... */
    });
    test("should handle large datasets", async () => {
      /* ... */
    });
    test("should handle special characters", async () => {
      /* ... */
    });
  });
});
```

### Mock Setup Pattern

```javascript
// Mock all dependencies at module level
jest.mock("../../../db/models/[Model]");
jest.mock("../../../services/audit-service");
jest.mock("../../../middleware/auth");
jest.mock("../../../middleware/validation");
jest.mock("../../../utils/request-helpers");

// Setup default mock behaviors
beforeEach(() => {
  jest.clearAllMocks();

  // Middleware mocks (pass-through by default)
  authenticateToken.mockImplementation((req, res, next) => {
    req.dbUser = { id: 1, email: "admin@test.com", role: "admin" };
    next();
  });

  requireAdmin.mockImplementation((req, res, next) => next());

  // Utility mocks (return predictable values)
  getClientIp.mockReturnValue("192.168.1.1");
  getUserAgent.mockReturnValue("jest-test-agent");
});
```

## Current Test Metrics

### routes/roles.js

- **Coverage:** 100% statements, 100% branches, 100% functions, 100% lines
- **Tests:** 41 unit tests
- **Pattern:** ✅ Fully implemented

### utils/request-helpers.js

- **Coverage:** 100% statements, 100% branches, 100% functions, 100% lines
- **Tests:** 16 unit tests
- **Pattern:** ✅ Reference implementation

### db/models/Role.js

- **Coverage:** 100% statements, 100% branches, 100% functions, 100% lines
- **Tests:** 58 unit tests
- **Pattern:** ✅ Reference implementation

## Next Steps

Apply this pattern to:

1. **routes/users.js** (80% → 100%)
2. **db/models/User.js** (57% → 100%)
3. **routes/auth.js** (21% → 100%)
4. **services/audit-service.js** (27% → 100%)

Extract common patterns into:

- `__tests__/helpers/route-test-factory.js` - Generate standard route tests
- `__tests__/helpers/mock-factory.js` - Standard mock setups
- `__tests__/helpers/assertions.js` - Common assertion patterns

## Key Principles

1. **Code First, Tests Second** - Refactor for testability before testing
2. **SRP Always** - One function, one responsibility
3. **Extract, Don't Embed** - Logic in utilities, not inline
4. **Test Boundaries** - Each layer tested independently
5. **Mock at Boundaries** - Mock what you don't own
6. **100% is Achievable** - With proper structure, perfect coverage is realistic

---

**Reference Implementation:** See `routes/roles.js` and `__tests__/unit/routes/roles.test.js`
