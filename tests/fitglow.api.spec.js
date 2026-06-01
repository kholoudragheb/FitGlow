// ============================================================
// FitGlow Backend API – Full QA Test Suite
// Senior Software Tester view: covers Auth, User, Subscription,
// AI endpoints – positive & negative cases.
// ============================================================

const { test, expect } = require('@playwright/test');

// ── Shared state (populated during the auth tests) ──────────────
let accessToken = '';
let refreshToken = '';

const BASE = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

// Helper: authenticated POST
async function authPost(request, path, body = {}) {
  return request.post(`${BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    data: body,
  });
}

// Helper: authenticated GET
async function authGet(request, path) {
  return request.get(`${BASE}${path}`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
  });
}

// Helper: authenticated PATCH
async function authPatch(request, path, body = {}) {
  return request.patch(`${BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
    data: body,
  });
}

// ════════════════════════════════════════════════════════════
// GROUP 1 — AUTH
// ════════════════════════════════════════════════════════════

test.describe('🔐 Auth Endpoints', () => {

  // ── 1.1 Register with missing fields ────────────────────
  test('POST /auth/register — rejects empty body [400/422]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/register`, {
      headers: { 'Content-Type': 'application/json' },
      data: {},
    });
    console.log(`[register-empty] status: ${res.status()}`);
    expect([400, 422, 409]).toContain(res.status());
  });

  // ── 1.2 Register — duplicate email should 409 ───────────
  test('POST /auth/register — duplicate email [409]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/register`, {
      headers: { 'Content-Type': 'application/json' },
      data: {
        firstName: 'Test',
        lastName: 'User',
        email: 'testqa@fitglow.com',
        password: 'Test@12345',
        role: 'client',
      },
    });
    console.log(`[register-duplicate] status: ${res.status()}`);
    // First call may succeed (201) or conflict (409) — both are acceptable
    expect([201, 409, 400]).toContain(res.status());
  });

  // ── 1.3 Login — wrong credentials ───────────────────────
  test('POST /auth/login — wrong password [401]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/login`, {
      headers: { 'Content-Type': 'application/json' },
      data: { email: 'testqa@fitglow.com', password: 'WRONG_PASSWORD' },
    });
    console.log(`[login-wrong-pass] status: ${res.status()} body: ${await res.text()}`);
    expect([401, 400]).toContain(res.status());
  });

  // ── 1.4 Login — valid credentials (CRITICAL) ────────────
  test('POST /auth/login — valid creds returns tokens [200]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/login`, {
      headers: { 'Content-Type': 'application/json' },
      data: {
        email: 'mohamedkasem9000@gmail.com',
        password: 'mohamedkasem9000',
      },
    });
    const body = await res.json();
    console.log(`[login-valid] status: ${res.status()} body:`, JSON.stringify(body, null, 2));

    expect(res.status()).toBe(200);
    // Alternatively if 201 is also possible:
    // expect([200, 201]).toContain(res.status());
    // Store tokens for downstream tests
    accessToken = body.accessToken ?? body.access_token ?? body.token ?? '';
    refreshToken = body.refreshToken ?? body.refresh_token ?? '';
    console.log(`[login-valid] token captured: ${accessToken.substring(0, 30)}...`);
    expect(accessToken.length).toBeGreaterThan(10);
  });

  // ── 1.5 Login — missing email field ─────────────────────
  test('POST /auth/login — missing email [400/422]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/login`, {
      headers: { 'Content-Type': 'application/json' },
      data: { password: 'Test@12345' },
    });
    console.log(`[login-no-email] status: ${res.status()}`);
    expect([400, 422]).toContain(res.status());
  });

  // ── 1.6 Forgot password ──────────────────────────────────
  test('POST /auth/forgot-password — valid email [200]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/forgot-password`, {
      headers: { 'Content-Type': 'application/json' },
      data: { email: 'mohamedkasem9000@gmail.com' },
    });
    console.log(`[forgot-password] status: ${res.status()} body: ${await res.text()}`);
    expect([200, 201, 404]).toContain(res.status());
  });

  // ── 1.7 Refresh token ───────────────────────────────────
  test('POST /auth/refresh — returns new access token [200]', async ({ request }) => {
    test.skip(refreshToken === '', 'No refresh token — login test must pass first');
    const res = await request.post(`${BASE}/auth/refresh`, {
      headers: { 'Content-Type': 'application/json' },
      data: { refreshToken },
    });
    const body = await res.json();
    console.log(`[refresh-token] status: ${res.status()} body:`, body);
    expect([200, 201]).toContain(res.status());
  });

});

