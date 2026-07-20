const DEFAULT_APP_REDIRECT_URIS = [
  "io.supabase.driveflow://platform-oauth/",
  "io.supabase.driveflow://platform-oauth",
];

export function allowedAppRedirectUris(): string[] {
  const env = Deno.env.get("PLATFORM_OAUTH_APP_REDIRECT_URIS");
  if (!env?.trim()) return DEFAULT_APP_REDIRECT_URIS;
  return env.split(",").map((value) => value.trim()).filter(Boolean);
}

export function validateAppRedirectUri(uri: string): boolean {
  if (!uri?.trim()) return false;
  const allowed = allowedAppRedirectUris();
  if (allowed.includes(uri)) return true;

  try {
    const parsed = new URL(uri);
    if (parsed.protocol !== "io.supabase.driveflow:") return false;
    if (parsed.hostname !== "platform-oauth") return false;
    return allowed.some((entry) => {
      try {
        return new URL(entry).toString() === parsed.toString();
      } catch {
        return entry === uri;
      }
    });
  } catch {
    return false;
  }
}

export function timingSafeEqual(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const left = encoder.encode(a);
  const right = encoder.encode(b);
  if (left.length !== right.length) return false;
  let diff = 0;
  for (let i = 0; i < left.length; i++) {
    diff |= left[i] ^ right[i];
  }
  return diff === 0;
}

function bytesToHex(bytes: Uint8Array): string {
  return [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export async function verifyWebhookHmac(
  rawBody: string,
  signatureHeader: string | null,
  secret: string,
): Promise<boolean> {
  if (!signatureHeader?.trim()) return false;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const mac = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(rawBody),
  );
  const expectedHex = bytesToHex(new Uint8Array(mac));

  const normalized = signatureHeader.trim().toLowerCase();
  const provided = normalized.startsWith("sha256=")
    ? normalized.slice(7)
    : normalized;

  return timingSafeEqual(provided, expectedHex);
}

export function opaqueOAuthErrorCode(
  error?: string | null,
  errorDescription?: string | null,
): string {
  const combined = `${error ?? ""} ${errorDescription ?? ""}`.toLowerCase();
  if (combined.includes("access_denied") || combined.includes("denied")) {
    return "access_denied";
  }
  if (combined.includes("expired")) return "expired";
  return "oauth_failed";
}
