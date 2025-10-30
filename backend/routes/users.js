/**
 * User Management Routes
 * RESTful API for user CRUD operations
 * All routes require authentication and admin privileges
 */
const express = require("express");
const { authenticateToken, requireAdmin } = require("../middleware/auth");
const {
  validateUserCreate,
  validateProfileUpdate,
  validateRoleAssignment,
  validateIdParam, // Using centralized validator
  validatePagination, // Query string validation
} = require("../validators"); // Now from validators/ instead of middleware/
const User = require("../db/models/User");
const Role = require("../db/models/Role");
const auditService = require("../services/audit-service");
const { HTTP_STATUS } = require("../config/constants");
const { getClientIp, getUserAgent } = require("../utils/request-helpers");
const { logger } = require("../config/logger");

const router = express.Router();

/**
 * @openapi
 * /api/users:
 *   get:
 *     tags: [Users]
 *     summary: Get all users (admin only)
 *     description: Retrieve a list of all users with their roles
 *     security:
 *       - bearerAuth: []
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
 *         description: Users retrieved successfully
 *       400:
 *         description: Invalid pagination parameters
 *       403:
 *         description: Forbidden - Admin access required
 */
router.get(
  "/",
  authenticateToken,
  requireAdmin,
  validatePagination({ maxLimit: 200 }),
  async (req, res) => {
    try {
      // For now, return all users (pagination ready for future use)
      // TODO: Implement User.getAllPaginated(page, limit) when needed
      const users = await User.getAll();
      const { page, limit } = req.validated.pagination;

      res.json({
        success: true,
        data: users,
        count: users.length,
        pagination: {
          page,
          limit,
          total: users.length,
        },
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error retrieving users", { error: error.message });
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: "Internal Server Error",
        message: "Failed to retrieve users",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/users/{id}:
 *   get:
 *     tags: [Users]
 *     summary: Get user by ID (admin only)
 *     description: Retrieve a single user by their ID
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: User retrieved successfully
 *       404:
 *         description: User not found
 *       403:
 *         description: Forbidden - Admin access required
 */
router.get(
  "/:id",
  authenticateToken,
  requireAdmin,
  validateIdParam,
  async (req, res) => {
    try {
      const userId = req.validatedId; // From validateIdParam middleware
      const user = await User.findById(userId);

      if (!user) {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          error: "Not Found",
          message: "User not found",
          timestamp: new Date().toISOString(),
        });
      }

      res.json({
        success: true,
        data: user,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error retrieving user", {
        error: error.message,
        userId: req.params.id,
      });
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: "Internal Server Error",
        message: "Failed to retrieve user",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/users:
 *   post:
 *     tags: [Users]
 *     summary: Create new user (admin only)
 *     description: Manually create a new user. Requires admin privileges.
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               first_name:
 *                 type: string
 *               last_name:
 *                 type: string
 *               role_id:
 *                 type: integer
 *     responses:
 *       201:
 *         description: User created successfully
 *       400:
 *         description: Bad Request - Invalid input
 *       403:
 *         description: Forbidden - Admin access required
 */
router.post(
  "/",
  authenticateToken,
  requireAdmin,
  validateUserCreate,
  async (req, res) => {
    try {
      const { email, first_name, last_name, role_id } = req.body;

      // Create user (will default to 'client' role if no role_id provided)
      const newUser = await User.create({
        email,
        first_name,
        last_name,
        role_id,
      });

      // Log user creation
      await auditService.log({
        userId: req.dbUser.id,
        action: "user_create",
        resourceType: "user",
        resourceId: newUser.id,
        newValues: { email, first_name, last_name, role_id },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.status(HTTP_STATUS.CREATED).json({
        success: true,
        data: newUser,
        message: "User created successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error creating user", {
        error: error.message,
        email: req.body.email,
      });

      if (error.message === "Email already exists") {
        return res.status(HTTP_STATUS.CONFLICT).json({
          error: "Conflict",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: "Internal Server Error",
        message: "Failed to create user",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/users/{id}:
 *   put:
 *     tags: [Users]
 *     summary: Update user (admin only)
 *     description: Update user information
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               first_name:
 *                 type: string
 *               last_name:
 *                 type: string
 *     responses:
 *       200:
 *         description: User updated successfully
 *       404:
 *         description: User not found
 *       403:
 *         description: Forbidden - Admin access required
 */
router.put(
  "/:id",
  authenticateToken,
  requireAdmin,
  validateIdParam,
  validateProfileUpdate,
  async (req, res) => {
    try {
      const userId = req.validatedId; // From validateIdParam middleware
      const { email, first_name, last_name, is_active } = req.body;

      // Verify user exists
      const existingUser = await User.findById(userId);
      if (!existingUser) {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          error: "Not Found",
          message: "User not found",
          timestamp: new Date().toISOString(),
        });
      }

      // Update user
      const updatedUser = await User.update(userId, {
        email,
        first_name,
        last_name,
        is_active,
      });

      // Log user update
      await auditService.log({
        userId: req.dbUser.id,
        action: "user_update",
        resourceType: "user",
        resourceId: userId,
        newValues: { email, first_name, last_name, is_active },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.json({
        success: true,
        data: updatedUser,
        message: "User updated successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error updating user", {
        error: error.message,
        userId: req.params.id,
      });

      // Return 400 for validation errors
      if (error.message === "No valid fields to update") {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          error: "Bad Request",
          message: error.message,
          timestamp: new Date().toISOString(),
        });
      }

      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: "Internal Server Error",
        message: "Failed to update user",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/users/{id}/role:
 *   put:
 *     tags: [Users]
 *     summary: Set user's role (admin only)
 *     description: Change a user's role (REPLACES existing role - one role per user)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - role_id
 *             properties:
 *               role_id:
 *                 type: integer
 *     responses:
 *       200:
 *         description: Role assigned successfully
 *       404:
 *         description: User or role not found
 *       403:
 *         description: Forbidden - Admin access required
 */
router.put(
  "/:id/role",
  authenticateToken,
  requireAdmin,
  validateIdParam,
  validateRoleAssignment,
  async (req, res) => {
    try {
      const userId = req.validatedId; // From validateIdParam middleware
      const { role_id } = req.body;

      // Validate role_id is a number
      const roleIdNum = parseInt(role_id);
      if (isNaN(roleIdNum)) {
        return res.status(400).json({
          error: "Bad Request",
          message: "role_id must be a number",
          timestamp: new Date().toISOString(),
        });
      }

      // Verify role exists
      const role = await Role.findById(roleIdNum);
      if (!role) {
        return res.status(404).json({
          error: "Role Not Found",
          message: `Role with ID ${role_id} not found`,
          timestamp: new Date().toISOString(),
        });
      }

      // KISS: setRole REPLACES user's role (one role per user)
      await User.setRole(userId, role_id);

      // Log the role assignment
      await auditService.log({
        userId: req.dbUser.id,
        action: "role_assign",
        resourceType: "user",
        resourceId: userId,
        newValues: { role_id, role_name: role.name },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.json({
        success: true,
        message: `Role '${role.name}' assigned successfully`,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error assigning role", {
        error: error.message,
        userId: req.params.id,
        roleId: req.body.role_id,
      });

      res.status(500).json({
        error: "Internal Server Error",
        message: "Failed to assign role",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

/**
 * @openapi
 * /api/users/{id}:
 *   delete:
 *     tags: [Users]
 *     summary: Delete user (admin only)
 *     description: Soft delete a user (sets is_active = false)
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: User deleted successfully
 *       404:
 *         description: User not found
 *       403:
 *         description: Forbidden - Admin access required
 */
router.delete(
  "/:id",
  authenticateToken,
  requireAdmin,
  validateIdParam(),
  async (req, res) => {
    try {
      const userId = req.validated.id; // From validateIdParam middleware

      // Prevent self-deletion
      if (req.dbUser.id === userId) {
        return res.status(HTTP_STATUS.BAD_REQUEST).json({
          error: "Bad Request",
          message: "Cannot delete your own account",
          timestamp: new Date().toISOString(),
        });
      }

      // Verify user exists
      const user = await User.findById(userId);
      if (!user) {
        return res.status(HTTP_STATUS.NOT_FOUND).json({
          error: "Not Found",
          message: "User not found",
          timestamp: new Date().toISOString(),
        });
      }

      // Soft delete user
      await User.delete(userId, false);

      // Log user deletion
      await auditService.log({
        userId: req.dbUser.id,
        action: "user_delete",
        resourceType: "user",
        resourceId: userId,
        oldValues: {
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
        },
        ipAddress: getClientIp(req),
        userAgent: getUserAgent(req),
      });

      res.json({
        success: true,
        message: "User deleted successfully",
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error("Error deleting user", {
        error: error.message,
        userId: req.params.id,
      });
      res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
        error: "Internal Server Error",
        message: "Failed to delete user",
        timestamp: new Date().toISOString(),
      });
    }
  },
);

module.exports = router;
