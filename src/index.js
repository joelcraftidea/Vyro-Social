
const SESSION_DAYS = 30;
const PASSWORD_ITERATIONS = 310000;

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization"
    }
  });
}

function base64(bytes) {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function fromBase64(value) {
  return Uint8Array.from(atob(value), c => c.charCodeAt(0));
}

function randomToken() {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return base64(bytes).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

async function sha256(value) {
  const result = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value)
  );
  return base64(new Uint8Array(result));
}

async function hashPassword(password) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(password),
    "PBKDF2",
    false,
    ["deriveBits"]
  );

  const bits = await crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      salt,
      iterations: PASSWORD_ITERATIONS,
      hash: "SHA-256"
    },
    key,
    256
  );

  return `pbkdf2$${PASSWORD_ITERATIONS}$${base64(salt)}$${base64(new Uint8Array(bits))}`;
}

async function verifyPassword(password, stored) {
  try {
    const parts = stored.split("$");
    if (parts.length !== 4 || parts[0] !== "pbkdf2") return false;

    const iterations = Number(parts[1]);
    if (!Number.isInteger(iterations) || iterations < 100000 || iterations > 1000000) {
      return false;
    }

    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(password),
      "PBKDF2",
      false,
      ["deriveBits"]
    );

    const bits = await crypto.subtle.deriveBits(
      {
        name: "PBKDF2",
        salt: fromBase64(parts[2]),
        iterations,
        hash: "SHA-256"
      },
      key,
      256
    );

    const actual = new Uint8Array(bits);
    const expected = fromBase64(parts[3]);

    if (actual.length !== expected.length) return false;

    let difference = 0;
    for (let i = 0; i < actual.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    return difference === 0;
  } catch {
    return false;
  }
}

function publicUser(user) {
  return {
    id: user.id,
    username: user.username,
    display_name: user.display_name,
    email: user.email,
    phone: user.phone,
    account_type: user.account_type,
    bio: user.bio,
    avatar_url: user.avatar_url,
    email_verified: user.email_verified,
    phone_verified: user.phone_verified,
    created_at: user.created_at
  };
}

async function createSession(db, userId) {
  const token = randomToken();
  const tokenHash = await sha256(token);
  const sessionId = crypto.randomUUID();
  const expiresAt = new Date(
    Date.now() + SESSION_DAYS * 24 * 60 * 60 * 1000
  ).toISOString();

  await db.prepare(
    `INSERT INTO sessions
     (id, user_id, token_hash, expires_at)
     VALUES (?, ?, ?, ?)`
  ).bind(sessionId, userId, tokenHash, expiresAt).run();

  return { token, expiresAt };
}

async function authenticate(request, db) {
  const header = request.headers.get("Authorization") || "";
  if (!header.startsWith("Bearer ")) return null;

  const token = header.slice(7).trim();
  if (!token || token.length > 200) return null;

  const tokenHash = await sha256(token);
  const now = new Date().toISOString();

  const session = await db.prepare(
    `SELECT sessions.id AS session_id,
            users.*
     FROM sessions
     JOIN users ON users.id = sessions.user_id
     WHERE sessions.token_hash = ?
       AND sessions.expires_at > ?
     LIMIT 1`
  ).bind(tokenHash, now).first();

  return session || null;
}

