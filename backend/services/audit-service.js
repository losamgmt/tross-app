const { pool } = require("../db/connection");
const { logger } = require("../config/logger");
const {
  AuditActions,
  ResourceTypes,
  AuditResults,
} = require("./audit-constants");
const { toSafeUserId, toSafeInteger } = require("../validators/type-coercion");

/**
 * AuditService - Comprehensive audit logging for security and compliance
 * Tracks all security-relevant actions across the application
 *
 * REFACTORED: Removed 15 redundant wrapper methods. Use log() directly with action constants.
 * TYPE SAFE: Handles both integer userIds (Auth0) and string userIds (dev tokens)
 *
 * @example
 * // Old way (deprecated):
 * await auditService.logUserCreation(adminId, userId, ip, ua);
 *
 * // New way:
 * await auditService.log({
 *   action: AuditActions.USER_CREATE,
 *   userId: adminId,
 *   resourceType: ResourceTypes.USER,
 *   resourceId: userId,
 *   ipAddress: ip,
 *   userAgent: ua
 * });
 */
class AuditService {
  /**
   * Log an audit event
   *
   * TYPE SAFETY: userId is coerced to integer or null.
   * - Integer userId: Database-backed users (Auth0)
   * - Null userId: Dev tokens (no database ID) or anonymous actions
   * - String userId: Automatically converted to null with warning log
   *
   * @param {Object} params - Audit event parameters
   * @param {number|string|null} params.userId - User ID performing the action (integer, string dev token, or null)
   * @param {string} params.action - Action performed (use AuditActions constants)
   * @param {string} params.resourceType - Type of resource affected (use ResourceTypes constants)
   * @param {number} params.resourceId - ID of affected resource (optional)
   * @param {Object} params.oldValues - Previous values (for updates)
   * @param {Object} params.newValues - New values (for creates/updates)
   * @param {string} params.ipAddress - Client IP address
   * @param {string} params.userAgent - Client user agent
   * @param {string} params.result - Result status (use AuditResults constants, defaults to SUCCESS)
   * @param {string} params.errorMessage - Error message if failed
   * @returns {Promise<void>}
   */
  async log({
    userId = null,
    action,
    resourceType,
    resourceId = null,
    oldValues = null,
    newValues = null,
    ipAddress = null,
    userAgent = null,
    result = AuditResults.SUCCESS,
    errorMessage = null,
  }) {
    try {
      // CRITICAL FIX: Safely coerce userId to integer or null
      // Dev tokens provide string auth0_id which doesn't map to database ID
      // This prevents "invalid input syntax for type integer" PostgreSQL errors
      const safeUserId = toSafeUserId(userId, "userId");

      await pool.query(
        `INSERT INTO audit_logs 
         (user_id, action, resource_type, resource_id, old_values, new_values, 
          ip_address, user_agent, result, error_message)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          safeUserId, // Now guaranteed to be integer or null
          action,
          resourceType,
          resourceId,
          oldValues ? JSON.stringify(oldValues) : null,
          newValues ? JSON.stringify(newValues) : null,
          ipAddress,
          userAgent,
          result,
          errorMessage,
        ],
      );

      // Also log to application logger for real-time monitoring
      logger.info("Audit event", {
        userId: safeUserId,
        originalUserId: userId !== safeUserId ? userId : undefined, // Track coercion
        action,
        resourceType,
        resourceId,
        result,
        ipAddress,
      });
    } catch (error) {
      // Don't throw - audit logging should never break the application
      logger.error("Error writing audit log", {
        error: error.message,
        action,
        userId,
        stack: error.stack,
      });
    }
  }

  /**
   * Get audit trail for a specific user
   * @param {number|string} userId - User ID (will be validated)
   * @param {number|string} limit - Maximum records to return (will be validated)
   * @returns {Promise<Array>}
   * @throws {Error} If userId or limit is invalid
   */
  async getUserAuditTrail(userId, limit = 100) {
    try {
      // TYPE SAFETY: Validate userId and limit before query
      const safeUserId = toSafeInteger(userId, "userId", {
        min: 1,
        allowNull: false,
      });
      const safeLimit = toSafeInteger(limit, "limit", {
        min: 1,
        max: 1000,
        allowNull: false,
      });

      const result = await pool.query(
        `SELECT * FROM audit_logs
         WHERE user_id = $1
         ORDER BY created_at DESC
         LIMIT $2`,
        [safeUserId, safeLimit],
      );

      return result.rows;
    } catch (error) {
      logger.error("Error fetching user audit trail", {
        error: error.message,
        userId,
      });
      throw error;
    }
  }

  /**
   * Get recent security events (failed logins, unauthorized access, etc.)
   * @param {number} hours - Hours to look back
   * @param {number} limit - Maximum records to return
   * @returns {Promise<Array>}
   */
  async getSecurityEvents(hours = 24, limit = 100) {
    try {
      const result = await pool.query(
        `SELECT * FROM audit_logs
         WHERE action IN ($1, $2)
         AND created_at > NOW() - INTERVAL '${hours} hours'
         ORDER BY created_at DESC
         LIMIT $3`,
        [AuditActions.LOGIN_FAILED, AuditActions.UNAUTHORIZED_ACCESS, limit],
      );

      return result.rows;
    } catch (error) {
      logger.error("Error fetching security events", { error: error.message });
      throw error;
    }
  }

  /**
   * Get audit logs for a specific resource
   * @param {string} resourceType - Resource type (use ResourceTypes constants)
   * @param {number|string} resourceId - Resource ID (will be validated)
   * @param {number|string} limit - Maximum records to return (will be validated)
   * @returns {Promise<Array>}
   * @throws {Error} If resourceType is empty, resourceId is invalid, or limit is invalid
   */
  async getResourceAuditTrail(resourceType, resourceId, limit = 50) {
    try {
      // TYPE SAFETY: Validate inputs before query
      if (!resourceType || typeof resourceType !== "string") {
        throw new Error("resourceType must be a non-empty string");
      }
      const safeResourceId = toSafeInteger(resourceId, "resourceId", {
        min: 1,
        allowNull: false,
      });
      const safeLimit = toSafeInteger(limit, "limit", {
        min: 1,
        max: 1000,
        allowNull: false,
      });

      const result = await pool.query(
        `SELECT * FROM audit_logs
         WHERE resource_type = $1 AND resource_id = $2
         ORDER BY created_at DESC
         LIMIT $3`,
        [resourceType, safeResourceId, safeLimit],
      );

      return result.rows;
    } catch (error) {
      logger.error("Error fetching resource audit trail", {
        error: error.message,
        resourceType,
        resourceId,
      });
      throw error;
    }
  }

  /**
   * Get failed login attempts by IP
   * @param {string} ipAddress - IP address to check
   * @param {number} minutes - Minutes to look back
   * @returns {Promise<number>}
   */
  async getFailedLoginAttempts(ipAddress, minutes = 15) {
    try {
      const result = await pool.query(
        `SELECT COUNT(*) as count
         FROM audit_logs
         WHERE action = $1
         AND ip_address = $2
         AND created_at > NOW() - INTERVAL '${minutes} minutes'`,
        [AuditActions.LOGIN_FAILED, ipAddress],
      );

      return parseInt(result.rows[0].count, 10);
    } catch (error) {
      logger.error("Error checking failed login attempts", {
        error: error.message,
        ipAddress,
      });
      return 0; // Fail open - don't block legitimate users on error
    }
  }

  /**
   * Clean up old audit logs
   * @param {number} daysToKeep - Number of days to retain
   * @returns {Promise<number>} - Number of rows deleted
   */
  async cleanupOldLogs(daysToKeep = 365) {
    try {
      const result = await pool.query(
        `DELETE FROM audit_logs
         WHERE created_at < NOW() - INTERVAL '${daysToKeep} days'
         RETURNING id`,
      );

      const count = result.rowCount;

      if (count > 0) {
        logger.info("Old audit logs cleaned up", { count, daysToKeep });
      }

      return count;
    } catch (error) {
      logger.error("Error cleaning up audit logs", { error: error.message });
      throw error;
    }
  }
}

module.exports = new AuditService();
