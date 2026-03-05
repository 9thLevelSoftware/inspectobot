#!/usr/bin/env node

const args = new Set(process.argv.slice(2));

if (args.has("--help") || args.has("-h")) {
  console.log(`Phase 17 live validation runner

Usage:
  node .planning/phases/17-tenant-auth-and-isolation-validation-closure/live_validation_runner.mjs [--mode verify]

Required environment variables:
  LIVE_EMAIL_A
  LIVE_EMAIL_B
  LIVE_PASSWORD

Optional environment variables:
  LIVE_SUPABASE_URL (fallback: SUPABASE_URL)
  LIVE_SUPABASE_ANON_KEY (fallback: SUPABASE_ANON_KEY)
  LIVE_OLD_PASSWORD (used to assert exposed password no longer authenticates)

Output:
  Prints sanitized JSON evidence for AUTH-01, AUTH-02, FLOW-01, and SEC-01.
`);
  process.exit(0);
}

const mode = args.has("--mode")
  ? process.argv[process.argv.indexOf("--mode") + 1]
  : "verify";

const env = {
  supabaseUrl: process.env.LIVE_SUPABASE_URL || process.env.SUPABASE_URL,
  supabaseAnonKey:
    process.env.LIVE_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY,
  emailA: process.env.LIVE_EMAIL_A,
  emailB: process.env.LIVE_EMAIL_B,
  password: process.env.LIVE_PASSWORD,
  oldPassword: process.env.LIVE_OLD_PASSWORD,
};

const required = ["supabaseUrl", "supabaseAnonKey", "emailA", "emailB", "password"];
for (const key of required) {
  if (!env[key]) {
    console.error(`Missing required environment variable for ${key}`);
    process.exit(1);
  }
}

const baseUrl = env.supabaseUrl.replace(/\/+$/, "");

function nowIso() {
  return new Date().toISOString();
}

async function requestJson(path, options = {}) {
  const response = await fetch(`${baseUrl}${path}`, options);
  const text = await response.text();
  let body;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = { raw: text };
  }
  return { status: response.status, ok: response.ok, body };
}

async function signIn(email, password) {
  const response = await requestJson("/auth/v1/token?grant_type=password", {
    method: "POST",
    headers: {
      apikey: env.supabaseAnonKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, password }),
  });
  if (!response.ok || !response.body?.access_token || !response.body?.user?.id) {
    throw new Error(`Sign-in failed for ${email} (status ${response.status})`);
  }
  return {
    accessToken: response.body.access_token,
    userId: response.body.user.id,
  };
}

async function membershipFor(token, userId) {
  const response = await requestJson(
    `/rest/v1/organization_memberships?select=organization_id,user_id&user_id=eq.${userId}`,
    {
      method: "GET",
      headers: {
        apikey: env.supabaseAnonKey,
        Authorization: `Bearer ${token}`,
      },
    },
  );
  if (!response.ok || !Array.isArray(response.body) || response.body.length === 0) {
    throw new Error(`Membership lookup failed for ${userId} (status ${response.status})`);
  }
  return {
    organizationId: response.body[0].organization_id,
    membershipCount: response.body.length,
  };
}