export default {
  async fetch(request, env) {
    try {
      if (request.method === "OPTIONS") {
        return new Response(null, {
          status: 204,
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization"
          }
        });
      }

      const url = new URL(request.url);
      const path = url.pathname.replace(/\/+$/, "") || "/";
      const db = env.DB;

      if (!db) return json({ error: "Database unavailable" }, 500);

      // Health check
      if (request.method === "GET" && path === "/health") {
        const result = await db.prepare(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
        ).all();

        return json({
          status: "success",
          service: "VYRO",
          database: "connected",
          tables: result.results.map(row => row.name)
        });
      }

      // Register a new account
      if (request.method === "POST" && path === "/auth/register") {
        const body = await request.json();

        const username = String(body.username || "").trim().toLowerCase();
        const displayName = String(body.display_name || "").trim();
        const email = String(body.email || "").trim().toLowerCase() || null;
        const phone = String(body.phone || "").trim() || null;
        const password = String(body.password || "");
        const accountType = String(body.account_type || "personal");

        if (!/^[a-z0-9_]{3,30}$/.test(username)) {
          return json({ error: "Username must be 3–30 characters and use letters, numbers, or underscores." }, 400);
        }

        if (!email && !phone) {
          return json({ error: "Provide an email address or phone number." }, 400);
        }

        if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
          return json({ error: "Enter a valid email address." }, 400);
        }

        if (phone && !/^\+?[0-9]{7,15}$/.test(phone)) {
          return json({ error: "Enter a valid phone number with country code." }, 400);
        }

        if (password.length < 12 || password.length > 128) {
          return json({ error: "Password must be at least 12 characters." }, 400);
        }

        if (!["personal", "business", "government"].includes(accountType)) {
          return json({ error: "Invalid account type." }, 400);
        }

        const passwordHash = await hashPassword(password);
        const userId = crypto.randomUUID();

        try {
          await db.prepare(
            `INSERT INTO users
             (id, username, display_name, email, phone, account_type,
              password_hash, email_verified, phone_verified)
             VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0)`
          ).bind(
            userId,
            username,
            displayName || username,
            email,
            phone,
            accountType,
            passwordHash
          ).run();
        } catch (error) {
          const message = String(error.message || "").toLowerCase();
          if (message.includes("unique") || message.includes("constraint")) {
            return json({ error: "That username, email, or phone number is already registered." }, 409);
          }
          throw error;
        }

        const user = await db.prepare(
          "SELECT * FROM users WHERE id = ?"
        ).bind(userId).first();

        const session = await createSession(db, userId);

        return json({
          message: "Account created. Contact verification is still required.",
          user: publicUser(user),
          token: session.token,
          expires_at: session.expiresAt
        }, 201);
      }

      // Login with username, email, or phone
      if (request.method === "POST" && path === "/auth/login") {
        const body = await request.json();
        const identifier = String(body.identifier || "").trim().toLowerCase();
        const password = String(body.password || "");

        if (!identifier || !password) {
          return json({ error: "Enter your username, email, or phone and password." }, 400);
        }

        const user = await db.prepare(
          `SELECT * FROM users
           WHERE lower(username) = ?
              OR lower(email) = ?
              OR phone = ?
           LIMIT 1`
        ).bind(identifier, identifier, identifier).first();

        if (!user || !user.password_hash ||
            !(await verifyPassword(password, user.password_hash))) {
          return json({ error: "Invalid login details." }, 401);
        }

        const session = await createSession(db, user.id);

        return json({
          message: "Login successful.",
          user: publicUser(user),
          token: session.token,
          expires_at: session.expiresAt
        });
      }

      // Check the current logged-in user
      if (request.method === "GET" && path === "/auth/me") {
        const user = await authenticate(request, db);
        if (!user) return json({ error: "Invalid or expired session." }, 401);

        return json({ user: publicUser(user) });
      }

      // Log out and revoke the current session
      if (request.method === "POST" && path === "/auth/logout") {
        const header = request.headers.get("Authorization") || "";
        if (!header.startsWith("Bearer ")) {
          return json({ error: "Missing login token." }, 401);
        }

        const token = header.slice(7).trim();
        const tokenHash = await sha256(token);

        await db.prepare(
          "DELETE FROM sessions WHERE token_hash = ?"
        ).bind(tokenHash).run();

        return json({ message: "Logged out successfully." });
      }

      return json({ error: "Route not found." }, 404);

    } catch (error) {
      return json({
        error: "The server could not complete the request."
      }, 500);
    }
  }
};
