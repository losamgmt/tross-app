// Robust User model with error handling and validation
const db = require("../connection");
const { logger } = require("../../config/logger");
const { toSafeInteger } = require("../../validators/type-coercion");

class User {
  // ============================================================================
  // PRIVATE QUERY BUILDER (DRY)
  // ============================================================================

  /**
   * Build base SELECT query for user with role
   * Centralized query pattern to eliminate duplication
   *
   * @private
   * @param {string} whereClause - WHERE clause (optional)
   * @param {string} orderBy - ORDER BY clause (optional)
   * @returns {string} SQL query
   */
  static _buildUserWithRoleQuery(whereClause = "", orderBy = "") {
    return `
      SELECT u.*, r.name as role, u.role_id
      FROM users u 
      LEFT JOIN roles r ON u.role_id = r.id
      ${whereClause}
      ${orderBy}
    `.trim();
  }

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /**
   * Find user by Auth0 ID with role
   * KISS: Direct JOIN with users.role_id (many-to-one relationship)
   *
   * @param {string} auth0Id - Auth0 user ID (e.g., "auth0|123" or "dev|tech001")
   * @returns {Promise<Object|null>} User object with role or null if not found
   */
  static async findByAuth0Id(auth0Id) {
    if (!auth0Id) {
      throw new Error("Auth0 ID is required");
    }

    try {
      const query = this._buildUserWithRoleQuery("WHERE u.auth0_id = $1");
      const result = await db.query(query, [auth0Id]);
      return result.rows[0] || null;
    } catch (error) {
      logger.error("Error finding user by Auth0 ID", {
        error: error.message,
        auth0Id,
      });
      throw new Error("Failed to find user");
    }
  }

  /**
   * Find user by ID with role
   * KISS: Direct JOIN with users.role_id (many-to-one relationship)
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - User ID (will be coerced to integer)
   * @returns {Promise<Object|null>} User object with role or null if not found
   * @throws {Error} If id is not a valid positive integer
   */
  static async findById(id) {
    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "userId", { min: 1, allowNull: false });

