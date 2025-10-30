/**
 * Development Authentication Routes
 *
 * ALWAYS uses DevAuthStrategy - independent of AUTH_MODE.
 * This allows dev login buttons to work alongside Auth0.
 */
const express = require("express");
const DevAuthStrategy = require("../services/auth/DevAuthStrategy");
const User = require("../db/models/User");
const { HTTP_STATUS } = require("../config/constants");
const { logger } = require("../config/logger");

const router = express.Router();

// Create dedicated dev strategy instance
const devStrategy = new DevAuthStrategy();

/**
 * @openapi
 * /api/dev/token:
 *   get:
 *     tags: [Development]
 *     summary: Generate test token (technician role)
 *     description: |
 *       Generate a JWT token for testing with technician role.
 *       **DEVELOPMENT ONLY** - Always available regardless of AUTH_MODE.
 *       Token is valid for 24 hours.
 *     responses:
 *       200:
 *         description: Test token generated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 token:
 *                   type: string
 *                   description: JWT token for Authorization header
 *                 user:
 *                   type: object
 *                   properties:
 *                     auth0_id:
 *                       type: string
 *                     email:
 *                       type: string
 *                     name:
 *                       type: string
 *                     role:
 *                       type: string
 *                 provider:
 *                   type: string
 *                   example: development
 *                 expires_in:
 *                   type: integer
 *                   description: Token validity in seconds
 *                 instructions:
 *                   type: string
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 */
router.get("/token", async (req, res) => {
  try {
    // Use dev strategy directly - always works regardless of AUTH_MODE
    const { token, user } = await devStrategy.authenticate({
      role: "technician",
    });

    logger.info("🔧 Dev token generated for technician");

    res.json({
      success: true,
      token,
      user: {
        auth0_id: user.auth0_id,
        email: user.email,
        name: user.first_name + " " + user.last_name,
        role: user.role,
      },
      provider: "development",
      expires_in: 86400, // 24 hours (dev tokens are long-lived for convenience)
      instructions: "Use this token in Authorization header: Bearer <token>",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Failed to generate test token:", error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: "Failed to generate test token",
      message: error.message,
    });
  }
});

/**
 * @openapi
 * /api/dev/admin-token:
 *   get:
 *     tags: [Development]
 *     summary: Generate test token (admin role)
 *     description: |
 *       Generate a JWT token for testing with admin role.
 *       **DEVELOPMENT ONLY** - Always available regardless of AUTH_MODE.
 *       Token is valid for 24 hours.
 *     responses:
 *       200:
 *         description: Admin test token generated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 token:
 *                   type: string
 *                 user:
 *                   type: object
 *                 provider:
 *                   type: string
 *                 expires_in:
 *                   type: integer
 *                 instructions:
 *                   type: string
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 */
router.get("/admin-token", async (req, res) => {
  try {
    // Use dev strategy directly - always works regardless of AUTH_MODE
    const { token, user } = await devStrategy.authenticate({ role: "admin" });

    logger.info("🔧 Dev token generated for admin");

    res.json({
      success: true,
      token,
      user: {
        auth0_id: user.auth0_id,
        email: user.email,
        name: user.first_name + " " + user.last_name,
        role: user.role,
      },
      provider: "development",
      expires_in: 86400, // 24 hours (dev tokens are long-lived for convenience)
      instructions: "Use this token in Authorization header: Bearer <token>",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    logger.error("Failed to generate admin token:", error);
    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      error: "Failed to generate admin token",
      message: error.message,
    });
  }
});

/**
 * @openapi
 * /api/dev/status:
 *   get:
 *     tags: [Development]
 *     summary: Show development auth configuration
 *     description: |
 *       Displays current dev auth configuration and available endpoints.
 *       **ALWAYS AVAILABLE** - Works regardless of AUTH_MODE setting.
 *       Dev auth is designed to run alongside Auth0 for testing purposes.
 *     responses:
 *       200:
 *         description: Dev auth status
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 dev_auth_enabled:
 *                   type: boolean
 *                   example: true
 *                 provider:
 *                   type: string
 *                   example: development
 *                 message:
 *                   type: string
 *                 available_endpoints:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example:
 *                     - "GET /api/dev/token - Get test technician token"
 *                     - "GET /api/dev/admin-token - Get test admin token"
 *                     - "GET /api/dev/status - This endpoint"
 *                 note:
 *                   type: string
 */
router.get("/status", (req, res) => {
  res.json({
    dev_auth_enabled: true,
    provider: "development",
    message: "Dev auth always available (independent of AUTH_MODE)",
    available_endpoints: [
      "GET /api/dev/token - Get test technician token",
      "GET /api/dev/admin-token - Get test admin token",
      "GET /api/dev/status - This endpoint",
    ],
    note: "Dev auth works alongside Auth0 - use for testing and internal users",
  });
});

module.exports = router;
