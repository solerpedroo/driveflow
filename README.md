<div align="center">

<h1>
  <span style="color:#0064F5">Drive</span><span style="color:#34C759">Flow</span>
</h1>

<p>
  <strong>The financial cockpit for rideshare drivers.</strong><br/>
  Earnings, expenses, shifts, integrations, and AI — all in one offline-first platform.
</p>

<p>
  <img src="https://img.shields.io/badge/Flutter-0064F5?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Supabase-34C759?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase"/>
  <img src="https://img.shields.io/badge/Riverpod-0A192F?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod"/>
  <img src="https://img.shields.io/badge/Onda_53-0064F5?style=flat-square" alt="Onda 53"/>
</p>

</div>

---

## The Story

You spend hours on the road. Money flows in from three different apps. Fuel comes out of your pocket. Maintenance due dates sneak up without warning. At the end of the day, the question is always the same: **was it worth it?**

Most drivers answer based on gut feeling — or using a spreadsheet that nobody actually maintains.

**DriveFlow was built to close this loop.** It is not just an expense tracker. It is the control panel of your operation: how much you earned, how much you actually took home, which app pays the best, which hours are most profitable, and what to focus on during your next shift.

> From the first logged ride to the monthly retrospective PDF — every mile becomes data. Every data point becomes a decision.

---

## Core Features

<table>
<tr>
<td width="33%" valign="top">

<h3 style="color:#0064F5">Real Net Income</h3>

<p>
Log earnings and expenses categorized by vehicle. Track gross and <strong>net profit</strong> — factoring in fuel, tolls, car washes, and everything else that eats into your margins.
</p>

<p>
<strong>Dashboard</strong> &middot; <strong>PDF/CSV Reports</strong> &middot; <strong>Receipt OCR</strong>
</p>

</td>
<td width="33%" valign="top">

<h3 style="color:#34C759">Intelligent Shifts</h3>

<p>
Start your shift with an adaptive plan based on local heatmaps and your personal history. Track compliance, live net income, iOS Live Activities, and get coaching insights.
</p>

<p>
<strong>Shift Mode</strong> &middot; <strong>7d/30d Analytics</strong> &middot; <strong>iOS Home Widgets</strong>
</p>

</td>
<td width="33%" valign="top">

<h3 style="color:#5AC8FA">Multi-App Sync &amp; AI</h3>

<p>
Connect Uber, 99, and InDrive. Sync trip histories, compare platform take rates, simulate platform mixes, and query an AI assistant with the context of your last 90 days.
</p>

<p>
<strong>Multi-App Cockpit</strong> &middot; <strong>Payout Sync</strong> &middot; <strong>Groq AI Assistant</strong>
</p>

</td>
</tr>
</table>

---

## Driver Workflow

```
   Log Metrics        Analyze Data         Run Shift            Decide & Adapt
   ───────────        ────────────         ─────────            ──────────────
   Earnings           Dashboard            Shift Mode           Adaptive Plans
   Expenses     →     Analytics     →      Live Activities →    AI Coaching Insights
   Fuel Log           Weekly Rollups       Real-time P&L        Retrospective PDFs
   Maintenance        App Comparisons      Quick Actions        App-specific Goals
```

Each stage feeds the next. The more you use it, the more precise the AI recommendations become — freeing you completely from external spreadsheets.

---

## Product Highlights

| Area | Feature Details |
|------|-----------------|
| <span style="color:#0064F5">**Financials**</span> | Earnings, expenses, fuel logs, recurring maintenance, goals, and multi-vehicle tracking with dedicated car scopes |
| <span style="color:#34C759">**Shifts**</span> | Active shift session with timers, pauses, plan compliance tracking, history logs, and PDF retrospectives |
| <span style="color:#5AC8FA">**Integrations**</span> | OAuth integrations for Uber, 99, and InDrive, ride synchronization, automatic rollups, and multi-app cockpit |
| <span style="color:#FF9500">**Intelligence**</span> | 7x24 heatmap visualization, mix simulator, AI predictions, on-device OCR, and context-aware chat assistant |
| <span style="color:#FF3B30">**Reliability**</span> | Offline-first syncing via Hive, sync queue, maintenance notifications, and `driveflow://` deep links |
| <span style="color:#B8D4FF">**UX/UI**</span> | Design System v2, premium Apple-style UI, liquid glass navigation, accessibility compliance, and taximeter mode |

---

## Technical Stack

<table>
<tr>
<td align="center" width="20%">

**Frontend**  
Flutter 3.11+  
Riverpod &middot; GoRouter  
Flutter Hooks &middot; FL Chart

</td>
<td align="center" width="20%">

**Backend**  
Supabase  
Postgres + RLS  
Edge Functions (Deno)

</td>
<td align="center" width="20%">

**Offline Database**  
Hive  
Background SyncWorker  
Exponential Retry

</td>
<td align="center" width="20%">

**AI Layer**  
Groq SDK (Edge)  
90-day Context Vector  
Server-side Rate Limiting