    try {
      const query = this._buildUserWithRoleQuery("WHERE u.id = $1");
      const result = await db.query(query, [safeId]);
      return result.rows[0] || null;
    } catch (error) {
      logger.error("Error finding user by ID", {
        error: error.message,
        userId: id,
      });
      throw new Error("Failed to find user");
    }
  }

  /**
   * Create user from Auth0 data
   * KISS: Direct role_id foreign key (many-to-one relationship)
   *
   * @param {Object} auth0Data - Auth0 user data
   * @param {string} auth0Data.sub - Auth0 user ID
   * @param {string} auth0Data.email - User email
   * @param {string} [auth0Data.given_name] - User first name
   * @param {string} [auth0Data.family_name] - User last name
   * @param {string} [auth0Data.role] - User role (defaults to 'client')
   * @returns {Promise<Object>} Created user object
   */
  static async createFromAuth0(auth0Data) {
    const { sub: auth0_id, email, given_name, family_name, role } = auth0Data;

    if (!auth0_id || !email) {
      throw new Error("Auth0 ID and email are required");
    }

    try {
      // Assign role from JWT token or default to 'client'
      const userRole = role || "client";

      // Single INSERT with role_id - no transaction needed (KISS)
      const userQuery = `
        INSERT INTO users (auth0_id, email, first_name, last_name, role_id) 
        VALUES ($1, $2, $3, $4, (SELECT id FROM roles WHERE name = $5))
        RETURNING *
      `;
      const userResult = await db.query(userQuery, [
        auth0_id,
        email,
        given_name || "",
        family_name || "",
        userRole,
      ]);

      return userResult.rows[0];
    } catch (error) {
      logger.error("Error creating user from Auth0", {
        error: error.message,
        email,
      });

      if (error.constraint === "users_auth0_id_key") {
        throw new Error("User already exists");
      }
      if (error.constraint === "users_email_key") {
        throw new Error("Email already exists");
      }

      throw new Error("Failed to create user");
    }
  }

  // Find or create user from Auth0 token
  // Handles account linking: if user exists by email but different auth0_id, links them
  static async findOrCreate(auth0Data) {
    if (!auth0Data?.sub) {
      throw new Error("Invalid Auth0 data");
    }

    try {
      // First, try to find by Auth0 ID
      let user = await this.findByAuth0Id(auth0Data.sub);

      if (!user && auth0Data.email) {
        // Check if user exists by email (might have been created manually or with different Auth0 connection)
        const emailCheckQuery =
          "SELECT id FROM users WHERE email = $1 AND is_active = true";
        const emailResult = await db.query(emailCheckQuery, [auth0Data.email]);

        if (emailResult.rows.length > 0) {
          // User exists with this email - update their auth0_id to link accounts
          await db.query(
            "UPDATE users SET auth0_id = $1, updated_at = CURRENT_TIMESTAMP WHERE email = $2",
            [auth0Data.sub, auth0Data.email],
          );

          // Now find the user by their newly linked auth0_id
          user = await this.findByAuth0Id(auth0Data.sub);
        }
      }

      // If still no user, create new one
      if (!user) {
        user = await this.createFromAuth0(auth0Data);
        // Fetch with role after creation
        user = await this.findByAuth0Id(auth0Data.sub);
      }

      return user;
    } catch (error) {
      logger.error("Error in findOrCreate", {
        error: error.message,
        auth0Id: auth0Data?.sub,
      });
      throw error;
    }
  }

  // Create user manually (admin function, no Auth0 ID required)
  // Create new user (manual creation)
  // KISS: Direct role_id foreign key (many-to-one relationship)
  static async create(userData) {
    const { email, first_name, last_name, role_id } = userData;

    if (!email) {
      throw new Error("Email is required");
    }

    try {
      // Assign role if provided, otherwise use client role
      let assignedRoleId = role_id;
      if (!assignedRoleId) {
        const Role = require("./Role");
        const clientRole = await Role.getByName("client");
        assignedRoleId = clientRole.id;
      }

      // Single INSERT with role_id - no transaction needed (KISS)
      const userQuery = `
        INSERT INTO users (email, first_name, last_name, role_id) 
        VALUES ($1, $2, $3, $4) 
        RETURNING *
      `;
      const userResult = await db.query(userQuery, [
        email,
        first_name || "",
        last_name || "",
        assignedRoleId,
      ]);

      // Return user with role
      return await this.findById(userResult.rows[0].id);
    } catch (error) {
      logger.error("Error creating user", { error: error.message, email });

      if (error.constraint === "users_email_key") {
        throw new Error("Email already exists");
      }

      throw new Error("Failed to create user");
    }
  }

  // Get all users with roles (admin function)
  // KISS: Direct JOIN with users.role_id (many-to-one relationship)
  static async getAll() {
    try {
      const query = this._buildUserWithRoleQuery(
        "",
        "ORDER BY u.created_at DESC",
      );
      const result = await db.query(query);
      return result.rows;
    } catch (error) {
      logger.error("Error getting all users", { error: error.message });
      throw new Error("Failed to retrieve users");
    }
  }

  /**
   * Update user profile with validation
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - User ID (will be coerced to integer)
   * @param {Object} updates - Fields to update
   * @param {string} [updates.email] - User email
   * @param {string} [updates.first_name] - User first name
   * @param {string} [updates.last_name] - User last name
   * @param {boolean} [updates.is_active] - User active status
   * @returns {Promise<Object>} Updated user object
   * @throws {Error} If id is invalid or no valid fields to update
   */
  static async update(id, updates) {
    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "userId", { min: 1, allowNull: false });

    if (!updates || typeof updates !== "object") {
      throw new Error("Valid user ID and updates are required");
    }

    const allowedFields = ["email", "first_name", "last_name", "is_active"];
    const validUpdates = {};

    // Filter only allowed fields
    Object.keys(updates).forEach((key) => {
      if (allowedFields.includes(key) && updates[key] !== undefined) {
        validUpdates[key] = updates[key];
      }
    });

    if (Object.keys(validUpdates).length === 0) {
      throw new Error("No valid fields to update");
    }

    try {
      const fields = [];
      const values = [];
      let paramCount = 1;

      Object.keys(validUpdates).forEach((key) => {
        fields.push(`${key} = $${paramCount}`);
        values.push(validUpdates[key]);
        paramCount++;
      });

      values.push(id);

      const query = `
        UPDATE users 
        SET ${fields.join(", ")}, updated_at = CURRENT_TIMESTAMP 
        WHERE id = $${paramCount} 
        RETURNING *
      `;

      const result = await db.query(query, values);

      if (result.rows.length === 0) {
        throw new Error("User not found");
      }

      return result.rows[0];
    } catch (error) {
      logger.error("Error updating user", { error: error.message, userId: id });

      if (error.constraint === "users_email_key") {
        throw new Error("Email already exists");
      }

      throw new Error("Failed to update user");
    }
  }

  /**
   * Set user's role (REPLACES existing role - ONE role per user)
   * KISS: Direct update of users.role_id (many-to-one relationship)
   *
   * TYPE SAFE: Validates both userId and roleId are positive integers
   *
   * @param {number|string} userId - User ID (will be coerced to integer)
   * @param {number|string} roleId - Role ID (will be coerced to integer)
   * @returns {Promise<Object>} Updated user object
   * @throws {Error} If userId or roleId are invalid
   */
  static async setRole(userId, roleId) {
    // TYPE SAFETY: Ensure both IDs are valid positive integers
    const safeUserId = toSafeInteger(userId, "userId", {
      min: 1,
      allowNull: false,
    });
    const safeRoleId = toSafeInteger(roleId, "roleId", {
      min: 1,
      allowNull: false,
    });

    try {
      const query = `
        UPDATE users 
        SET role_id = $1, updated_at = CURRENT_TIMESTAMP 
        WHERE id = $2 
        RETURNING *
      `;
      const result = await db.query(query, [safeRoleId, safeUserId]);

      if (result.rows.length === 0) {
        throw new Error("User not found");
      }

      // Return updated user with role
      return await this.findById(userId);
    } catch (error) {
      logger.error("Error setting user role", {
        error: error.message,
        userId,
        roleId,
      });
      throw error;
    }
  }

  /**
   * Delete user (soft delete by default, hard delete optional)
   * KISS: No CASCADE needed for user_roles (doesn't exist)
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - User ID (will be coerced to integer)
   * @param {boolean} [hardDelete=false] - True for permanent deletion, false for soft delete
   * @returns {Promise<Object>} Deleted/deactivated user object
   * @throws {Error} If id is invalid or user not found
   */
  static async delete(id, hardDelete = false) {
    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "userId", { min: 1, allowNull: false });

    try {
      if (hardDelete) {
        // Hard delete - user removed from database
        const query = "DELETE FROM users WHERE id = $1 RETURNING *";
        const result = await db.query(query, [safeId]);

        if (result.rows.length === 0) {
          throw new Error("User not found");
        }

        return result.rows[0];
      } else {
        // Soft delete - set is_active = false (recommended)
        const query = `
          UPDATE users 
          SET is_active = false, updated_at = CURRENT_TIMESTAMP 
          WHERE id = $1 
          RETURNING *
        `;
        const result = await db.query(query, [safeId]);

        if (result.rows.length === 0) {
          throw new Error("User not found");
        }

        return result.rows[0];
      }
    } catch (error) {
      logger.error("Error deleting user", {
        error: error.message,
        userId: id,
        hardDelete,
      });
      throw error;
    }
  }
}

module.exports = User;