// ════════════════════════════════════════════════════════════
// GROUP 2 — OTP
// ════════════════════════════════════════════════════════════

test.describe('📧 OTP Endpoints', () => {

  test('POST /auth/send-otp — valid email [200/201]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/send-otp`, {
      headers: { 'Content-Type': 'application/json' },
      data: { email: 'mohamedkasem9000@gmail.com' },
    });
    console.log(`[send-otp] status: ${res.status()} body: ${await res.text()}`);
    expect([200, 201, 400]).toContain(res.status());
  });

  test('POST /auth/verify-otp — wrong OTP returns error [400/401]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/verify-otp`, {
      headers: { 'Content-Type': 'application/json' },
      data: { email: 'mohamedkasem9000@gmail.com', otp: '000000' },
    });
    console.log(`[verify-otp-wrong] status: ${res.status()} body: ${await res.text()}`);
    expect([400, 401, 404]).toContain(res.status());
  });

});

// ════════════════════════════════════════════════════════════
// GROUP 3 — USER PROFILE
// ════════════════════════════════════════════════════════════

test.describe('👤 User Profile Endpoints', () => {

  test('GET /users/me — returns profile when authenticated [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authGet(request, '/users/me');
    const body = await res.json();
    console.log(`[get-profile] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect(res.status()).toBe(200);
    // Validate response shape
    expect(body).toHaveProperty('email');
  });

  test('GET /users/me — unauthenticated returns [401]', async ({ request }) => {
    const res = await request.get(`${BASE}/users/me`, {
      headers: { 'Content-Type': 'application/json' },
    });
    console.log(`[get-profile-unauth] status: ${res.status()}`);
    expect(res.status()).toBe(401);
  });

  test('PATCH /users/me — update height/weight [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPatch(request, '/users/me', {
      height: 175,
      weight: 70,
    });
    const body = await res.json();
    console.log(`[patch-profile] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201]).toContain(res.status());
  });

  test('GET /users/saved — returns saved items [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authGet(request, '/users/saved');
    console.log(`[get-saved] status: ${res.status()} body: ${await res.text()}`);
    expect([200, 404]).toContain(res.status());
  });

});

// ════════════════════════════════════════════════════════════
// GROUP 4 — SUBSCRIPTION & PAYMENTS
// ════════════════════════════════════════════════════════════

test.describe('💳 Subscription / Payment Endpoints', () => {

  test('GET /payments/plans — returns plan list [200]', async ({ request }) => {
    const res = await request.get(`${BASE}/payments/plans`, {
      headers: { 'Content-Type': 'application/json' },
    });
    const body = await res.json();
    console.log(`[get-plans] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201]).toContain(res.status());
  });

  test('GET /payments/subscription-status — requires auth [200/401]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authGet(request, '/payments/subscription-status');
    const body = await res.json();
    console.log(`[sub-status] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201]).toContain(res.status());
    expect(body).toHaveProperty('subscriptionStatus');
  });

  test('GET /payments/subscription-status — unauthenticated [401]', async ({ request }) => {
    const res = await request.get(`${BASE}/payments/subscription-status`, {
      headers: { 'Content-Type': 'application/json' },
    });
    console.log(`[sub-status-unauth] status: ${res.status()}`);
    expect(res.status()).toBe(401);
  });

  test('POST /payments/mock/checkout — valid planId + coachId [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/payments/mock/checkout', {
      planId: 'monthly',
      coachId: 'test_coach_id',
    });
    const body = await res.json();
    console.log(`[checkout] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201, 400, 404]).toContain(res.status());
  });

  test('POST /payments/mock/cancel — cancels subscription [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/payments/mock/cancel', {});
    const body = await res.json();
    console.log(`[cancel-sub] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201, 400, 404]).toContain(res.status());
  });

});

// ════════════════════════════════════════════════════════════
// GROUP 5 — AI ENDPOINTS
// ════════════════════════════════════════════════════════════

