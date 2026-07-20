import {
  getClientCredentials,
  getPlatformDefinition,
  oauthCallbackUri,
  type PlatformDefinition,
} from "./platform_config.ts";

export type StoredOAuthTokens = {
  access_token: string;
  refresh_token?: string;
  expires_at: string;
  token_type?: string;
  scope?: string;
};

type TokenResponse = {
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
  token_type?: string;
  scope?: string;
  error?: string;
  error_description?: string;
};

function expiresAtFromSeconds(seconds?: number): string {
  const ttl = typeof seconds === "number" && seconds > 0 ? seconds : 3600;
  return new Date(Date.now() + ttl * 1000).toISOString();
}

export function isTokenExpired(
  expiresAt: string,
  bufferMs = 5 * 60 * 1000,
): boolean {
  const expires = new Date(expiresAt).getTime();
  if (Number.isNaN(expires)) return true;
  return expires <= Date.now() + bufferMs;
}

async function requestTokens(
  def: PlatformDefinition,
  body: Record<string, string>,
): Promise<StoredOAuthTokens> {
  const credentials = getClientCredentials(def);
  if (!credentials) {
    throw new Error(`Credenciais OAuth ausentes para ${def.id}.`);
  }

  const form = new URLSearchParams({
    client_id: credentials.clientId,
    client_secret: credentials.clientSecret,
    ...body,
  });

  const response = await fetch(def.tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: form.toString(),
  });

  const payload = await response.json() as TokenResponse;
  if (!response.ok || !payload.access_token) {
    const detail = payload.error_description ?? payload.error ??
      `HTTP ${response.status}`;
    throw new Error(`Falha ao obter token (${def.id}): ${detail}`);
  }

  return {
    access_token: payload.access_token,
    refresh_token: payload.refresh_token,
    expires_at: expiresAtFromSeconds(payload.expires_in),
    token_type: payload.token_type,
    scope: payload.scope,
  };
}

export async function exchangeAuthorizationCode(
  platform: string,
  code: string,
  codeVerifier?: string,
): Promise<StoredOAuthTokens> {
  const def = getPlatformDefinition(platform);
  if (!def) {
    throw new Error(`Plataforma OAuth não configurada: ${platform}`);
  }

  const body: Record<string, string> = {
    grant_type: "authorization_code",
    code,
    redirect_uri: oauthCallbackUri(),
  };
  if (codeVerifier) {
    body.code_verifier = codeVerifier;
  }

  return requestTokens(def, body);
}

export async function refreshAccessToken(
  platform: string,
  refreshToken: string,
): Promise<StoredOAuthTokens> {
  const def = getPlatformDefinition(platform);
  if (!def) {
    throw new Error(`Plataforma OAuth não configurada: ${platform}`);
  }

  return requestTokens(def, {
    grant_type: "refresh_token",
    refresh_token: refreshToken,
  });
}
