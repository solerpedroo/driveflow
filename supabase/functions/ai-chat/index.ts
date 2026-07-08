import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";
const DEFAULT_MODEL = "llama-3.3-70b-versatile";
const FALLBACK_MODEL = Deno.env.get("GROQ_FALLBACK_MODEL") ??
  "llama-3.1-8b-instant";
const RATE_LIMIT_PER_HOUR = 30;
const CONTEXT_DAYS = 90;

type GroqMessage = { role: "system" | "user" | "assistant"; content: string };

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function formatBrl(value: number) {
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(value);
}

function sumAmount(rows: Array<{ amount?: number; cost?: number }>, key: "amount" | "cost") {
  return rows.reduce((sum, row) => sum + Number(row[key] ?? 0), 0);
}

function buildContextPrompt(data: {
  earnings: Array<Record<string, unknown>>;
  expenses: Array<Record<string, unknown>>;
  goals: Record<string, unknown> | null;
  fuelLogs: Array<Record<string, unknown>>;
  maintenance: Array<Record<string, unknown>>;
}) {
  const earningsTotal = sumAmount(data.earnings as Array<{ amount: number }>, "amount");
  const expensesTotal = sumAmount(data.expenses as Array<{ amount: number }>, "amount");
  const profit = earningsTotal - expensesTotal;
  const fuelTotal = (data.fuelLogs as Array<{ total_amount?: number }>).reduce(
    (sum, row) => sum + Number(row.total_amount ?? 0),
    0,
  );
  const rides = (data.earnings as Array<{ rides?: number }>).reduce(
    (sum, row) => sum + Number(row.rides ?? 0),
    0,
  );
  const workedHours = (data.earnings as Array<{ worked_hours?: number }>).reduce(
    (sum, row) => sum + Number(row.worked_hours ?? 0),
    0,
  );

  const goals = data.goals ?? {};
  const maintenancePending = (data.maintenance as Array<Record<string, unknown>>)
    .filter((row) => row.next_due_date || row.next_due_km)
    .slice(0, 5);

  return [
    "Contexto financeiro do motorista (últimos 90 dias):",
    `- Receita total: ${formatBrl(earningsTotal)}`,
    `- Despesas total: ${formatBrl(expensesTotal)}`,
    `- Lucro estimado: ${formatBrl(profit)}`,
    `- Corridas registradas: ${rides}`,
    `- Horas trabalhadas: ${workedHours.toFixed(1)}h`,
    `- Gasto em abastecimentos (fuel_logs): ${formatBrl(fuelTotal)}`,
    `- Metas (BRL): diária ${formatBrl(Number(goals.daily ?? 0))}, semanal ${formatBrl(Number(goals.weekly ?? 0))}, mensal ${formatBrl(Number(goals.monthly ?? 0))}, anual ${formatBrl(Number(goals.yearly ?? 0))}`,
    `- Manutenções com lembrete: ${maintenancePending.length}`,
    `- Registros: ${data.earnings.length} ganhos, ${data.expenses.length} despesas, ${data.fuelLogs.length} abastecimentos`,
  ].join("\n");
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
      temperature: 0.4,
      max_tokens: 1024,
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
    return jsonResponse({ error: "Método não permitido" }, 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Não autorizado" }, 401);
    }

    const groqKey = Deno.env.get("GROQ_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!groqKey || !supabaseUrl || !serviceRoleKey || !anonKey) {
      return jsonResponse({ error: "Configuração do servidor incompleta" }, 500);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return jsonResponse({ error: "Sessão inválida" }, 401);
    }

    const userId = authData.user.id;
    const body = await req.json();
    const question = typeof body?.question === "string" ? body.question.trim() : "";

    if (!question || question.length < 3) {
      return jsonResponse({ error: "Pergunta inválida" }, 400);
    }
    if (question.length > 2000) {
      return jsonResponse({ error: "Pergunta muito longa" }, 400);
    }

    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count: recentCount, error: rateError } = await adminClient
      .from("ai_history")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", oneHourAgo);

    if (rateError) {
      return jsonResponse({ error: rateError.message }, 500);
    }
    if ((recentCount ?? 0) >= RATE_LIMIT_PER_HOUR) {
      return jsonResponse(
        { error: "Limite de perguntas atingido. Tente novamente em breve." },
        429,
      );
    }

    const since = new Date(Date.now() - CONTEXT_DAYS * 24 * 60 * 60 * 1000)
      .toISOString();

    const [earningsRes, expensesRes, goalsRes, fuelRes, maintenanceRes] =
      await Promise.all([
        adminClient
          .from("earnings")
          .select("amount, rides, worked_hours, date, platform")
          .eq("user_id", userId)
          .gte("date", since),
        adminClient
          .from("expenses")
          .select("amount, category, date, description")
          .eq("user_id", userId)
          .gte("date", since),
        adminClient
          .from("goals")
          .select("daily, weekly, monthly, yearly")
          .eq("user_id", userId)
          .maybeSingle(),
        adminClient
          .from("fuel_logs")
          .select("total_amount, liters, km_per_liter, cost_per_km, created_at")
          .eq("user_id", userId)
          .gte("created_at", since)
          .order("created_at", { ascending: false })
          .limit(20),
        adminClient
          .from("maintenance")
          .select("type, cost, service_date, next_due_date, next_due_km")
          .eq("user_id", userId)
          .order("service_date", { ascending: false })
          .limit(20),
      ]);

    if (earningsRes.error || expensesRes.error || goalsRes.error || fuelRes.error ||
      maintenanceRes.error) {
      const message = earningsRes.error?.message ??
        expensesRes.error?.message ??
        goalsRes.error?.message ??
        fuelRes.error?.message ??
        maintenanceRes.error?.message ??
        "Erro ao buscar contexto";
      return jsonResponse({ error: message }, 500);
    }

    const contextPrompt = buildContextPrompt({
      earnings: earningsRes.data ?? [],
      expenses: expensesRes.data ?? [],
      goals: goalsRes.data,
      fuelLogs: fuelRes.data ?? [],
      maintenance: maintenanceRes.data ?? [],
    });

    const systemPrompt = [
      "Você é o assistente financeiro do app DriveFlow para motoristas de aplicativo.",
      "Responda sempre em português brasileiro, de forma clara e objetiva.",
      "Use valores em BRL quando citar dinheiro.",
      "Baseie-se apenas no contexto fornecido; se faltar dado, diga o que falta.",
      "Não invente números. Seja prático e actionável.",
      "",
      contextPrompt,
    ].join("\n");

    const messages: GroqMessage[] = [
      { role: "system", content: systemPrompt },
      { role: "user", content: question },
    ];

    let answer: string;
    try {
      answer = await callGroq(messages, groqKey, DEFAULT_MODEL);
    } catch {
      answer = await callGroq(messages, groqKey, FALLBACK_MODEL);
    }

    const { data: saved, error: saveError } = await adminClient
      .from("ai_history")
      .insert({ user_id: userId, question, answer })
      .select("id, question, answer, created_at")
      .single();

    if (saveError || !saved) {
      return jsonResponse({ error: saveError?.message ?? "Erro ao salvar histórico" }, 500);
    }

    return jsonResponse({
      id: saved.id,
      question: saved.question,
      answer: saved.answer,
      createdAt: saved.created_at,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Erro interno";
    return jsonResponse({ error: message }, 500);
  }
});
