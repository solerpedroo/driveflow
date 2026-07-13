<div align="center">

<h1>
  <span style="color:#0064F5">Drive</span><span style="color:#34C759">Flow</span>
</h1>

<p>
  <strong>O cockpit financeiro do motorista de aplicativo.</strong><br/>
  Ganhos, despesas, turno, integrações e IA — em um só lugar, offline-first.
</p>

<p>
  <img src="https://img.shields.io/badge/Flutter-0064F5?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Supabase-34C759?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/Riverpod-0A192F?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Onda_53-0064F5?style=flat-square" alt="Onda 53"/>
</p>

</div>

---

## A história

Você passa horas na rua. O dinheiro entra em três apps diferentes. O combustível sai do bolso. A manutenção vence sem aviso. No fim do dia, a pergunta é sempre a mesma: **valeu a pena?**

A maioria dos motoristas responde no feeling — ou numa planilha que ninguém mantém.

**DriveFlow nasce para fechar esse ciclo.** Não é só um app de gastos. É o painel de controle da sua operação: quanto você faturou, quanto sobrou de verdade, em qual app rende mais, qual horário compensa, e o que fazer no próximo turno.

> Do primeiro ganho registrado ao PDF da retrospectiva — cada corrida vira dado. Cada dado vira decisão.

---

## O que o DriveFlow faz por você

<table>
<tr>
<td width="33%" valign="top">

<h3 style="color:#0064F5">Caixa real</h3>

<p>
Registre ganhos e despesas por veículo. Veja lucro bruto e <strong>líquido</strong> — descontando combustível, pedágio, lavagem e tudo mais que come sua margem.
</p>

<p>
<strong>Dashboard</strong> · <strong>Relatórios PDF/CSV</strong> · <strong>OCR de comprovantes</strong>
</p>

</td>
<td width="33%" valign="top">

<h3 style="color:#34C759">Turno inteligente</h3>

<p>
Inicie um turno com plano adaptativo (heatmap + seu histórico). Acompanhe aderência, caixa líquido ao vivo, Live Activity e retrospectiva com insight de coaching.
</p>

<p>
<strong>Modo turno</strong> · <strong>Analytics 7d/30d</strong> · <strong>Widget iOS</strong>
</p>

</td>
<td width="33%" valign="top">

<h3 style="color:#5AC8FA">Multi-app + IA</h3>

<p>
Conecte Uber, 99 e InDrive. Sincronize corridas, compare take rate, simule mix de plataformas e pergunte ao assistente com contexto dos seus últimos 90 dias.
</p>

<p>
<strong>Cockpit</strong> · <strong>Repasses</strong> · <strong>Assistente Groq</strong>
</p>

</td>
</tr>
</table>

---

## Jornada do motorista

```
  Registrar          Entender            Operar              Decidir
  ─────────          ────────            ──────              ───────
  Ganhos             Dashboard           Modo turno          Plano adaptativo
  Despesas      →    Analytics      →    Live Activity  →   Coaching + IA
  Abastecimento      Insights            Caixa líquido       PDF retrospectiva
  Manutenção         Comparativos        Atalhos rápidos     Metas por app
```

Cada etapa alimenta a próxima. Quanto mais você usa, mais preciso fica o conselho — sem depender de planilha externa.

---

## Destaques do produto

| Área | O que você ganha |
|------|------------------|
| <span style="color:#0064F5">**Financeiro**</span> | Ganhos, despesas, combustível, manutenção, metas e múltiplos veículos com escopo por carro |
| <span style="color:#34C759">**Turno**</span> | Sessão com timer, pausas, aderência ao plano, histórico, retrospectiva e exportação PDF |
| <span style="color:#5AC8FA">**Integrações**</span> | OAuth Uber/99/InDrive, sync de corridas, rollup automático e cockpit multi-app |
| <span style="color:#FF9500">**Inteligência**</span> | Heatmap 7×24, simulador de mix, previsão IA, OCR on-device e chat contextual |
| <span style="color:#FF3B30">**Operação**</span> | Offline-first com Hive, fila de sync, notificações de manutenção e deep links `driveflow://` |
| <span style="color:#B8D4FF">**Experiência**</span> | Design System v2, UI Apple Premium, liquid glass nav, acessibilidade e modo taxista |

---

## Stack

<table>
<tr>
<td align="center" width="20%">

**Frontend**  
Flutter 3.11+  
Riverpod · GoRouter  
Hooks · fl_chart

</td>
<td align="center" width="20%">

**Backend**  
Supabase  
Postgres + RLS  
Edge Functions

</td>
<td align="center" width="20%">

