/**
 * Application Constants
 * Single source of truth for all application constants
 * KISS Principle: Eliminate magic strings and magic numbers
 */

// Environment Constants
const ENVIRONMENTS = Object.freeze({
  DEVELOPMENT: "development",
  STAGING: "staging",
  PRODUCTION: "production",
  TEST: "test",
});

// Authentication Constants
const AUTH = Object.freeze({
  AUTH_MODES: Object.freeze({
    DEVELOPMENT: "development",
    AUTH0: "auth0",
  }),
  PROVIDERS: Object.freeze({
    DEVELOPMENT_JWT: "development",
    AUTH0: "auth0",
  }),
  JWT: Object.freeze({
    ALGORITHM: "HS256",
    DEFAULT_EXPIRY: "24h",
    BEARER_PREFIX: "Bearer ",
  }),
});

// User Role Constants
const USER_ROLES = Object.freeze({
  ADMIN: "admin",
  MANAGER: "manager",
  DISPATCHER: "dispatcher",
  TECHNICIAN: "technician",
  CLIENT: "client",
});

// HTTP Status Constants
const HTTP_STATUS = Object.freeze({
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  CONFLICT: 409,
  INTERNAL_SERVER_ERROR: 500,
  NOT_IMPLEMENTED: 501,
  SERVICE_UNAVAILABLE: 503,
});

// Security Configuration Constants
const SECURITY = Object.freeze({
  RATE_LIMITING: Object.freeze({
    WINDOW_MS: 15 * 60 * 1000, // 15 minutes
    API_MAX_REQUESTS: 50, // API requests per window
    AUTH_MAX_REQUESTS: 10, // Auth attempts per window
    DEFAULT_MAX_REQUESTS: 100, // Default requests per window
  }),
  REQUEST_LIMITS: Object.freeze({
    JSON_BODY_SIZE: "10mb",
    URL_ENCODED_SIZE: "10mb",
  }),
  HEADERS: Object.freeze({
    CSP_UNSAFE_INLINE: "'unsafe-inline'",
    CSP_SELF: "'self'",
    CSP_NONE: "'none'",
  }),
});

// Database Configuration Constants
// KISS Principle: Single source of truth for all database credentials
// Dev and Test use SAME credentials (postgres/tross123) for simplicity
// Production credentials MUST come from environment variables
const DATABASE = Object.freeze({
  DEV: Object.freeze({
    HOST: "localhost",
    PORT: 5432,
    NAME: "trossapp_dev",
    USER: "postgres",
    PASSWORD: "tross123", // Dev only, never use in production
    POOL: Object.freeze({
      MIN: 2,
      MAX: 20,
      IDLE_TIMEOUT_MS: 30000,
      CONNECTION_TIMEOUT_MS: 5000,
    }),
  }),
  TEST: Object.freeze({
    HOST: "localhost",
    PORT: 5433,
    NAME: "trossapp_test",
    USER: "postgres", // SAME as dev for simplicity
    PASSWORD: "tross123", // SAME as dev for simplicity
    POOL: Object.freeze({
      MIN: 1,
      MAX: 5,
      IDLE_TIMEOUT_MS: 1000,
      CONNECTION_TIMEOUT_MS: 3000,
    }),
  }),
  PROD: Object.freeze({
    // Production values MUST come from secure environment variables
    // Never use default values in production
    MIN_PASSWORD_LENGTH: 16,
  }),
});

// Redis Configuration Constants
const REDIS = Object.freeze({
  DEV: Object.freeze({
    HOST: "localhost",
    PORT: 6379,
    DB: 0,
  }),
  TEST: Object.freeze({
    HOST: "localhost",
    PORT: 6379,
    DB: 1, // Different DB index for test isolation
  }),
  PROD: Object.freeze({
    DB: 0,
    // Host, port, password MUST come from environment variables
  }),
});

// API Endpoints
const API_ENDPOINTS = Object.freeze({
  HEALTH: "/api/health",
  AUTH: "/api/auth",
  AUTH0: "/api/auth0",
  DEV: "/api/dev",
  ROLES: "/api/roles",
});

module.exports = Object.freeze({
  ENVIRONMENTS,
  AUTH,
  USER_ROLES,
  HTTP_STATUS,
  SECURITY,
  DATABASE,
  REDIS,
  API_ENDPOINTS,
});