async function createInspection(token, organizationId, userId) {
  const payload = {
    organization_id: organizationId,
    user_id: userId,
    client_name: "Phase17 Validation Tenant A",
    client_email: "phase17-validation@example.com",
    client_phone: "555-0100",
    property_address: `17 Closure Ln ${Date.now()}`,
    inspection_date: nowIso().slice(0, 10),
    year_built: 2005,
    forms_enabled: ["four_point"],
  };

  const response = await requestJson("/rest/v1/inspections", {
    method: "POST",
    headers: {
      apikey: env.supabaseAnonKey,
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(payload),
  });

  return {
    status: response.status,
    created:
      Array.isArray(response.body) && response.body[0]
        ? {
            id: response.body[0].id,
            organization_id: response.body[0].organization_id,
            user_id: response.body[0].user_id,
            inspection_date: response.body[0].inspection_date,
            year_built: response.body[0].year_built,
          }
        : null,
    error: Array.isArray(response.body) ? null : response.body,
  };
}

async function readInspection(token, inspectionId) {
  const response = await requestJson(
    `/rest/v1/inspections?select=id&id=eq.${inspectionId}`,
    {
      method: "GET",
      headers: {
        apikey: env.supabaseAnonKey,
        Authorization: `Bearer ${token}`,
      },
    },
  );
  return {
    status: response.status,
    count: Array.isArray(response.body) ? response.body.length : 0,
  };
}

async function crossTenantInsert(token, organizationId, userId) {
  const response = await requestJson("/rest/v1/inspections", {
    method: "POST",
    headers: {
      apikey: env.supabaseAnonKey,
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify({
      organization_id: organizationId,
      user_id: userId,
      client_name: "Cross Tenant Attempt",
      client_email: "cross-tenant@example.com",
      client_phone: "555-0199",
      property_address: "Denied Attempt St",
      inspection_date: nowIso().slice(0, 10),
      year_built: 2006,
      forms_enabled: ["four_point"],
    }),
  });
  return {
    status: response.status,
    error: Array.isArray(response.body) ? null : response.body,
  };
}

async function oldPasswordInvalidated(email) {
  if (!env.oldPassword) {
    return null;
  }
  const response = await requestJson("/auth/v1/token?grant_type=password", {
    method: "POST",
    headers: {
      apikey: env.supabaseAnonKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email, password: env.oldPassword }),
  });
  return response.status >= 400;
}

async function run() {
  const tenantASession = await signIn(env.emailA, env.password);
  const tenantAMembership = await membershipFor(tenantASession.accessToken, tenantASession.userId);
  const tenantASecondSession = await signIn(env.emailA, env.password);

  const tenantBSession = await signIn(env.emailB, env.password);
  const tenantBMembership = await membershipFor(tenantBSession.accessToken, tenantBSession.userId);

  const flow = await createInspection(
    tenantASession.accessToken,
    tenantAMembership.organizationId,
    tenantASession.userId,
  );

  const tenantBRead = flow.created
    ? await readInspection(tenantBSession.accessToken, flow.created.id)
    : { status: 0, count: -1 };

  const tenantBCrossInsert = await crossTenantInsert(
    tenantBSession.accessToken,
    tenantAMembership.organizationId,
    tenantASession.userId,
  );

  const output = {
    captured_at: nowIso(),
    supabase_host: new URL(baseUrl).host,
    tenant_a: {
      user_id: tenantASession.userId,
      organization_id: tenantAMembership.organizationId,
      membership_count: tenantAMembership.membershipCount,
      second_signin_user_id: tenantASecondSession.userId,
    },
    tenant_b: {
      user_id: tenantBSession.userId,
      organization_id: tenantBMembership.organizationId,
      membership_count: tenantBMembership.membershipCount,
    },
    flow_01: {
      create_status: flow.status,
      created_inspection: flow.created,
      error: flow.error,
    },
    sec_01: {
      tenant_b_read_status: tenantBRead.status,
      tenant_b_read_count: tenantBRead.count,
      tenant_b_cross_insert_status: tenantBCrossInsert.status,
      tenant_b_cross_insert_error: tenantBCrossInsert.error,
    },
    checks: {
      auth_02_same_user_after_resume: tenantASecondSession.userId === tenantASession.userId,
      org_ids_not_fallback_local:
        !tenantAMembership.organizationId.startsWith("org-local-") &&
        !tenantBMembership.organizationId.startsWith("org-local-"),
      flow_01_create_status_ok: flow.status === 201 && Boolean(flow.created),
      sec_01_cross_tenant_read_blocked: tenantBRead.count === 0,
      sec_01_cross_tenant_insert_blocked:
        tenantBCrossInsert.status === 403 || tenantBCrossInsert.status === 401,
      exposed_password_invalidated: await oldPasswordInvalidated(env.emailA),
    },
  };

  if (mode === "verify") {
    const failures = [];
    if (!output.checks.auth_02_same_user_after_resume) failures.push("AUTH-02 resume check failed");
    if (!output.checks.org_ids_not_fallback_local) failures.push("Fallback org-local tenant IDs detected");
    if (!output.checks.flow_01_create_status_ok) failures.push("FLOW-01 inspection creation failed");
    if (!output.checks.sec_01_cross_tenant_read_blocked) failures.push("SEC-01 cross-tenant read not blocked");
    if (!output.checks.sec_01_cross_tenant_insert_blocked) failures.push("SEC-01 cross-tenant insert not blocked");
    if (output.checks.exposed_password_invalidated === false) {
      failures.push("Exposed password still authenticates; rotate credential before closure");
    }

    console.log(JSON.stringify(output, null, 2));
    if (failures.length > 0) {
      console.error(`\nVerification failed:\n- ${failures.join("\n- ")}`);
      process.exit(1);
    }
    process.exit(0);
  }

  console.log(JSON.stringify(output, null, 2));
}

run().catch((error) => {
  console.error(`Phase 17 live runner failed: ${error.message}`);
  process.exit(1);
});
