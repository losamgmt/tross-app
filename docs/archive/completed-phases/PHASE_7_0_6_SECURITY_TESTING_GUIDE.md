# Phase 7.0.6: Security Verification & Manual Testing Guide

## Date: October 19, 2025

## Objective

Manually verify that all three layers of security work correctly:

1. **Route Guards** (frontend routing protection)
2. **Widget-Level Hiding** (UI element visibility)
3. **Backend API Validation** (server-side enforcement)

---

## Test Environment Status

✅ **Backend:** Running on http://localhost:3001
✅ **Frontend:** Running on http://localhost:8080
✅ **Database:** trossapp_dev (port 5433) - HEALTHY
✅ **Test Database:** trossapp_test (port 5434) - HEALTHY

---

## Test Scenarios

### **Scenario 1: Unauthenticated User** 🚫

**Test Steps:**

1. Open browser to `http://localhost:8080/`
2. You should see the **login page** automatically
3. Try to manually navigate to protected routes:
   - `http://localhost:8080/home` → Should redirect to `/login`
   - `http://localhost:8080/profile` → Should redirect to `/login`
   - `http://localhost:8080/admin` → Should redirect to `/login`

**Expected Results:**

- ✅ All protected routes redirect to login page
- ✅ No flash of protected content
- ✅ URL changes to `/login`
- ✅ Clean navigation, no errors in console (F12)

**Security Layer Tested:** Route Guards (Layer 1)

---

### **Scenario 2: Technician User Login** 👷

**Test Steps:**

1. Login with technician credentials:
   - Email: `tech@trossapp.com` (or your test technician email)
   - Password: (your Auth0 password)
2. After successful login, verify:
   - ✅ Redirected to `/home`
   - ✅ Can see home screen
   - ❌ **Admin button is NOT visible** on home screen
3. Try to access allowed routes:
   - Navigate to `/profile` → Should work ✅
   - Navigate to `/home` → Should work ✅
4. Try to access admin routes:
   - Manually navigate to `http://localhost:8080/admin`
   - Should redirect to `/unauthorized` page ❌
   - Unauthorized page should show friendly message
5. Try the "Go Back" button on unauthorized page:
   - Should navigate back to previous page (home)

**Expected Results:**

- ✅ Technician can access home and profile
- ✅ Admin button hidden from UI (Widget-Level Security)
- ✅ Admin route redirects to unauthorized (Route Guard)
- ✅ Unauthorized page displays correctly
- ✅ No console errors

**Security Layers Tested:**

- Route Guards (Layer 1) ✅
- Widget-Level Hiding (Layer 2) ✅

---

### **Scenario 3: Admin User Login** 👑

**Test Steps:**

1. Logout (if logged in as technician)
2. Login with admin credentials:
   - Email: `admin@trossapp.com` (or your test admin email)
   - Password: (your Auth0 password)
3. After successful login, verify:
   - ✅ Redirected to `/home`
   - ✅ Can see home screen
   - ✅ **Admin button IS visible** on home screen
4. Click the admin button:
   - Should navigate to `/admin`
   - Should see "Under Construction" page
   - Should have "Go Back" button
5. Manually navigate to routes:
   - `/home` → Should work ✅
   - `/profile` → Should work ✅
   - `/admin` → Should work ✅
6. Test admin dashboard:
   - Verify construction message displays
   - Click "Go Back" button
   - Should return to home screen

**Expected Results:**

- ✅ Admin can access all routes
- ✅ Admin button visible (Widget-Level Security)
- ✅ Admin dashboard accessible (Route Guard)
- ✅ Under construction page displays correctly
- ✅ Navigation works smoothly
- ✅ No console errors

**Security Layers Tested:**

- Route Guards (Layer 1) ✅
- Widget-Level Hiding (Layer 2) ✅

---

### **Scenario 4: Direct URL Manipulation** 🔐

**Purpose:** Test that route guards can't be bypassed

**Test Steps (as Technician):**

1. Login as technician
2. Open browser DevTools (F12) → Console
3. Try to manipulate navigation:
   ```javascript
   // Try these in console:
   window.location.href = "/admin";
   ```
4. Should redirect to `/unauthorized`

**Test Steps (as Unauthenticated):**

1. Logout completely
2. Try direct URL access:
   - `http://localhost:8080/admin`
   - `http://localhost:8080/home`
   - `http://localhost:8080/profile`
3. All should redirect to `/login`

**Expected Results:**

- ✅ Cannot bypass route guards via JavaScript
- ✅ Cannot bypass route guards via direct URL
- ✅ Always redirected appropriately
- ✅ Debug logs in console show access checks (in development mode)

