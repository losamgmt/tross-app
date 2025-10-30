/**
 * Unit Tests for routes/roles.js - CRUD Operations
 *
 * Tests core CRUD operations for role routes with mocked dependencies.
 * Uses centralized setup from route-test-setup.js (DRY architecture).
 *
 * Test Coverage: GET, POST, PUT, DELETE /api/roles and /api/roles/:id
 */

const request = require("supertest");
const Role = require("../../../db/models/Role");
const auditService = require("../../../services/audit-service");
const { authenticateToken, requireAdmin } = require("../../../middleware/auth");
const {
  validateRoleCreate,
  validateRoleUpdate,
  validateIdParam,
} = require("../../../validators");
const { HTTP_STATUS } = require("../../../config/constants");
const { getClientIp, getUserAgent } = require("../../../utils/request-helpers");
const {
  createRouteTestApp,
  setupRouteMocks,
  teardownRouteMocks,
} = require("../../helpers/route-test-setup");

// Mock dependencies
jest.mock("../../../db/models/Role");
jest.mock("../../../services/audit-service");
jest.mock("../../../middleware/auth");
jest.mock("../../../utils/request-helpers");

// Mock validators with proper factory functions that return middleware
jest.mock("../../../validators", () => ({
  validatePagination: jest.fn(() => (req, res, next) => {
    if (!req.validated) req.validated = {};
    req.validated.pagination = { page: 1, limit: 50, offset: 0 };
    next();
  }),
  validateIdParam: jest.fn(() => (req, res, next) => {
    req.validated = req.validated || {};
    req.validated.id = parseInt(req.params.id, 10) || null;
    next();
  }),
  validateRoleCreate: jest.fn((req, res, next) => next()),
  validateRoleUpdate: jest.fn((req, res, next) => next()),
}));

// Create test app with roles router - NOW it's safe to require the router
const rolesRouter = require("../../../routes/roles");
const { validatePagination } = require("../../../validators");
const app = createRouteTestApp(rolesRouter, "/api/roles");