**Offline**  
Hive  
SyncWorker  
Retry exponencial

</td>
<td align="center" width="20%">

**IA**  
Groq (Edge)  
Contexto 90 dias  
Rate limit server-side

</td>
<td align="center" width="20%">

**Nativo**  
WidgetKit  
Live Activities  
Quick Actions iOS/Android

</td>
</tr>
</table>

---

## Começar em 4 passos

### 1. Dependências

```bash
git clone https://github.com/solerpedroo/driveflow.git
cd driveflow
flutter pub get
```

### 2. Ambiente

```bash
cp env.example.json env.json
```

Edite `env.json` com suas credenciais Supabase:

```json
{
  "SUPABASE_URL": "http://127.0.0.1:54321",
  "SUPABASE_ANON_KEY": "sua-anon-key"
}
```

> **Android emulador:** use `http://10.0.2.2:54321` como URL.

### 3. Supabase local (opcional)

```bash
supabase start
supabase db reset
```

Copie a `anon key` exibida no terminal para `env.json`.

### 4. Rodar

```bash
flutter run --dart-define-from-file=env.json
```

### IA (produção)

```bash
supabase secrets set GROQ_API_KEY=sua_chave_groq
supabase functions deploy ai-chat
supabase functions deploy ai-forecast
```

---

## Arquitetura

Clean Architecture feature-first — cada módulo com `presentation`, `domain` e `data`.

```
lib/
├── core/              # theme, router, constants, services, utils
├── features/          # authentication, dashboard, earnings, expenses,
│   └── <feature>/     # vehicle, shift, integrations, ai, reports...
│       ├── presentation/
│       ├── domain/
│       └── data/
└── shared/            # widgets cross-feature, deep links, bootstrap
```

**Padrões:** schema + mapper explícitos, injeção para testes, streams Supabase com cache Hive, guards no GoRouter.

<details>
<summary><strong>Estrutura interna de uma feature</strong></summary>

```
features/<feature>/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── data/
    ├── datasources/
    ├── mappers/
    ├── schema/
    └── repositories/
```

</details>

---

## Scripts úteis

```bash
flutter analyze
flutter test
flutter test --coverage
dart run build_runner build --delete-conflicting-outputs
```

Meta de cobertura: **≥ 70%** em `lib/features/*/domain` e `lib/features/*/data`.

---

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [implementation-plan.md](implementation-plan.md) | Roadmap completo em 53+ ondas, critérios de conclusão e mapa de RFs |
| [docs/SUPABASE_ER.md](docs/SUPABASE_ER.md) | Modelo de dados e relacionamentos |
| [docs/RELEASE.md](docs/RELEASE.md) | Checklist de release e deploy |
| [docs/INTEGRACOES-PLATAFORMAS.md](docs/INTEGRACOES-PLATAFORMAS.md) | OAuth e sync Uber/99/InDrive |
| [docs/engineering-audit.md](docs/engineering-audit.md) | Auditoria técnica e débitos |

---

## Roadmap

O DriveFlow evolui em **ondas** — entregas incrementais com demo funcional e testes antes de avançar.

| Fase | Ondas | Escopo |
|------|-------|--------|
| **MVP v1.0** | 0–9 | Auth, CRUD, dashboard, relatórios, IA, offline-first |
| **Pós-MVP** | 10–14 | Múltiplos veículos, OCR, analytics, insights, importação |
| **Premium UI** | 15–23 | Design System v2, glass, haptics, polish outlier |
| **Integrações** | 24–33 | Uber/99/InDrive, cockpit, heatmap, caixa, Pro analytics |
| **Turno completo** | 45–53 | Histórico, widget, Live Activity, coaching, automação, caixa líquido |

Consulte [implementation-plan.md](implementation-plan.md) para o detalhamento de cada onda.

---

## Variáveis de ambiente

```env
# Flutter (--dart-define-from-file)
SUPABASE_URL=
SUPABASE_ANON_KEY=

# Supabase Edge Functions (secrets)
GROQ_API_KEY=
GROQ_MODEL=llama-3.3-70b-versatile

# Integrações (Onda 26+)
UBER_CLIENT_ID=
UBER_CLIENT_SECRET=
NINETY_NINE_CLIENT_ID=
NINETY_NINE_CLIENT_SECRET=
INDRIVE_CLIENT_ID=
INDRIVE_CLIENT_SECRET=
PLATFORM_OAUTH_REDIRECT_URL=
```

---

<div align="center">

<p>
  <span style="color:#0064F5">DriveFlow</span> — transforme quilômetros em clareza financeira.
</p>

<p>
  <sub>Projeto privado · todos os direitos reservados</sub>
</p>

</div>