**Security Layer Tested:** Route Guards (Layer 1) - Bypass Prevention

---

### **Scenario 5: Backend API Validation** 🛡️

**Purpose:** Verify backend enforces authorization (Layer 3)

**Test Steps:**

1. Open browser DevTools (F12) → Network tab
2. Login as technician
3. Watch network requests when navigating
4. Find the API calls (e.g., to `/api/auth/me`)
5. Copy the Authorization token from request headers
6. Open a new terminal and test API directly:

```bash
# Replace YOUR_TOKEN with actual token from network tab
TOKEN="YOUR_TOKEN"

# Test user profile endpoint (should work for technician)
curl -H "Authorization: Bearer $TOKEN" http://localhost:3001/api/auth/me

# Test admin-only endpoints (should fail for technician)
curl -H "Authorization: Bearer $TOKEN" http://localhost:3001/api/users
# Should return 403 Forbidden
```

**Expected Results:**

- ✅ Technician can access their own profile
- ❌ Technician gets 403 on admin endpoints
- ✅ Backend validates role on every request
- ✅ Token is properly validated

**Security Layer Tested:** Backend API (Layer 3)

---

### **Scenario 6: Error Pages** 📄

**Test Steps:**

1. Navigate to non-existent route: `http://localhost:8080/doesnotexist`
   - Should show **404 Not Found** page
   - Should have "Go Back" button
2. As technician, navigate to `/admin`
   - Should show **403 Unauthorized** page
   - Should have friendly message about admin-only access
   - Should have "Go Back" button
3. Test error page (if needed):
   - Trigger an error (e.g., network failure)
   - Should show **Error Page**
   - Should have "Retry" button

**Expected Results:**

- ✅ 404 page displays for unknown routes
- ✅ 403 page displays for unauthorized access
- ✅ Error pages are user-friendly
- ✅ Navigation buttons work
- ✅ Consistent branding and styling

---

## Console Debug Logs to Watch For

When navigating in **development mode**, you should see these debug logs in the browser console (F12):

```
[RouteGuard] Checking access to: /admin
[RouteGuard] Authenticated: true
[RouteGuard] User role: technician
[RouteGuard] Access denied - admin role required
```

These are **intentional** debug logs that help verify security is working. They are stripped from production builds.

---

## Checklist Summary

Use this to track your testing:

### Unauthenticated User:

- [ ] Cannot access /home (redirects to login)
- [ ] Cannot access /profile (redirects to login)
- [ ] Cannot access /admin (redirects to login)
- [ ] No flash of protected content

### Technician User:

- [ ] Can access /home
- [ ] Can access /profile
- [ ] Cannot access /admin (redirects to unauthorized)
- [ ] Admin button NOT visible on home screen
- [ ] Unauthorized page displays correctly

### Admin User:

- [ ] Can access /home
- [ ] Can access /profile
- [ ] Can access /admin
- [ ] Admin button IS visible on home screen
- [ ] Admin dashboard shows "Under Construction"
- [ ] Navigation works smoothly

### Error Pages:

- [ ] 404 page displays for unknown routes
- [ ] Unauthorized page displays for denied access
- [ ] All navigation buttons work

### Backend Validation:

- [ ] API returns 403 for unauthorized requests
- [ ] Token is validated on every request
- [ ] Role is checked server-side

---

## What to Look For (Red Flags)

❌ **Security Issues:**

- Flash of protected content before redirect
- Admin button visible to non-admins
- Direct URL access bypassing guards
- Backend not validating roles
- Console errors during navigation

✅ **Good Signs:**

- Immediate redirects (no content flash)
- Proper role-based UI hiding
- Debug logs showing security checks
- Clean navigation with no errors
- Backend 403 responses for unauthorized requests

---

## After Testing

Once all scenarios pass:

1. **Document Results:**
   - Take screenshots of each scenario
   - Note any issues found
   - Record console logs showing security checks

2. **Update Documentation:**
   - Add security architecture diagram to AUTH_GUIDE.md
   - Document multi-layer security approach
   - Add troubleshooting section

3. **Mark Phase 7.0 Complete:**
   - All security foundations in place ✅
   - Route guards tested ✅
   - Widget-level hiding verified ✅
   - Backend validation confirmed ✅
   - Ready for Phase 7.1 (Admin Dashboard Features)

---

## Next Steps After Phase 7.0.6

**Phase 7.1-7.7: Admin Dashboard Features**

- User management
- Role management
- Audit logs
- Settings
- Full CRUD operations

Estimated: 2-3 weeks

---

_Testing Guide Created: October 19, 2025_
_Let's verify your security is bulletproof! 🛡️_