describe("routes/roles.js - CRUD Operations", () => {
  beforeEach(() => {
    setupRouteMocks({
      getClientIp,
      getUserAgent,
      authenticateToken,
      requireAdmin,
      validateIdParam,
      validateRoleCreate,
      validateRoleUpdate,
      validatePagination,
    });
  });

  afterEach(() => {
    teardownRouteMocks();
  });

  // ===========================
  // GET /api/roles - List All Roles
  // ===========================
  describe("GET /api/roles", () => {
    test("should return all roles with count and timestamp", async () => {
      // Arrange
      const mockRoles = [
        { id: 1, name: "admin", created_at: "2025-10-17T16:52:17.841Z" },
        { id: 2, name: "client", created_at: "2025-10-17T16:52:17.841Z" },
        { id: 3, name: "manager", created_at: "2025-10-17T16:52:17.841Z" },
      ];
      Role.findAll.mockResolvedValue(mockRoles);

      // Act
      const response = await request(app).get("/api/roles");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockRoles);
      expect(response.body.count).toBe(3);
      expect(response.body.timestamp).toBeDefined();
      expect(Role.findAll).toHaveBeenCalledTimes(1);
    });

    test("should return empty array when no roles exist", async () => {
      // Arrange
      Role.findAll.mockResolvedValue([]);

      // Act
      const response = await request(app).get("/api/roles");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([]);
      expect(response.body.count).toBe(0);
    });

    test("should handle very large result sets", async () => {
      // Arrange
      const largeRoleSet = Array.from({ length: 1000 }, (_, i) => ({
        id: i + 1,
        name: `role${i}`,
        created_at: new Date(),
      }));
      Role.findAll.mockResolvedValue(largeRoleSet);

      // Act
      const response = await request(app).get("/api/roles");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.count).toBe(1000);
      expect(response.body.data).toHaveLength(1000);
    });
  });

  // ===========================
  // GET /api/roles/:id - Get Role by ID
  // ===========================
  describe("GET /api/roles/:id", () => {
    test("should return role when found", async () => {
      // Arrange
      const mockRole = {
        id: 1,
        name: "admin",
        created_at: "2025-10-17T16:52:17.917Z",
      };
      Role.findById.mockResolvedValue(mockRole);

      // Act
      const response = await request(app).get("/api/roles/1");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockRole);
      expect(response.body.timestamp).toBeDefined();
      expect(Role.findById).toHaveBeenCalledWith(1); // Validator coerces to integer
    });

    test("should handle non-numeric ID gracefully", async () => {
      // Arrange
      Role.findById.mockResolvedValue(null);

      // Act
      const response = await request(app).get("/api/roles/abc");

      // Assert
      expect(response.status).toBe(404);
      expect(Role.findById).toHaveBeenCalledWith(null); // Validator returns null for invalid ID
    });
  });

  // ===========================
  // POST /api/roles - Create Role
  // ===========================
  describe("POST /api/roles", () => {
    test("should create role successfully and log audit", async () => {
      // Arrange
      const newRoleName = "manager";
      const mockCreatedRole = {
        id: 4,
        name: "manager",
        created_at: "2025-10-17T16:52:17.961Z",
      };
      Role.create.mockResolvedValue(mockCreatedRole);
      auditService.log.mockResolvedValue(undefined);

      // Act
      const response = await request(app)
        .post("/api/roles")
        .send({ name: newRoleName })
        .set("User-Agent", "jest-test-agent");

      // Assert
      expect(response.status).toBe(HTTP_STATUS.CREATED);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(mockCreatedRole);
      expect(response.body.message).toBe("Role created successfully");
      expect(response.body.timestamp).toBeDefined();

      expect(Role.create).toHaveBeenCalledWith(newRoleName);
      expect(auditService.log).toHaveBeenCalledWith({
        userId: 1,
        action: "role_create",
        resourceType: "role",
        resourceId: mockCreatedRole.id,
        newValues: { name: mockCreatedRole.name },
        ipAddress: "192.168.1.1",
        userAgent: "jest-test-agent",
      });
    });

    test("should handle special characters in role names", async () => {
      // Arrange
      const specialRole = {
        id: 10,
        name: "test-role_123",
        created_at: new Date(),
      };
      Role.create.mockResolvedValue(specialRole);
      auditService.log.mockResolvedValue(undefined);

      // Act
      const response = await request(app)
        .post("/api/roles")
        .send({ name: "test-role_123" });

      // Assert
      expect(response.status).toBe(HTTP_STATUS.CREATED);
      expect(response.body.data.name).toBe("test-role_123");
    });
  });

  // ===========================
  // PUT /api/roles/:id - Update Role
  // ===========================
  describe("PUT /api/roles/:id", () => {
    test("should update role successfully and log audit", async () => {
      // Arrange
      const oldRole = {
        id: 3,
        name: "manager",
        created_at: "2025-10-17T16:52:18.015Z",
      };
      const updatedRole = {
        id: 3,
        name: "supervisor",
        created_at: "2025-10-17T16:52:18.015Z",
      };
      Role.findById.mockResolvedValue(oldRole);
      Role.update.mockResolvedValue(updatedRole);
      auditService.log.mockResolvedValue(undefined);

      // Act
      const response = await request(app)
        .put("/api/roles/3")
        .send({ name: "supervisor" })
        .set("User-Agent", "jest-update-agent");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual(updatedRole);
      expect(response.body.message).toBe("Role updated successfully");

      expect(Role.findById).toHaveBeenCalledWith(3);
      expect(Role.update).toHaveBeenCalledWith(3, "supervisor");
      expect(auditService.log).toHaveBeenCalledWith({
        userId: 1,
        action: "role_update",
        resourceType: "role",
        resourceId: 3,
        oldValues: { name: "manager" },
        newValues: { name: "supervisor" },
        ipAddress: "192.168.1.1",
        userAgent: "jest-test-agent",
      });
    });

    test("should use validatedId from middleware", async () => {
      // Arrange
      const oldRole = { id: 5, name: "analyst", created_at: new Date() };
      const updatedRole = {
        id: 5,
        name: "senior-analyst",
        created_at: new Date(),
      };
      Role.findById.mockResolvedValue(oldRole);
      Role.update.mockResolvedValue(updatedRole);
      auditService.log.mockResolvedValue(undefined);

      validateIdParam.mockImplementation((req, res, next) => {
        req.validatedId = parseInt(req.params.id);
        next();
      });

      // Act
      const response = await request(app)
        .put("/api/roles/5")
        .send({ name: "senior-analyst" });

      // Assert
      expect(response.status).toBe(200);
      expect(Role.findById).toHaveBeenCalledWith(5);
      expect(Role.update).toHaveBeenCalledWith(5, "senior-analyst");
    });
  });

  // ===========================
  // DELETE /api/roles/:id - Delete Role
  // ===========================
  describe("DELETE /api/roles/:id", () => {
    test("should delete role successfully and log audit", async () => {
      // Arrange
      const deletedRole = {
        id: 5,
        name: "observer",
        created_at: "2025-10-17T16:52:18.100Z",
      };
      Role.delete.mockResolvedValue(deletedRole);
      auditService.log.mockResolvedValue(undefined);

      // Act
      const response = await request(app)
        .delete("/api/roles/5")
        .set("X-Forwarded-For", "192.168.1.102")
        .set("User-Agent", "jest-delete-agent");

      // Assert
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe("Role deleted successfully");
      expect(response.body.timestamp).toBeDefined();

      expect(Role.delete).toHaveBeenCalledWith(5);
      expect(auditService.log).toHaveBeenCalledWith({
        userId: 1,
        action: "role_delete",
        resourceType: "role",
        resourceId: 5,
        oldValues: { name: "observer" },
        ipAddress: "192.168.1.1",
        userAgent: "jest-test-agent",
      });
    });

    test("should parse ID as integer", async () => {
      // Arrange
      const deletedRole = { id: 7, name: "temp", created_at: new Date() };
      Role.delete.mockResolvedValue(deletedRole);
      auditService.log.mockResolvedValue(undefined);

      // Act
      await request(app).delete("/api/roles/7");

      // Assert
      expect(Role.delete).toHaveBeenCalledWith(7);
    });

    test("should handle concurrent delete requests gracefully", async () => {
      // Arrange - Simulate role already deleted
      Role.delete.mockRejectedValue(new Error("Role not found"));

      // Act
      const response = await request(app).delete("/api/roles/5");

      // Assert
      expect(response.status).toBe(HTTP_STATUS.NOT_FOUND);
    });
  });
});