</td>
<td align="center" width="20%">

**Native Modules**  
iOS WidgetKit  
Live Activities  
Quick Actions (iOS/Android)

</td>
</tr>
</table>

---

## Getting Started

### 1. Install Dependencies

```bash
git clone https://github.com/solerpedroo/driveflow.git
cd driveflow
flutter pub get
```

### 2. Environment Configuration

```bash
cp env.example.json env.json
```

Edit `env.json` with your Supabase credentials:

```json
{
  "SUPABASE_URL": "http://127.0.0.1:54321",
  "SUPABASE_ANON_KEY": "your-anon-key"
}
```

> **Android Emulator Note:** Use `http://10.0.2.2:54321` as the local URL.

### 3. Local Supabase Setup (Optional)

```bash
supabase start
supabase db reset
```

Copy the generated `anon key` from your terminal into your `env.json` file.

### 4. Run the Project

```bash
flutter run --dart-define-from-file=env.json
```

### Deploying Edge Functions (Production)

```bash
supabase secrets set GROQ_API_KEY=your_groq_api_key
supabase functions deploy ai-chat
supabase functions deploy ai-forecast
```

---

## Architecture

This project follows **Clean Architecture** with a **Feature-first** directory structure. Each feature module contains separate `presentation`, `domain`, and `data` layers.

```
lib/
├── core/              # Global themes, router, constants, services, and utils
├── features/          # Feature modules (auth, dashboard, earnings, expenses,
│   └── <feature>/     # vehicle, shift, integrations, ai, reports...)
│       ├── presentation/
│       ├── domain/
│       └── data/
└── shared/            # Reusable widgets, deep link configurations, bootstrap logic
```

**Architectural Standards:**
- Explicit schema-to-entity mappers
- Full dependency injection for unit testing
- Supabase reactive streams cached locally in Hive
- Route guards and middleware in GoRouter

<details>
<summary><strong>Internal Feature Module Directory Structure</strong></summary>

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
│   ├── datasources/
│   ├── mappers/
│   ├── schema/
│   └── repositories/
```

</details>

---

## Developer Scripts

```bash
flutter analyze
flutter test
flutter test --coverage
dart run build_runner build --delete-conflicting-outputs
```

Coverage target: **&ge; 70%** coverage across `lib/features/*/domain` and `lib/features/*/data`.

---

## Project Documentation

| Document | Content Description |
|-----------|---------------------|
| [implementation-plan.md](implementation-plan.md) | Full 53-wave development roadmap, completion criteria, and functional mapping |
| [docs/SUPABASE_ER.md](docs/SUPABASE_ER.md) | Database schema entity-relationship model and relational constraints |
| [docs/RELEASE.md](docs/RELEASE.md) | Deployment checklists and release workflows |
| [docs/INTEGRACOES-PLATAFORMAS.md](docs/INTEGRACOES-PLATAFORMAS.md) | OAuth flow and data sync pipelines for Uber, 99, and InDrive |
| [docs/PRIVACY.md](docs/PRIVACY.md) | LGPD, consentimento IA e processamento Groq |

---

## Roadmap

DriveFlow is built incrementally in **waves** — ensuring a complete functional demo and unit tests are validated before starting the next wave.

| Phase | Waves | Scope |
|------|-------|--------|
| **MVP v1.0** | 0–9 | Auth, Core CRUD, Dashboard, PDF Reports, AI Chat, Offline Sync |
| **Post-MVP** | 10–14 | Multi-vehicle tracking, OCR receipt scanner, analytics, data imports |
| **Premium UI** | 15–23 | Design System v2, Glassmorphism, Haptics, visual polish |
| **Integrations** | 24–33 | Platform OAuth (Uber/99/InDrive), Sync telemetry, heatmaps |
| **Shifts Engine**| 45–53 | Shift tracking, widgets, Live Activities, AI coaching, real-time P&L |

For the wave-by-wave checklist breakdown, check [implementation-plan.md](implementation-plan.md).

---

## Environment Variables

```env
# Flutter (--dart-define-from-file)
SUPABASE_URL=
SUPABASE_ANON_KEY=
SENTRY_DSN=
SUPABASE_CERT_SHA256=

# Supabase Edge Functions (secrets)
GROQ_API_KEY=
GROQ_MODEL=llama-3.3-70b-versatile
PLATFORM_TOKEN_ENCRYPTION_KEY=   # 32 bytes base64 — criptografia de tokens OAuth
PLATFORM_OAUTH_APP_REDIRECT_URIS=io.supabase.driveflow://platform-oauth/
PLATFORM_WEBHOOK_SECRET=
PLATFORM_CRON_SECRET=

# Integrations (Wave 26+)
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
  <span style="color:#0064F5">DriveFlow</span> — transforming miles on the road into absolute financial clarity.
</p>

<p>
  <sub>Private Project &middot; All Rights Reserved</sub>
</p>

</div>
