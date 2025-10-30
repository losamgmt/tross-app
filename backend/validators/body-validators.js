/**
 * Request Body Validation Middleware
 *
 * Comprehensive validation for all POST/PUT endpoints using Joi.
 * Ensures data integrity before it reaches the database.
 *
 * Philosophy: Fail fast with clear, actionable error messages.
 *
 * Migrated from middleware/validation.js to consolidate all validators.
 */
const Joi = require("joi");
const { HTTP_STATUS } = require("../config/constants");

/**
 * Helper function to create validation middleware
 * DRY principle: Single error handler for all validators
 */
const createValidator = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body, {
    abortEarly: false, // Return all errors, not just the first
    stripUnknown: true, // Remove unknown fields for security
  });

  if (error) {
    return res.status(HTTP_STATUS.BAD_REQUEST).json({
      error: "Validation Error",
      message: error.details[0].message,
      details: error.details.map((d) => ({
        field: d.path.join("."),
        message: d.message,
      })),
      timestamp: new Date().toISOString(),
    });
  }

  next();
};

/**
 * User Creation Validation
 * Validates: POST /api/users
 */
const validateUserCreate = createValidator(
  Joi.object({
    email: Joi.string()
      .email()
      .required()
      .trim()
      .lowercase()
      .max(255)
      .messages({
        "string.email": "Email must be a valid email address",
        "string.empty": "Email is required",
        "any.required": "Email is required",
      }),
    first_name: Joi.string().min(1).max(100).required().trim().messages({
      "string.empty": "First name is required",
      "string.max": "First name cannot exceed 100 characters",
      "any.required": "First name is required",
    }),
    last_name: Joi.string().min(1).max(100).required().trim().messages({
      "string.empty": "Last name is required",
      "string.max": "Last name cannot exceed 100 characters",
      "any.required": "Last name is required",
    }),
    role_id: Joi.number().integer().positive().optional().messages({
      "number.base": "Role ID must be a number",
      "number.integer": "Role ID must be an integer",
      "number.positive": "Role ID must be positive",
    }),
  }),
);

/**
 * User Profile Update Validation
 * Validates: PUT /api/auth/me, PUT /api/users/:id
 */
const validateProfileUpdate = createValidator(
  Joi.object({
    email: Joi.string()
      .email()
      .optional()
      .trim()
      .lowercase()
      .max(255)
      .messages({
        "string.email": "Email must be a valid email address",
        "string.max": "Email cannot exceed 255 characters",
      }),
    first_name: Joi.string().min(1).max(100).optional().trim().messages({
      "string.empty": "First name cannot be empty",
      "string.max": "First name cannot exceed 100 characters",
    }),
    last_name: Joi.string().min(1).max(100).optional().trim().messages({
      "string.empty": "Last name cannot be empty",
      "string.max": "Last name cannot exceed 100 characters",
    }),
    is_active: Joi.boolean().optional().messages({
      "boolean.base": "is_active must be true or false",
    }),
  })
    .min(1)
    .messages({
      "object.min": "At least one field must be provided for update",
    }),
);

/**
 * Role Creation Validation
 * Validates: POST /api/roles
 */
const validateRoleCreate = createValidator(
  Joi.object({
    name: Joi.string()
      .min(1)
      .max(50)
      .required()
      .trim()
      .lowercase()
      .pattern(/^[a-z][a-z0-9_]*$/)
      .messages({
        "string.empty": "Role name is required",
        "string.max": "Role name cannot exceed 50 characters",
        "string.pattern.base":
          "Role name must start with a letter and contain only lowercase letters, numbers, and underscores",
        "any.required": "Role name is required",
      }),
    description: Joi.string().max(255).optional().trim().messages({
      "string.max": "Description cannot exceed 255 characters",
    }),
    permissions: Joi.array().items(Joi.string()).optional().messages({
      "array.base": "Permissions must be an array of strings",
    }),
  }),
);

/**
 * Role Update Validation
 * Validates: PUT /api/roles/:id
 */
const validateRoleUpdate = createValidator(
  Joi.object({
    name: Joi.string()
      .min(1)
      .max(50)
      .optional()
      .trim()
      .lowercase()
      .pattern(/^[a-z][a-z0-9_]*$/)
      .messages({
        "string.empty": "Role name cannot be empty",
        "string.max": "Role name cannot exceed 50 characters",
        "string.pattern.base":
          "Role name must start with a letter and contain only lowercase letters, numbers, and underscores",
      }),
    description: Joi.string().max(255).optional().trim().allow("").messages({
      "string.max": "Description cannot exceed 255 characters",
    }),
    permissions: Joi.array().items(Joi.string()).optional().messages({
      "array.base": "Permissions must be an array of strings",
    }),
  })
    .min(1)
    .messages({
      "object.min": "At least one field must be provided for update",
    }),
);

/**
 * Role Assignment Validation
 * Validates: PUT /api/users/:id/role
 */
const validateRoleAssignment = createValidator(
  Joi.object({
    role_id: Joi.number().integer().positive().required().messages({
      "number.base": "Role ID must be a number",
      "number.integer": "Role ID must be an integer",
      "number.positive": "Role ID must be positive",
      "any.required": "Role ID is required",
    }),
  }),
);

module.exports = {
  validateUserCreate,
  validateProfileUpdate,
  validateRoleAssignment,
  validateRoleCreate,
  validateRoleUpdate,
};
