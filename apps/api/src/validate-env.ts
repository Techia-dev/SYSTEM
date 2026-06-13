import "dotenv/config";

const requiredVars = [
  ["DATABASE_URL", "PostgreSQL connection string"],
  ["JWT_SECRET", "JWT signing secret (min 32 chars)"],
];

const warnings: string[] = [];

for (const [varName, description] of requiredVars) {
  const value = process.env[varName];
  if (!value) {
    console.error(`[ENV ERROR] Missing required environment variable: ${varName} (${description})`);
    process.exit(1);
  }
  if (varName === "JWT_SECRET" && value.length < 32) {
    console.error(`[ENV ERROR] ${varName} must be at least 32 characters long`);
    process.exit(1);
  }
}

if (process.env.CORS_ORIGINS) {
  const origins = process.env.CORS_ORIGINS.split(",").map((o) => o.trim()).filter(Boolean);
  for (const origin of origins) {
    if (!origin.startsWith("http://") && !origin.startsWith("https://")) {
      warnings.push(`CORS_ORIGINS entry "${origin}" is missing protocol (http:// or https://)`);
    }
  }
}

if (process.env.JWT_ACCESS_TOKEN_TTL) {
  const ttl = process.env.JWT_ACCESS_TOKEN_TTL;
  if (!/^\d+[smhd]$/.test(ttl)) {
    warnings.push(`JWT_ACCESS_TOKEN_TTL "${ttl}" looks invalid - expected format like "15m", "1h", "7d"`);
  }
}

for (const warning of warnings) {
  console.warn(`[ENV WARN] ${warning}`);
}

console.log("[ENV] All required environment variables are present");

if (warnings.length > 0) {
  console.log(`[ENV] ${warnings.length} warning(s) found (non-blocking)`);
}
