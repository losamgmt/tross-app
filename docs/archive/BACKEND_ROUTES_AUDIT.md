# Backend Routes Audit

**Date**: October 16, 2025  
**Status**: ✅ Audit Complete  
**Goal**: Identify missing CRUD endpoints for complete admin interface

---

## Current Backend Routes

### Authentication Routes (`/api/auth`)

#### ✅ Implemented

- `GET /api/auth/me` - Get current user profile (authenticated)
- `PUT /api/auth/me` - Update current user profile (authenticated)
- `GET /api/auth/users` - Get all users (admin only)
- `PUT /api/auth/users/:id/role` - Assign role to user (admin only)
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout and invalidate tokens
- `POST /api/auth/logout-all` - Logout from all sessions
- `GET /api/auth/sessions` - Get user sessions

#### ❌ Missing - User CRUD

- `POST /api/auth/users` - **Create new user (admin only)**
- `PUT /api/auth/users/:id` - **Update user details (admin only)**
- `DELETE /api/auth/users/:id` - **Delete user (admin only)**

### Role Routes (`/api/roles`)

#### ✅ Implemented

- `GET /api/roles` - List all roles
- `GET /api/roles/:id` - Get role by ID
- `GET /api/roles/:id/users` - Get users with specific role

#### ❌ Missing - Role CRUD

- `POST /api/roles` - **Create new role (admin only)**
- `PUT /api/roles/:id` - **Update role name (admin only)**
- `DELETE /api/roles/:id` - **Delete role (admin only)**

### User-Role Association

#### ✅ Implemented

- Assign role to user: `PUT /api/auth/users/:id/role`

#### ❌ Missing

- `DELETE /api/auth/users/:userId/roles/:roleId` - **Remove role from user (admin only)**

---

## Model Methods Assessment

### User Model (`backend/db/models/User.js`)

#### ✅ Existing Methods

- `findByAuth0Id(auth0Id)` - Find user by Auth0 ID with role
- `createFromAuth0(auth0Data)` - Create user from Auth0 data
- `findOrCreate(auth0Data)` - Find or create from Auth0
- `getAll()` - Get all users with roles
- `update(id, updates)` - Update user profile (first_name, last_name, is_active)
- `addRole(userId, roleId)` - Assign role to user
- `removeRole(userId, roleId)` - Remove role from user
- `hasRole(userId, roleId)` - Check if user has role
- `getRoles(userId)` - Get user's roles

#### ❌ Missing Methods

- `create(userData)` - **Create user manually (without Auth0)**
- `delete(id)` - **Delete user by ID**
- `findById(id)` - **Find user by ID** (we only have findByAuth0Id)

### Role Model (`backend/db/models/Role.js`)

#### ✅ Existing Methods

- `findAll()` - Get all roles
- `findById(id)` - Get role by ID
- `getUsersByRole(roleId)` - Get users with role
- `getByName(name)` - Get role by name
- `create(name)` - Create new role ✅
- `update(id, name)` - Update role name ✅
- `delete(id)` - Delete role (with user check) ✅

**Note**: Role model has complete CRUD methods! Just need to expose via routes.

---

## Security & Validation Assessment

### Current Implementation: ✅ Solid

- ✅ `authenticateToken` middleware - JWT validation
- ✅ `requireAdmin` middleware - Admin-only access
- ✅ Audit logging via `auditService`
- ✅ Field-level validation (allowed fields only)
- ✅ Error handling with proper HTTP status codes
- ✅ Swagger documentation for existing endpoints

### Required for New Endpoints

- ✅ Admin-only access via `requireAdmin`
- ✅ Input validation middleware (already in place)
- ✅ Audit logging for all operations
- ✅ Error handling (404, 400, 409, 500)
- ✅ Swagger @openapi annotations

---

## Implementation Priority

### Phase 1: User CRUD Endpoints (HIGH)

1. **POST /api/auth/users** - Create user
   - Admin only
   - Validate: email (required, unique), first_name, last_name, role_id (optional)
   - Audit log creation
   - Return created user

2. **PUT /api/auth/users/:id** - Update user
   - Admin only
   - Validate: email (unique if changed), first_name, last_name, is_active
   - Cannot update auth0_id
   - Audit log update
   - Return updated user

3. **DELETE /api/auth/users/:id** - Delete user
   - Admin only
   - Soft delete (set is_active = false) OR hard delete with cascade
   - Cannot delete self
   - Audit log deletion
   - Return success message

### Phase 2: Role CRUD Endpoints (HIGH)

1. **POST /api/roles** - Create role
   - Admin only
   - Validate: name (required, unique, lowercase)
   - Audit log creation
   - Return created role

