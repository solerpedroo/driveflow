# DriveFlow — Auditoria de Engenharia Sênior

**Data:** 12 de julho de 2026  
**Escopo:** Revisão completa pós-refatoração do design system (Ondas 15–37)  
**Objetivo:** Registrar falhas, gaps e bugs para revisão da equipe e priorização de correções.

---

## Veredito executivo

O DriveFlow apresenta **engenharia de produto madura** (design system, Clean Architecture, domínio rico) com **engenharia de confiabilidade imatura** (sem CI/CD, sync parcialmente testado, bugs de escopo de dados).

| Classe | Impacto | Status |
|--------|---------|--------|
| **P0 — Crítico** | Dados incorretos, perda de sessão, offline quebrado | Concluído (PR #29) |
| **P1 — Alto** | UX degradada, vazamento de recursos, erros crus na UI | Concluído (PR #30) |
| **P2 — Médio** | Consistência, polish, débito técnico | Em correção (branch `cursor/p2-design-polish-9e66`) |
| **P3 — Baixo** | Melhorias cosméticas | Pendente |

---

## P0 — Crítico

### P0-1 · Redirect do GoRouter derruba o shell em refresh de dados

**Arquivos:** `lib/core/router/app_router.dart:120-125`

**Problema:** O gate trata `isLoading` como ausência de dados. Quando `userProfileProvider` ou `vehiclesStreamProvider` são invalidados (salvar nome, avatar, veículo), entram em `AsyncLoading` **com valor anterior**. O redirect envia o usuário para `/splash`, destrói o shell e reseta a aba para Dashboard.

**Reprodução:**
1. Login → aba Perfil
2. Editar nome → salvar
3. Flash no splash → volta no Dashboard (perde aba e subpáginas)

**Correção:** Gate apenas na **primeira carga** (`!hasValue && isLoading`), não em refresh (`hasValue && isLoading`).

---

### P0-2 · Splash infinito em erro de rede (cold start offline)

**Arquivos:** `lib/core/router/app_router.dart`, `lib/features/profile/presentation/providers/profile_providers.dart`

**Problema:** Se `profileAsync` ou `vehiclesAsync` entram em `AsyncError` sem valor, `!hasValue` mantém redirect eterno para splash. `fetchProfile` não tem try/catch — exceção de rede → `AsyncError` → usuário preso.

**Correção:** try/catch em `userProfileProvider` com fallback para `authUser`; gate do router não bloqueia em `hasError`.

---

### P0-3 · Ganhos manuais sem `vehicleId`

**Arquivo:** `lib/features/earnings/presentation/screens/earning_form_screen.dart:68-75`

**Problema:** `EarningDraft` criado sem `vehicleId`. Despesas já usam `scopedVehicleIdProvider`. Com filtro por veículo, **todos os ganhos somem** e lucro fica negativo.

**Impacto:** Dashboard, relatórios, analytics, IA — tudo que usa `VehicleScopeFilter`.

**Correção:** Resolver `vehicleId` como em `expense_form_screen.dart`.

---

### P0-4 · Custos de manutenção não entram no lucro

**Arquivo:** `lib/features/maintenance/data/repositories/maintenance_repository_impl.dart`

**Problema:** Abastecimento cria despesa via `FuelExpenseLinker`; manutenção não cria despesa. Todo `cost` é invisível para `ProfitCalculator`, metas e relatórios.

**Correção:** `MaintenanceExpenseLinker` + `_syncExpense` no create/update/delete.

---

### P0-5 · Despesa de combustível sem `vehicleId`

**Arquivo:** `lib/features/fuel/data/repositories/fuel_repository_impl.dart:171-177`

**Problema:** Despesa derivada de abastecimento criada sem `vehicleId`. Com escopo por veículo, despesas de combustível somem.

**Correção:** Passar `vehicleId: entity.vehicleId` no `ExpenseDraft`.

---

### P0-6 · Offline-first incompleto + fila descarta ops silenciosamente

**Arquivos:**
- `lib/core/services/sync_worker.dart:126-128` — `default` faz `dequeue` sem processar
- `lib/features/vehicle/data/repositories/vehicle_repository_impl.dart:272-284` — edição offline de ID local não atualiza fila
- `lib/features/vehicle/data/repositories/vehicle_repository_impl.dart:297-313` — delete offline de ID local não remove create pendente

**Problema:** fuel/goals/maintenance sem fila offline (P1 estendido). Vehicle offline perde edições e cria fantasmas.

**Correção P0:** SyncWorker lança erro em entidade desconhecida (não descarta); vehicle offline espelha padrão de earnings.

---

### P0-7 · Migrações Supabase com versões duplicadas

**Arquivos:**
```
003_ai_history_type.sql + 003_platform_integrations.sql
004_platform_trips.sql + 004_realtime_publication.sql
005_platform_oauth_sync_logs.sql + 005_vehicle_ownership_rls.sql
```

**Problema:** Ordem implícita por nome alfabético — frágil para `db reset` e colaboração.

**Correção:** Renumeração monotônica 001–011 + nova 012.

---

### P0-8 · Tokens OAuth em tabela legível pelo client

**Arquivos:** `supabase/migrations/003_platform_integrations.sql`, `platform-oauth-callback/index.ts`

**Problema:** `platform_connections.metadata` contém `oauth` com tokens; RLS permite `select` pelo usuário. Mapper do client remove `oauth` na leitura, mas client malicioso pode ler raw.

**Correção:** Tabela `platform_connection_secrets` sem policy de select para `authenticated`; edge functions leem/escrevem secrets; migração de dados existentes.

---

## P1 — Alto

### Navegação e UX

| ID | Achado | Arquivo |
|----|--------|---------|
| N1 | Brand intro repete a cada retorno ao splash | `splash_screen.dart:22-23` |
| N2 | Login → splash flash antes do home | `auth_providers.dart` + router |
| N3 | Back do Android sai do app de qualquer aba | `main_shell_screen.dart:72` |
| N4 | Touch target nav = 40px (< 44pt) | `df_bottom_nav_bar.dart:135-138` |

### Design system

| ID | Achado |
|----|--------|
| D1 | Liquid glass com 4 sigmas (12/20/24/28) — bypass de `DfGlassSurface` |
| D2 | `DfSubpageScaffold` vs `DfFormScaffold` — AppBar inconsistente |
| D3 | Máscaras de privacidade com bullet counts diferentes |
| D4 | `foundation_screen.dart` órfão com ALL-CAPS |

### Arquitetura

| ID | Achado |
|----|--------|
| A1 | Zero `autoDispose` — streams realtime vazam |
| A2 | `error.toString()` em 11 telas |
| A3 | Datasources só capturam `PostgrestException` |
| A4 | `ConnectivityService` falso positivo em captive portal |
| A5 | `FuelRepositoryImpl` depende de implementação concreta |

### Lógica de negócio

| ID | Achado |
|----|--------|
| B1 | Metas sem escopo de veículo (dashboard sim) |
| B2 | Sign-up com confirmação de e-mail = erro |
| B3 | Odometer regride ao editar log antigo |
| B4 | API sync sem `vehicle_id` nos rollups | `platform-sync/index.ts` |

### Testes e CI

| ID | Achado |
|----|--------|
| T1 | Zero CI/CD |
| T2 | `SyncWorker` sem testes |
| T3 | Golden test sem `matchesGoldenFile` |
| T4 | `main_shell_test` — 3/5 abas |
| T5 | Feature `reports` zero testes |
| T6 | `cached_remote_watch_test` flaky |

---

## P2 — Médio

- ~55 arquivos com spacing literal vs `AppSpacing`
- `AppRadius.pill` inexistente (`circular(100)` vs `999`) — **corrigido** (`AppRadius.pill` + chips/hero)
- `app_theme.dart` radius 14 vs `DfButton` 16 — **corrigido** (16 via `AppRadius.xl`)
- `go_router_refresh_stream.dart` morto — removido na Onda 39
- CSV export sem escape — **corrigido** (`csv_escape.dart`)
- `platform_trips` insert sem validar ownership de `vehicle_id` — **corrigido** (migração 013)
- Sem `integration_test/`
- Provider overrides duplicados nos testes

---

## P3 — Baixo

- `GoogleFonts.geist` direto em login/brand intro
- Charts com `TextStyle` raw
- Dialogs Material puros (sem `DfConfirmDialog`) — **corrigido** (4 exclusões)
- `titleLarge` == `headlineLarge` (17px)
- `intl: ^0.20.2` pode conflitar em bump de SDK

---

## O que está bem feito

- Design system com tokens completos, zero `Colors.*` em features
- Clean Architecture consistente por feature
- RLS baseline sólido com hardening de ownership
- Offline earnings/expenses/vehicles com fila + retry exponencial
- Integrações não-stub (Uber/99/InDrive, shift advisor, take rate)
- Auth multi-step + Google OAuth + guards de onboarding
- 52 arquivos de teste de domínio (mappers, calculators, parsers)
- Bottom nav liquid glass (Onda 37) com transições na primeira visita

---

## Plano de correção

### Sprint 1 — P0 (concluído)
- [x] Documentar auditoria (`docs/engineering-audit.md`)
- [x] Router gate + profile try/catch + splash intro seed
- [x] vehicleId em ganhos + platform-sync
- [x] Manutenção → despesa
- [x] vehicleId em despesa de combustível
- [x] SyncWorker + vehicle offline
- [x] Renumerar migrações + 012 secrets
- [x] Secrets table para OAuth

### Sprint 2 — P1 (concluído)
- [x] CI/CD GitHub Actions
- [x] FailureMessage + 11 telas
- [x] autoDispose em stream providers
- [x] Nav touch 44px + main_shell 5 abas + PopScope back
- [x] Goals vehicle scope + email confirmation signup
- [x] SyncWorker test + cached_remote_watch fake_async
- [x] Máscaras unificadas + remoção código morto

### Sprint 3 — Design system polish (concluído)
- [x] `AppBlur` + glass unificado via `DfGlassSurface`
- [x] `DfScaffoldAppBar` — form/subpage alinhados
- [x] `AppRadius.pill` + theme radius 16
- [x] CSV escape + `csv_escape_test`
- [x] RLS `platform_trips` vehicle ownership
- [x] Hero toggle touch 44px
- [x] `DfConfirmDialog` nas exclusões

### Sprint 4 — Cobertura
- main_shell 5 abas, reports tests, integration_test

---

## Matriz de cobertura de testes

| Feature | Lógica | Widget | Gap crítico |
|---------|--------|--------|-------------|
| auth | parcial | login/register | splash, auth_gate |
| dashboard | sim | 3/5 tabs | despesas, relatórios |
| earnings | sim | form | vehicleId (bug) |
| expenses | sim | — | form screen |
| fuel | sim | — | offline, screens |
| maintenance | sim | — | expense linker |
| goals | sim | — | vehicle scope |
| reports | nenhum | nenhum | aba inteira |
| integrations | parcial | — | OAuth E2E |
| sync | queue/cache | — | SyncWorker |

---

## Referências de arquivos-chave

| Área | Caminhos |
|------|----------|
| Router | `lib/core/router/app_router.dart`, `transitions.dart` |
| Shell | `lib/shared/widgets/driveflow_main_shell.dart`, `main_shell_screen.dart` |
| Design system | `lib/shared/widgets/design_system/` |
| Tokens | `lib/core/theme/` |
| Sync | `lib/core/services/sync_worker.dart`, `pending_sync_queue.dart` |
| Migrações | `supabase/migrations/` |
| Edge functions | `supabase/functions/platform-sync/`, `platform-oauth-callback/` |
| Plano | `implementation-plan.md` |

---

*Última atualização: Onda 40 — branch `cursor/p2-design-polish-9e66`*
