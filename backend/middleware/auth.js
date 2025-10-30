/**
 * Authentication Middleware
 *
 * Verifies JWT tokens from both Dev and Auth0 strategies.
 * Works seamlessly with the unified AuthService (Strategy Pattern).
 *
 * SECURITY: Development tokens are ONLY accepted in development/test mode.
 * Production mode ONLY accepts Auth0 tokens.
 */
const jwt = require("jsonwebtoken");
const { UserDataService: userDataService } = require("../services/user-data");
const { HTTP_STATUS, USER_ROLES } = require("../config/constants");
const { logSecurityEvent } = require("../config/logger");
const AppConfig = require("../config/app-config");
const { TEST_USERS } = require("../config/test-users");

const JWT_SECRET = process.env.JWT_SECRET || "dev-secret-key";

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ")
    ? authHeader.substring(7)
    : null;

  if (!token) {
    logSecurityEvent("AUTH_MISSING_TOKEN", {
      ip: req.ip,
      userAgent: req.get("User-Agent"),
      url: req.url,
    });
    return res.status(HTTP_STATUS.UNAUTHORIZED).json({
      error: "Unauthorized",
      message: "Access token required",
      timestamp: new Date().toISOString(),
    });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);

    // Validate required standard claims (RFC 7519)
    if (!decoded.sub) {
      throw new Error('Missing required "sub" claim');
    }

    // Accept both development and auth0 providers
    if (
      !decoded.provider ||
      !["development", "auth0"].includes(decoded.provider)
    ) {
      throw new Error("Invalid token provider");
    }

    // SECURITY CHECK: Reject development tokens in production
    if (decoded.provider === "development") {
      if (!AppConfig.devAuthEnabled) {
        logSecurityEvent("AUTH_DEV_TOKEN_IN_PRODUCTION", {
          ip: req.ip,
          userAgent: req.get("User-Agent"),
          url: req.url,
          provider: decoded.provider,
          environment: AppConfig.environment,
          severity: "CRITICAL",
        });
        throw new Error(
          "Development authentication is not permitted in production mode. " +
            "Only Auth0 authentication is allowed.",
        );
      }
    }

    req.user = decoded;

    // CRITICAL: Development tokens should NEVER touch the database
    // They exist purely in-memory from test-users.js config
    if (decoded.provider === "development") {
      // Get the full user object from TEST_USERS (DB-consistent structure)
      const testUser = Object.values(TEST_USERS).find(
        (u) => u.auth0_id === decoded.sub || u.email === decoded.email,
      );

      if (!testUser) {
        throw new Error("Development user not found in TEST_USERS");
      }

      // Use the complete test user data (already matches DB schema)
      req.dbUser = {
        ...testUser,
        name: `${testUser.first_name} ${testUser.last_name}`.trim() || "User",
      };
      next();
    } else {
      // Auth0 provider: find or create user in database
      const dbUser = await userDataService.findOrCreateUser(decoded);
      req.dbUser = dbUser;
      next();
    }
  } catch (error) {
    logSecurityEvent("AUTH_INVALID_TOKEN", {
      ip: req.ip,
      userAgent: req.get("User-Agent"),
      url: req.url,
      error: error.message,
    });
    return res.status(HTTP_STATUS.FORBIDDEN).json({
      error: "Forbidden",
      message: "Invalid or expired token",
      // Only expose error details in development for debugging
      ...(process.env.NODE_ENV === "development" && { details: error.message }),
      timestamp: new Date().toISOString(),
    });
  }
};

const requireRole = (roleName) => (req, res, next) => {
  if (!req.dbUser?.role || req.dbUser.role !== roleName) {
    logSecurityEvent("AUTH_INSUFFICIENT_ROLE", {
      ip: req.ip,
      userAgent: req.get("User-Agent"),
      url: req.url,
      userId: req.dbUser?.id,
      requiredRole: roleName,
      userRole: req.dbUser?.role,
    });
    return res.status(HTTP_STATUS.FORBIDDEN).json({
      error: "Forbidden",
      message: `${roleName} role required`,
      timestamp: new Date().toISOString(),
    });
  }
  next();
};

module.exports = {
  authenticateToken,
  requireAdmin: requireRole("admin"),
  requireManager: requireRole("manager"),
  requireDispatcher: requireRole("dispatcher"),
  requireTechnician: requireRole("technician"),
};
