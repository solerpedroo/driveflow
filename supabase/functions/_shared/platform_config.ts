export type PlatformId = "uber" | "99" | "indrive";

export type PlatformDefinition = {
  id: PlatformId;
  clientIdEnv: string;
  clientSecretEnv: string;
  authorizeUrl: string;
  tokenUrl: string;
  scopes: string[];
  apiBaseUrl?: string;
};

export function getPlatformDefinition(
  platform: string,
): PlatformDefinition | null {
  switch (platform) {
    case "uber":
      return {
        id: "uber",
        clientIdEnv: "UBER_CLIENT_ID",
        clientSecretEnv: "UBER_CLIENT_SECRET",
        authorizeUrl: "https://auth.uber.com/oauth/v2/authorize",
        tokenUrl: "https://auth.uber.com/oauth/v2/token",
        scopes: ["partner.accounts", "partner.trips", "partner.payments"],
        apiBaseUrl: "https://api.uber.com",
      };
    case "99": {
      const authorizeUrl = Deno.env.get("NINETY_NINE_AUTHORIZE_URL") ?? "";
      const tokenUrl = Deno.env.get("NINETY_NINE_TOKEN_URL") ?? "";
      if (!authorizeUrl || !tokenUrl) return null;
      return {
        id: "99",
        clientIdEnv: "NINETY_NINE_CLIENT_ID",
        clientSecretEnv: "NINETY_NINE_CLIENT_SECRET",
        authorizeUrl,
        tokenUrl,
        scopes: (Deno.env.get("NINETY_NINE_SCOPES") ?? "trips earnings")
          .split(" ")
          .filter(Boolean),
        apiBaseUrl: Deno.env.get("NINETY_NINE_API_BASE_URL") ?? "",
      };
    }
    case "indrive": {
      const authorizeUrl = Deno.env.get("INDRIVE_AUTHORIZE_URL") ?? "";
      const tokenUrl = Deno.env.get("INDRIVE_TOKEN_URL") ?? "";
      if (!authorizeUrl || !tokenUrl) return null;
      return {
        id: "indrive",
        clientIdEnv: "INDRIVE_CLIENT_ID",
        clientSecretEnv: "INDRIVE_CLIENT_SECRET",
        authorizeUrl,
        tokenUrl,
        scopes: (Deno.env.get("INDRIVE_SCOPES") ?? "trips").split(" ")
          .filter(Boolean),
        apiBaseUrl: Deno.env.get("INDRIVE_API_BASE_URL") ?? "",
      };
    }
    default:
      return null;
  }
}

export function getClientCredentials(
  def: PlatformDefinition,
): { clientId: string; clientSecret: string } | null {
  const clientId = Deno.env.get(def.clientIdEnv)?.trim();
  const clientSecret = Deno.env.get(def.clientSecretEnv)?.trim();
  if (!clientId || !clientSecret) return null;
  return { clientId, clientSecret };
}

export function platformNotConfiguredMessage(platform: string): string {
  switch (platform) {
    case "uber":
      return "Configure UBER_CLIENT_ID e UBER_CLIENT_SECRET nos secrets do Supabase.";
    case "99":
      return "Integração 99 indisponível: credenciais de parceiro e URLs OAuth não configuradas no servidor.";
    case "indrive":
      return "Integração InDrive indisponível: credenciais de parceiro e URLs OAuth não configuradas no servidor.";
    default:
      return "Plataforma não configurada no servidor.";
  }
}

export function oauthCallbackUri(): string {
  const base = Deno.env.get("SUPABASE_URL") ?? "";
  return `${base}/functions/v1/platform-oauth-callback`;
}
