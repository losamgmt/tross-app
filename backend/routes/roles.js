const express = require("express");
const router = express.Router();
const Role = require("../db/models/Role");
const { authenticateToken, requireAdmin } = require("../middleware/auth");
const {
  validateRoleCreate,
  validateRoleUpdate,
  validateIdParam, // Using centralized validator
  validatePagination, // Query string validation
} = require("../validators"); // Now from validators/ instead of middleware/
const auditService = require("../services/audit-service");
const { HTTP_STATUS } = require("../config/constants");
const { getClientIp, getUserAgent } = require("../utils/request-helpers");
const { logger } = require("../config/logger");

/**
 * @openapi
 * /api/roles:
 *   get:
 *     tags: [Roles]
 *     summary: List all roles
 *     description: Returns a list of all available roles in the system
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number for pagination
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 200
 *           default: 50
 *         description: Number of items per page
 *     responses:
 *       200:
 *         description: Roles retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Role'
 *                 count:
 *                   type: integer
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       400:
 *         description: Invalid pagination parameters
 *       500:
 *         description: Server error
 */
router.get("/", validatePagination(), async (req, res) => {
  try {
    // For now, return all roles (pagination ready for future use)
    // TODO: Implement Role.findAllPaginated(page, limit) when needed
    const roles = await Role.findAll();
    const { page, limit } = req.validated.pagination;

    res.json({
      success: true,
      data: roles,
      count: roles.length,
      pagination: {
        page,
        limit,
        total: roles.length,
      },
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Error fetching roles", { error: error.message });
    res.status(500).json({
      success: false,
      error: "Failed to fetch roles",
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * @openapi
 * /api/roles/{id}:
 *   get:
 *     tags: [Roles]
 *     summary: Get role by ID
 *     description: Returns details of a specific role
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Role ID
 *     responses:
 *       200:
 *         description: Role retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/Role'
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       404:
 *         description: Role not found
 *       500:
 *         description: Server error
 */
router.get("/:id", validateIdParam(), async (req, res) => {
  try {
    const roleId = req.validated.id; // From validateIdParam middleware
    const role = await Role.findById(roleId);

    if (!role) {
      return res.status(404).json({
        success: false,
        error: "Role not found",
        timestamp: new Date().toISOString(),
      });
    }

    res.json({
      success: true,
      data: role,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Error fetching role", {
      error: error.message,
      roleId: req.validated.id,
    });
    res.status(500).json({
      success: false,
      error: "Failed to fetch role",
      timestamp: new Date().toISOString(),
    });
  }
});

/**
 * @openapi
 * /api/roles/{id}/users:
 *   get:
 *     tags: [Roles]
 *     summary: Get users with specific role
 *     description: Returns all users assigned to a specific role with pagination support
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Role ID
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number for pagination
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 200
 *           default: 10
 *         description: Number of items per page
 *     responses:
 *       200:
 *         description: Users retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/User'
 *                 count:
 *                   type: integer
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 *                     totalPages:
 *                       type: integer
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       400:
 *         description: Invalid pagination parameters
 *       500:
 *         description: Server error
 */
router.get(
  "/:id/users",
  validateIdParam(),
  validatePagination(),
  async (req, res) => {
    try {
      const roleId = req.validated.id; // From validateIdParam middleware
      const { page, limit } = req.validated.pagination; // From validatePagination middleware

      const result = await Role.getUsersByRole(roleId, { page, limit });

      res.json({
        success: true,
        data: result.users,
        count: result.users.length,
        pagination: result.pagination,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error fetching users by role", {
        error: error.message,
        roleId: req.validated.id,
      });
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        success: false,
        error: "Failed to fetch users by role",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/roles:
 *   post:
 *     tags: [Roles]
 *     summary: Create new role (admin only)
 *     description: Create a new role. Role name must be unique. Requires admin privileges.
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: Role name (will be converted to lowercase)
 *                 example: manager
 *     responses:
 *       201:
 *         description: Role created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/Role'
 *                 message:
 *                   type: string
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       400:
 *         description: Bad request - Name required or empty
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       409:
 *         description: Conflict - Role name already exists
 */
router.post(
  "/",
  authenticateToken,
  requireAdmin,
  validateRoleCreate,
  async (req, res) => {
    try {
      const { name } = req.body;

      // Check if role name already exists
      if (!name) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          error: "Bad Request",
          message: "Role name is required",
          timestamp: new Date().toISOString(),
        });
      }

      // Create role
      const newRole = await Role.create(name);

      // Log the creation
      await auditService.log({
        userId: req.dbUser.id,
        action: "role_create",
        resourceType: "role",
        resourceId: newRole.id,
        newValues: { name: newRole.name },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: newRole,
        message: "Role created successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error creating role", {
        error: error.message,
        roleName: req.body.name,
      });

      if (error.message === "Role name already exists") {
        return res.status(HTTP_STATUS.CONFLICT).json({
          success: false,
          error: "Conflict",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        success: false,
        error: "Internal Server Error",
        message: "Failed to create role",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/roles/{id}:
 *   put:
 *     tags: [Roles]
 *     summary: Update role (admin only)
 *     description: Update role name. Cannot modify protected roles (admin, client). Requires admin privileges.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Role ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: New role name (will be converted to lowercase)
 *                 example: supervisor
 *     responses:
 *       200:
 *         description: Role updated successfully
 *       400:
 *         description: Bad request - Name required, empty, or protected role
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: Role not found
 *       409:
 *         description: Conflict - Role name already exists
 */
router.put(
  "/:id",
  authenticateToken,
  requireAdmin,
  validateIdParam,
  validateRoleUpdate,
  async (req, res) => {
    try {
      const roleId = req.validatedId; // From validateIdParam middleware
      const { name } = req.body;

      // Get old role name for audit
      const oldRole = await Role.findById(roleId);
      if (!oldRole) {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          error: "Role Not Found",
          message: "Role not found",
          timestamp: new Date().toISOString(),
        });
      }

      // Update role
      const updatedRole = await Role.update(roleId, name);

      // Log the update
      await auditService.log({
        userId: req.dbUser.id,
        action: "role_update",
        resourceType: "role",
        resourceId: roleId,
        oldValues: { name: oldRole.name },
        newValues: { name: updatedRole.name },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.json({
        success: true,
        data: updatedRole,
        message: "Role updated successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error updating role", {
        error: error.message,
        roleId: req.params.id,
      });

      if (error.message === "Cannot modify protected role") {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          error: "Bad Request",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      if (error.message === "Role name already exists") {
        return res.status(HTTP_STATUS.CONFLICT).json({
          success: false,
          error: "Conflict",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      if (error.message === "Role not found") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          error: "Role Not Found",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        success: false,
        error: "Internal Server Error",
        message: "Failed to update role",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/roles/{id}:
 *   delete:
 *     tags: [Roles]
 *     summary: Delete role (admin only)
 *     description: Delete a role. Cannot delete protected roles (admin, client) or roles with assigned users. Requires admin privileges.
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Role ID
 *     responses:
 *       200:
 *         description: Role deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       400:
 *         description: Bad request - Protected role or has assigned users
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin access required
 *       404:
 *         description: Role not found
 */
router.delete(
  "/:id",
  authenticateToken,
  requireAdmin,
  validateIdParam(),
  async (req, res) => {
    try {
      const roleId = req.validated.id; // From validateIdParam middleware

      // Delete role (will throw error if protected or has users)
      const deletedRole = await Role.delete(roleId);

      // Log the deletion
      await auditService.log({
        userId: req.dbUser.id,
        action: "role_delete",
        resourceType: "role",
        resourceId: roleId,
        oldValues: { name: deletedRole.name },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.json({
        success: true,
        message: "Role deleted successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error deleting role", {
        error: error.message,
        roleId: req.params.id,
      });

      if (
        error.message === "Cannot delete protected role" ||
        error.message === "Cannot delete role: users are assigned to this role"
      ) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          success: false,
          error: "Bad Request",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      if (error.message === "Role not found") {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          success: false,
          error: "Role Not Found",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        success: false,
        error: "Internal Server Error",
        message: "Failed to delete role",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

module.exports = router;
