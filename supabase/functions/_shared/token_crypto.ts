type EncryptedPayload = {
  v: 1;
  iv: string;
  data: string;
};

function isEncryptedPayload(value: unknown): value is EncryptedPayload {
  return typeof value === "object" &&
    value !== null &&
    (value as EncryptedPayload).v === 1 &&
    typeof (value as EncryptedPayload).iv === "string" &&
    typeof (value as EncryptedPayload).data === "string";
}

function hasPlainAccessToken(value: unknown): boolean {
  return typeof value === "object" &&
    value !== null &&
    typeof (value as { access_token?: string }).access_token === "string";
}

async function importEncryptionKey(): Promise<CryptoKey> {
  const raw = Deno.env.get("PLATFORM_TOKEN_ENCRYPTION_KEY")?.trim();
  if (!raw) {
    throw new Error("PLATFORM_TOKEN_ENCRYPTION_KEY não configurada.");
  }

  let keyBytes: Uint8Array;
  try {
    keyBytes = Uint8Array.from(atob(raw), (char) => char.charCodeAt(0));
  } catch {
    keyBytes = new TextEncoder().encode(raw);
  }

  if (keyBytes.length !== 32) {
    throw new Error(
      "PLATFORM_TOKEN_ENCRYPTION_KEY deve ter 32 bytes (base64 ou raw).",
    );
  }

  return crypto.subtle.importKey(
    "raw",
    keyBytes,
    { name: "AES-GCM" },
    false,
    ["encrypt", "decrypt"],
  );
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary);
}

function base64ToBytes(value: string): Uint8Array {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}

export async function encryptOAuthPayload<T>(payload: T): Promise<EncryptedPayload> {
  const key = await importEncryptionKey();
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encoded = new TextEncoder().encode(JSON.stringify(payload));
  const cipher = await crypto.subtle.encrypt({ name: "AES-GCM", iv }, key, encoded);

  return {
    v: 1,
    iv: bytesToBase64(iv),
    data: bytesToBase64(new Uint8Array(cipher)),
  };
}

export async function decryptOAuthPayload<T>(stored: unknown): Promise<T | undefined> {
  if (stored == null) return undefined;

  if (hasPlainAccessToken(stored)) {
    return stored as T;
  }

  if (!isEncryptedPayload(stored)) return undefined;

  const key = await importEncryptionKey();
  const iv = base64ToBytes(stored.iv);
  const cipher = base64ToBytes(stored.data);
  const plain = await crypto.subtle.decrypt({ name: "AES-GCM", iv }, key, cipher);
  return JSON.parse(new TextDecoder().decode(plain)) as T;
}

export function shouldEncryptOAuth(): boolean {
  return Boolean(Deno.env.get("PLATFORM_TOKEN_ENCRYPTION_KEY")?.trim());
}
