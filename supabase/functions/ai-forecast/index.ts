import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const allowedOrigin = Deno.env.get("ALLOWED_ORIGIN") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": allowedOrigin || "null",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
const DEFAULT_MODEL = "llama-3.3-70b-versatile";
const FALLBACK_MODEL = Deno.env.get("GROQ_FALLBACK_MODEL") ??
  "llama-3.1-8b-instant";
const RATE_LIMIT_PER_HOUR = 10;
const CONTEXT_DAYS = 90;

type GroqMessage = { role: "system" | "user" | "assistant"; content: string };

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function clientError(message: string, status = 500) {
  return jsonResponse({ error: message }, status);
}

function logServerError(context: string, error: unknown) {
  const detail = error instanceof Error ? error.message : String(error);
  console.error(`[ai-forecast] ${context}:`, detail);
}

function formatBrl(value: number) {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(value);
}

function dailyProfitSeries(
  earnings: Array<{ amount?: number; date?: string }>,
  expenses: Array<{ amount?: number; date?: string }>,
) {
  const byDay = new Map<string, number>();

  for (const row of earnings) {
    const day = (row.date ?? "").slice(0, 10);
    if (!day) continue;
    byDay.set(day, (byDay.get(day) ?? 0) + Number(row.amount ?? 0));
  }
  for (const row of expenses) {
    const day = (row.date ?? "").slice(0, 10);
    if (!day) continue;
    byDay.set(day, (byDay.get(day) ?? 0) - Number(row.amount ?? 0));
  }

  return [...byDay.entries()]
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([day, profit]) => ({ day, profit }));
}

async function callGroq(messages: GroqMessage[], apiKey: string, model: string) {
  const response = await fetch(GROQ_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.3,
      max_tokens: 900,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Groq error (${response.status}): ${errorText}`);
  }

  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;
  if (!content || typeof content !== "string") {
    throw new Error("Resposta inválida da Groq");
  }
  return content.trim();
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return clientError("Método não permitido", 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return clientError("Não autorizado", 401);
    }

    const groqKey = Deno.env.get("GROQ_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!groqKey || !supabaseUrl || !serviceRoleKey || !anonKey) {
      return clientError("Previsão indisponível no momento.", 500);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return clientError("Sessão inválida", 401);
    }

    const userId = authData.user.id;

    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .select("ai_data_consent_at")
      .eq("id", userId)
      .maybeSingle();

    if (profileError || !profile?.ai_data_consent_at) {
      return clientError(
        "Consentimento para processamento de dados de IA necessário.",
        403,
      );
    }

    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count: recentCount, error: rateError } = await adminClient
      .from("ai_history")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("type", "forecast")
      .gte("created_at", oneHourAgo);

    if (rateError) {
      logServerError("rate limit check", rateError);
      return clientError("Previsão indisponível no momento.", 500);
    }
    if ((recentCount ?? 0) >= RATE_LIMIT_PER_HOUR) {
      return clientError(
        "Limite de previsões atingido. Tente novamente em breve.",
        429,
      );
    }

    const since = new Date(Date.now() - CONTEXT_DAYS * 24 * 60 * 60 * 1000)
      .toISOString();

    const [earningsRes, expensesRes, goalsRes] = await Promise.all([
      adminClient
        .from("earnings")
        .select("amount, date")
        .eq("user_id", userId)
        .gte("date", since),
      adminClient
        .from("expenses")
        .select("amount, date")
        .eq("user_id", userId)
        .gte("date", since),
      adminClient
        .from("goals")
        .select("daily, weekly, monthly, yearly")
        .eq("user_id", userId)
        .maybeSingle(),
    ]);

    if (earningsRes.error || expensesRes.error || goalsRes.error) {
      logServerError(
        "context fetch",
        earningsRes.error ?? expensesRes.error ?? goalsRes.error,
      );
      return clientError("Previsão indisponível no momento.", 500);
    }

    const series = dailyProfitSeries(
      earningsRes.data ?? [],
      expensesRes.data ?? [],
    );
    const profits = series.map((item) => item.profit);
    const avg = profits.length
      ? profits.reduce((sum, value) => sum + value, 0) / profits.length
      : 0;

    const forecast7 = avg * 7;
    const forecast30 = avg * 30;
    const optimistic30 = forecast30 * 1.15;
    const pessimistic30 = forecast30 * 0.85;
    const goals = goalsRes.data ?? {};

    const prompt = [
      "Com base na série de lucro diário dos últimos 90 dias, explique em português",
      "a projeção para 7 e 30 dias, cenários otimista e pessimista, e relação com metas.",
      `Média diária: ${formatBrl(avg)}`,
      `Projeção 7d: ${formatBrl(forecast7)}`,
      `Projeção 30d: ${formatBrl(forecast30)}`,
      `Otimista 30d: ${formatBrl(optimistic30)}`,
      `Pessimista 30d: ${formatBrl(pessimistic30)}`,
      `Metas: diária ${formatBrl(Number(goals.daily ?? 0))}, mensal ${formatBrl(Number(goals.monthly ?? 0))}`,
      `Pontos na série: ${series.length}`,
    ].join("\n");

    const messages: GroqMessage[] = [
      {
        role: "system",
        content:
          "Você é o assistente financeiro do DriveFlow. Responda em português brasileiro, objetivo, sem inventar números.",
      },
      { role: "user", content: prompt },
    ];

    let summary: string;
    try {
      summary = await callGroq(messages, groqKey, DEFAULT_MODEL);
    } catch (primaryError) {
      logServerError("groq primary model", primaryError);
      summary = await callGroq(messages, groqKey, FALLBACK_MODEL);
    }

    const question = "Previsão de lucro — 7 e 30 dias";
    const { data: saved, error: saveError } = await adminClient
      .from("ai_history")
      .insert({
        user_id: userId,
        question,
        answer: summary,
        type: "forecast",
      })
      .select("id, question, answer, created_at")
      .single();

    if (saveError || !saved) {
      logServerError("save history", saveError);
      return clientError("Previsão indisponível no momento.", 500);
    }

    return jsonResponse({
      id: saved.id,
      summary: saved.answer,
      forecast7Days: forecast7,
      forecast30Days: forecast30,
      optimistic30Days: optimistic30,
      pessimistic30Days: pessimistic30,
      createdAt: saved.created_at,
    });
  } catch (error) {
    logServerError("unhandled", error);
    return clientError("Previsão indisponível no momento.", 500);
  }
});
