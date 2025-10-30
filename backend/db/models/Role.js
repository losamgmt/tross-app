// Role model - handles all role database operations
const db = require("../connection");
const { toSafeInteger } = require("../../validators/type-coercion");

class Role {
  /**
   * Get all roles
   *
   * @returns {Promise<Array>} Array of role objects
   */
  static async findAll() {
    const query = "SELECT id, name, created_at FROM roles ORDER BY name";
    const result = await db.query(query);
    return result.rows;
  }

  /**
   * Get role by ID
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - Role ID (will be coerced to integer)
   * @returns {Promise<Object|undefined>} Role object or undefined if not found
   * @throws {Error} If id is not a valid positive integer
   */
  static async findById(id) {
    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "roleId", { min: 1, allowNull: false });

    const query = "SELECT id, name, created_at FROM roles WHERE id = $1";
    const result = await db.query(query, [safeId]);
    return result.rows[0];
  }

  // Get role by name
  static async getByName(name) {
    const query = "SELECT id, name, created_at FROM roles WHERE name = $1";
    const result = await db.query(query, [name]);
    return result.rows[0];
  }

  // Check if role is protected (cannot be modified/deleted)
  static isProtected(roleName) {
    const protectedRoles = ["admin", "client"];
    return protectedRoles.includes(roleName.toLowerCase());
  }

  // Create new role (for future expansion)
  static async create(name) {
    if (!name || typeof name !== "string") {
      throw new Error("Role name is required");
    }

    // Normalize name to lowercase
    const normalizedName = name.toLowerCase().trim();

    if (!normalizedName) {
      throw new Error("Role name cannot be empty");
    }

    try {
      const query = `
        INSERT INTO roles (name)
        VALUES ($1)
        RETURNING id, name, created_at
      `;
      const result = await db.query(query, [normalizedName]);
      return result.rows[0];
    } catch (error) {
      if (error.constraint === "roles_name_key") {
        throw new Error("Role name already exists");
      }
      throw new Error("Failed to create role");
    }
  }

  /**
   * Update role name
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - Role ID (will be coerced to integer)
   * @param {string} name - New role name
   * @returns {Promise<Object>} Updated role object
   * @throws {Error} If id is invalid, role not found, or role is protected
   */
  static async update(id, name) {
    // BUSINESS LOGIC VALIDATION: Check both parameters first
    if (!id || !name || typeof name !== "string") {
      throw new Error("Role ID and name are required");
    }

    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "roleId", { min: 1, allowNull: false });

    // Normalize name to lowercase
    const normalizedName = name.toLowerCase().trim();

    if (!normalizedName) {
      throw new Error("Role name cannot be empty");
    }

    try {
      // Check if role exists and get its current name
      const currentRole = await this.findById(safeId);
      if (!currentRole) {
        throw new Error("Role not found");
      }

      // Check if current role is protected
      if (this.isProtected(currentRole.name)) {
        throw new Error("Cannot modify protected role");
      }

      const query = `
        UPDATE roles 
        SET name = $2
        WHERE id = $1
        RETURNING id, name, created_at
      `;
      const result = await db.query(query, [safeId, normalizedName]);

      if (result.rows.length === 0) {
        throw new Error("Role not found");
      }

      return result.rows[0];
    } catch (error) {
      if (error.constraint === "roles_name_key") {
        throw new Error("Role name already exists");
      }
      throw error;
    }
  }

  /**
   * Delete role (only if no users have this role)
   *
   * TYPE SAFE: Validates id is a positive integer
   *
   * @param {number|string} id - Role ID (will be coerced to integer)
   * @returns {Promise<Object>} Deleted role object
   * @throws {Error} If id is invalid, role not found, role is protected, or users are assigned
   */
  static async delete(id) {
    // BUSINESS LOGIC VALIDATION: Check ID first
    if (!id) {
      throw new Error("Role ID is required");
    }

    // TYPE SAFETY: Ensure id is a valid positive integer
    const safeId = toSafeInteger(id, "roleId", { min: 1, allowNull: false });

    try {
      // Check if role exists and get its name
      const role = await this.findById(safeId);
      if (!role) {
        throw new Error("Role not found");
      }

      // Check if role is protected
      if (this.isProtected(role.name)) {
        throw new Error("Cannot delete protected role");
      }

      // Check if any users have this role (NEW: users.role_id FK)
      const checkQuery =
        "SELECT COUNT(*) as count FROM users WHERE role_id = $1";
      const checkResult = await db.query(checkQuery, [safeId]);

      if (parseInt(checkResult.rows[0].count) > 0) {
        throw new Error("Cannot delete role: users are assigned to this role");
      }

      const query = "DELETE FROM roles WHERE id = $1 RETURNING id, name";
      const result = await db.query(query, [safeId]);

      if (result.rows.length === 0) {
        throw new Error("Role not found");
      }

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get users by role (uses users.role_id FK)
   *
   * TYPE SAFE: Validates roleId is a positive integer
   *
   * @param {number|string} roleId - Role ID (will be coerced to integer)
   * @param {Object} options - Pagination options
   * @param {number} options.page - Page number (default: 1)
   * @param {number} options.limit - Items per page (default: 10)
   * @returns {Promise<Object>} Object with users array and pagination metadata
   * @throws {Error} If roleId is not a valid positive integer
   */
  static async getUsersByRole(roleId, options = {}) {
    // TYPE SAFETY: Ensure roleId is a valid positive integer
    const safeRoleId = toSafeInteger(roleId, "roleId", {
      min: 1,
      allowNull: false,
    });

    const page = toSafeInteger(options.page || 1, "page", {
      min: 1,
      allowNull: false,
    });
    const limit = toSafeInteger(options.limit || 10, "limit", {
      min: 1,
      max: 200,
      allowNull: false,
    });

    const offset = (page - 1) * limit;

    // Get total count for pagination metadata
    const countQuery = `
      SELECT COUNT(*) as total
      FROM users u
      WHERE u.role_id = $1 AND u.is_active = true
    `;
    const countResult = await db.query(countQuery, [safeRoleId]);
    const total = parseInt(countResult.rows[0].total);

    // Get paginated users
    const query = `
      SELECT 
        u.id, 
        u.email, 
        u.first_name, 
        u.last_name, 
        u.is_active,
        u.created_at
      FROM users u
      WHERE u.role_id = $1 AND u.is_active = true
      ORDER BY u.first_name, u.last_name
      LIMIT $2 OFFSET $3
    `;
    const result = await db.query(query, [safeRoleId, limit, offset]);

    return {
      users: result.rows,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}

module.exports = Role;
