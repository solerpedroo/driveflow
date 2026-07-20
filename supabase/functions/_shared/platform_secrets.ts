import type { SupabaseClient } from "jsr:@supabase/supabase-js@2";
import type { StoredOAuthTokens } from "./platform_oauth.ts";
import {
  decryptOAuthPayload,
  encryptOAuthPayload,
  shouldEncryptOAuth,
} from "./token_crypto.ts";

type ConnectionRow = {
  id: string;
  metadata: Record<string, unknown> | null;
};

export async function loadConnectionOAuth(
  supabase: SupabaseClient,
  connection: ConnectionRow & { user_id: string },
): Promise<StoredOAuthTokens | undefined> {
  const { data: secretRow } = await supabase
    .from("platform_connection_secrets")
    .select("oauth")
    .eq("connection_id", connection.id)
    .maybeSingle();

  const secretOAuth = await decryptOAuthPayload<StoredOAuthTokens>(
    secretRow?.oauth,
  );
  if (secretOAuth?.access_token) return secretOAuth;

  const legacyOAuth = connection.metadata?.oauth as StoredOAuthTokens | undefined;
  if (!legacyOAuth?.access_token) return undefined;

  const legacyStored = shouldEncryptOAuth()
    ? await encryptOAuthPayload(legacyOAuth)
    : legacyOAuth;

  await supabase.from("platform_connection_secrets").upsert({
    connection_id: connection.id,
    user_id: connection.user_id,
    oauth: legacyStored,
  }, { onConflict: "connection_id" });

  const metadata = { ...(connection.metadata ?? {}) };
  delete metadata.oauth;
  await supabase.from("platform_connections").update({ metadata }).eq(
    "id",
    connection.id,
  );

  return legacyOAuth;
}

export async function storeConnectionOAuth(
  supabase: SupabaseClient,
  params: {
    connectionId: string;
    userId: string;
    oauth: StoredOAuthTokens;
    metadata?: Record<string, unknown> | null;
  },
): Promise<Record<string, unknown>> {
  const storedOAuth = shouldEncryptOAuth()
    ? await encryptOAuthPayload(params.oauth)
    : params.oauth;

  await supabase.from("platform_connection_secrets").upsert({
    connection_id: params.connectionId,
    user_id: params.userId,
    oauth: storedOAuth,
  }, { onConflict: "connection_id" });

  const nextMetadata = { ...(params.metadata ?? {}) };
  delete nextMetadata.oauth;
  return nextMetadata;
}
