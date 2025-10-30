import { test, expect } from '@playwright/test';

test.describe('TrossApp Backend API E2E Tests', () => {
  test('API health endpoint should respond correctly', async ({ request }) => {
    const response = await request.get('/api/health');
    expect(response.ok()).toBeTruthy();
    
    const json = await response.json();
    expect(json.status).toBe('healthy');
    expect(json.timestamp).toBeTruthy();
    expect(json.uptime).toBeGreaterThan(0);
    expect(json.environment).toBe('development');
    expect(json.version).toBe('1.0.0');
    expect(json.services).toBeDefined();
    expect(json.services.memory.status).toBe('normal');
    expect(json.services.database.status).toBe('healthy');
  });

  test('Development auth endpoint should respond', async ({ request }) => {
    const response = await request.get('/api/dev/status');
    expect(response.ok()).toBeTruthy();
    
    const json = await response.json();
    expect(json.development_mode).toBe(true);
    expect(json.test_auth_enabled).toBe(true);
    expect(json.available_endpoints).toBeDefined();
    expect(json.instructions).toBeDefined();
  });

  test('Authentication endpoints should be accessible', async ({ request }) => {
    const response = await request.get('/api/dev/token');
    expect(response.ok()).toBeTruthy();
    
    const json = await response.json();
    expect(json.token).toBeDefined();
    expect(json.user).toBeDefined();
    expect(json.user.name).toContain('Technician');
  });

  test('404 for unknown endpoints', async ({ request }) => {
    const response = await request.get('/api/nonexistent');
    expect(response.status()).toBe(404);
    
    const json = await response.json();
    expect(json.error).toBe('API endpoint not found');
    expect(json.path).toBe('/api/nonexistent');
  });
});

test.describe('TrossApp Future Features E2E', () => {
  test.skip('Work Order Management (Future)', async ({ page }) => {
    // TODO: Test work order creation flow when frontend is built
    await page.goto('/dashboard');
    await expect(page.locator('h1')).toContainText('Work Orders');
  });

  test.skip('Technician Assignment (Future)', async ({ page }) => {
    // TODO: Test technician assignment when implemented
    await page.goto('/assignments');
    await expect(page.locator('.technician-list')).toBeVisible();
  });
});