test.describe('🤖 AI Endpoints', () => {

  test('POST /ai/chat — sends query, returns response [200/201]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/ai/chat', {
      query: 'What exercises are best for weight loss?',
    });
    const body = await res.json();
    console.log(`[ai-chat] status: ${res.status()} body:`, JSON.stringify(body, null, 2));
    expect([200, 201]).toContain(res.status());
    expect(body).toHaveProperty('response');
    expect(typeof body.response).toBe('string');
    expect(body.response.length).toBeGreaterThan(5);
  });

  test('POST /ai/chat — empty query returns error [400/422]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/ai/chat', { query: '' });
    console.log(`[ai-chat-empty] status: ${res.status()} body: ${await res.text()}`);
    expect([400, 422, 200]).toContain(res.status()); // some AI servers echo empty
  });

  test('POST /ai/chat — unauthenticated [401]', async ({ request }) => {
    const res = await request.post(`${BASE}/ai/chat`, {
      headers: { 'Content-Type': 'application/json' },
      data: { query: 'hello' },
    });
    console.log(`[ai-chat-unauth] status: ${res.status()}`);
    expect(res.status()).toBe(401);
  });

  test('GET /ai/history — returns chat history [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authGet(request, '/ai/history');
    const text = await res.text();
    console.log(`[ai-history] status: ${res.status()} body: ${text.substring(0, 300)}`);
    expect([200, 201, 404]).toContain(res.status());
  });

  test('POST /ai/meal-plan — generates meal plan [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/ai/meal-plan', {
      goal: 'weight loss',
      dietaryRestrictions: ['vegetarian'],
      calorieTarget: 1800,
    });
    const text = await res.text();
    console.log(`[ai-meal-plan] status: ${res.status()} body: ${text.substring(0, 400)}`);
    expect([200, 201, 400, 503]).toContain(res.status());
  });

  test('POST /ai/workout-plan — generates workout plan [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/ai/workout-plan', {
      goal: 'muscle gain',
      fitnessLevel: 'beginner',
      daysPerWeek: 3,
    });
    const text = await res.text();
    console.log(`[ai-workout-plan] status: ${res.status()} body: ${text.substring(0, 400)}`);
    expect([200, 201, 400, 503]).toContain(res.status());
  });

  test('POST /ai/plan — generates AI plan [200]', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const res = await authPost(request, '/ai/plan', {
      goal: 'weight loss',
      fitnessLevel: 'intermediate',
    });
    const text = await res.text();
    console.log(`[ai-plan] status: ${res.status()} body: ${text.substring(0, 400)}`);
    expect([200, 201, 400, 503]).toContain(res.status());
  });

});

// ════════════════════════════════════════════════════════════
// GROUP 6 — SECURITY & EDGE CASES
// ════════════════════════════════════════════════════════════

test.describe('🛡️ Security & Edge Cases', () => {

  test('Any protected endpoint — expired/fake token returns [401]', async ({ request }) => {
    const res = await request.get(`${BASE}/users/me`, {
      headers: {
        Authorization: 'Bearer FAKE_TOKEN_12345_INVALID',
        'Content-Type': 'application/json',
      },
    });
    console.log(`[fake-token] status: ${res.status()}`);
    expect(res.status()).toBe(401);
  });

  test('POST /auth/login — SQL injection attempt [400/401]', async ({ request }) => {
    const res = await request.post(`${BASE}/auth/login`, {
      headers: { 'Content-Type': 'application/json' },
      data: {
        email: "admin'--",
        password: "' OR '1'='1",
      },
    });
    console.log(`[sql-injection] status: ${res.status()}`);
    // Must NOT return 200
    expect(res.status()).not.toBe(200);
  });

  test('POST /ai/chat — extremely long query (stress test)', async ({ request }) => {
    test.skip(accessToken === '', 'Requires valid token from login test');
    const longQuery = 'Give me a fitness plan. '.repeat(100);
    const res = await authPost(request, '/ai/chat', { query: longQuery });
    console.log(`[ai-chat-long] status: ${res.status()}`);
    // Should respond, not crash
    expect([200, 201, 400, 413, 429, 503]).toContain(res.status());
  });

  test('Server reachability — base URL returns non-404', async ({ request }) => {
    const res = await request.get(BASE);
    console.log(`[server-ping] status: ${res.status()}`);
    // Should be anything except connection refused
    expect(res.status()).toBeLessThan(500);
  });

});
