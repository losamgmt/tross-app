// Test Users Configuration for Development
// Five users representing each role in the TrossApp hierarchy
//
// ARCHITECTURE: File-based dev users with DB-consistent structure
// - Same schema as real database users (role_id, not role string)
// - id: null (dev users don't exist in DB, no foreign key conflicts)
// - auth0_id is the unique identifier for dev users
// - Allows dev auth WITHOUT database queries or dependencies

const TEST_USERS = {
  admin: {
    id: null, // No DB record - prevents foreign key conflicts
    auth0_id: "dev|admin001",
    email: "admin@trossapp.dev",
    first_name: "Sarah",
    last_name: "Administrator",
    role_id: 1, // FK reference (not enforced for dev users)
    role: "admin", // Denormalized for convenience
    is_active: true,
    provider: "development",
    created_at: "2025-01-01T00:00:00.000Z",
    updated_at: "2025-01-01T00:00:00.000Z",
  },
  manager: {
    id: null,
    auth0_id: "dev|manager001",
    email: "manager@trossapp.dev",
    first_name: "Mike",
    last_name: "Manager",
    role_id: 2,
    role: "manager",
    is_active: true,
    provider: "development",
    created_at: "2025-01-01T00:00:00.000Z",
    updated_at: "2025-01-01T00:00:00.000Z",
  },
  dispatcher: {
    id: null,
    auth0_id: "dev|dispatcher001",
    email: "dispatcher@trossapp.dev",
    first_name: "Diana",
    last_name: "Dispatcher",
    role_id: 3,
    role: "dispatcher",
    is_active: true,
    provider: "development",
    created_at: "2025-01-01T00:00:00.000Z",
    updated_at: "2025-01-01T00:00:00.000Z",
  },
  technician: {
    id: null,
    auth0_id: "dev|tech001",
    email: "technician@trossapp.dev",
    first_name: "Tom",
    last_name: "Technician",
    role_id: 4,
    role: "technician",
    is_active: true,
    provider: "development",
    created_at: "2025-01-01T00:00:00.000Z",
    updated_at: "2025-01-01T00:00:00.000Z",
  },
  client: {
    id: null,
    auth0_id: "dev|client001",
    email: "client@trossapp.dev",
    first_name: "Carol",
    last_name: "Client",
    role_id: 5,
    role: "client",
    is_active: true,
    provider: "development",
    created_at: "2025-01-01T00:00:00.000Z",
    updated_at: "2025-01-01T00:00:00.000Z",
  },
};

module.exports = { TEST_USERS };