2. **PUT /api/roles/:id** - Update role
   - Admin only
   - Validate: name (required, unique if changed)
   - Cannot update protected roles (admin, client)
   - Audit log update
   - Return updated role

3. **DELETE /api/roles/:id** - Delete role
   - Admin only
   - Check if users have this role (block if yes)
   - Cannot delete protected roles (admin, client)
   - Audit log deletion
   - Return success message

### Phase 3: User-Role Association (MEDIUM)

1. **DELETE /api/auth/users/:userId/roles/:roleId** - Remove role
   - Admin only
   - Validate: user and role exist
   - Cannot remove last role from user
   - Audit log role removal
   - Return success message

---

## Model Methods to Add

### User Model Additions

```javascript
// Find user by ID (not Auth0 ID)
static async findById(id) {
  const query = `
    SELECT u.*, r.name as role
    FROM users u
    LEFT JOIN user_roles ur ON u.id = ur.user_id
    LEFT JOIN roles r ON ur.role_id = r.id
    WHERE u.id = $1
  `;
  const result = await db.query(query, [id]);
  return result.rows[0] || null;
}

// Create user manually (admin function)
static async create(userData) {
  const { email, first_name, last_name, role_id } = userData;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Insert user (no auth0_id - this is for manual creation)
    const userQuery = `
      INSERT INTO users (email, first_name, last_name)
      VALUES ($1, $2, $3)
      RETURNING *
    `;
    const userResult = await client.query(userQuery, [email, first_name, last_name]);
    const user = userResult.rows[0];

    // Assign role if provided, otherwise default to 'client'
    const defaultRoleId = role_id || (await Role.getByName('client')).id;
    await client.query(
      'INSERT INTO user_roles (user_id, role_id) VALUES ($1, $2)',
      [user.id, defaultRoleId]
    );

    await client.query('COMMIT');
    return await this.findById(user.id);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

// Delete user (soft or hard)
static async delete(id, hardDelete = false) {
  if (hardDelete) {
    // Hard delete - cascade user_roles
    const query = 'DELETE FROM users WHERE id = $1 RETURNING *';
    const result = await db.query(query, [id]);
    return result.rows[0];
  } else {
    // Soft delete - set is_active = false
    const query = `
      UPDATE users
      SET is_active = false
      WHERE id = $1
      RETURNING *
    `;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }
}
```

---

## Swagger Documentation Gaps

### Current Status

- ✅ All implemented endpoints have @openapi annotations
- ✅ Schemas defined: User, Role, Session, HealthStatus, Error
- ✅ Security scheme: bearerAuth

### Required

- ❌ Add @openapi annotations for all new endpoints
- ❌ Verify schema completeness
- ❌ Add examples for request bodies
- ❌ Document all error codes (400, 401, 403, 404, 409, 500)

---

## Testing Requirements

### Integration Tests Needed

1. **User CRUD**
   - Create user (success, duplicate email, missing fields)
   - Update user (success, invalid ID, unauthorized)
   - Delete user (success, cannot delete self, invalid ID)

2. **Role CRUD**
   - Create role (success, duplicate name, missing name)
   - Update role (success, protected role, invalid ID)
   - Delete role (success, has users, protected role)

3. **User-Role Association**
   - Remove role (success, last role, invalid IDs)

4. **Admin-Only Access**
   - Non-admin user attempts CRUD (all should return 403)
   - Unauthenticated attempts (all should return 401)

5. **Audit Logging**
   - Verify all CRUD operations logged
   - Check log contains: user_id, action, resource_type, resource_id

---

## Summary

### Total Endpoints Needed: **7**

✅ **Existing**: 11 endpoints  
❌ **Missing**: 7 endpoints  
📊 **Completeness**: 61% (11/18)

### Breakdown

- User CRUD: 3 endpoints
- Role CRUD: 3 endpoints
- User-Role removal: 1 endpoint

### Model Status

- User Model: Needs 3 methods (`findById`, `create`, `delete`)
- Role Model: ✅ Complete (has all CRUD methods)

### Estimated Implementation Time

- User CRUD endpoints + model methods: **2-3 hours**
- Role CRUD endpoints: **1-2 hours** (models ready)
- User-Role removal: **30 minutes**
- Integration tests: **2-3 hours**
- Swagger documentation: **1 hour**
- **Total**: **6-9 hours** (1-2 days)

---

## Next Steps

1. ✅ Complete this audit
2. ⏳ Mark todo as "in-progress" → "completed"
3. ⏳ Start implementing User model methods
4. ⏳ Implement User CRUD endpoints
5. ⏳ Implement Role CRUD endpoints
6. ⏳ Implement User-Role removal
7. ⏳ Update Swagger documentation
8. ⏳ Write integration tests
9. ⏳ Verify all tests pass

**Status**: Ready to implement! 🚀
