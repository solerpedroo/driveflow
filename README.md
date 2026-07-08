# DriveFlow

Gestão financeira, operacional e estratégica para motoristas de aplicativo — com IA contextual integrada aos seus dados reais.

**Stack:** Flutter · Riverpod · GoRouter · Supabase · Hive · Groq

Consulte [implementation-plan.md](implementation-plan.md) para o roadmap completo em ondas.

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.11)
- [Supabase CLI](https://supabase.com/docs/guides/cli) (opcional, para backend local)
- Android Studio / Xcode para emuladores

---

## Setup rápido

### 1. Dependências Flutter

```bash
cd driveflow
flutter pub get
```

### 2. Variáveis de ambiente

Copie o exemplo e preencha com suas credenciais Supabase:

```bash
cp env.example.json env.json
```

Edite `env.json`:

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

Após `supabase start`, copie a `anon key` exibida no terminal para `env.json`.

### 4. Executar o app

```bash
flutter run --dart-define-from-file=env.json
```

---

## Arquitetura

```
lib/
├── core/           # theme, router, constants, utils, errors
├── features/       # Clean Architecture por feature
│   └── <feature>/
│       ├── presentation/
│       ├── domain/
│       └── data/
└── shared/         # widgets e providers cross-feature
```

**Padrões:** schema + mapper explícitos, injeção para testes, GoRouter, Riverpod.

---

## Scripts úteis

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

---

## Onda 0 — entregue

- [x] Projeto Flutter (`com.driveflow`)
- [x] Design system (tema claro/escuro, tipografia, glass cards)
- [x] GoRouter + tela foundation
- [x] Supabase migration 001 (RLS + storage)
- [x] Utils (BRL, datas, validators)
- [x] Testes unitários e widget

## Onda 1 — entregue

- [x] Login e-mail/senha + cadastro
- [x] Google OAuth (PKCE + deep link)
- [x] Auth guards no GoRouter (splash → login → home)
- [x] Sync automático de `profiles`
- [x] Backup de refresh token (`flutter_secure_storage`)
- [x] Testes: mapper, login screen, smoke app

## Onda 2 — entregue

- [x] Shell principal com 5 abas (Dashboard, Ganhos, Despesas, Relatórios, Perfil)
- [x] CRUD de veículo + onboarding obrigatório sem veículo
- [x] Perfil: editar nome, upload de avatar (`avatars` bucket)
- [x] Redirect GoRouter: auth → onboarding veículo → shell
- [x] Testes: `vehicle_mapper`, shell tab switching, validação odômetro

## Onda 3 — entregue

- [x] CRUD de ganhos (plataforma, valor, corridas, horas, data, observação)
- [x] CRUD de despesas com categorias e upload de comprovante (`receipts`)
- [x] Filtros por período (hoje/semana/mês) e plataforma nos ganhos
- [x] Listagem de despesas agrupada por categoria
- [x] Streams Supabase em tempo real + rotas de formulário
- [x] Testes: mappers, filtros, validação BRL, formulário de ganho

## Onda 4 — entregue

- [x] CRUD de abastecimentos (`fuel_logs`) com cálculo automático km/L e custo/km
- [x] Média rolling de consumo nos últimos abastecimentos
- [x] Sync automático com `expenses` categoria Combustível
- [x] Atualização do odômetro do veículo ao salvar
- [x] Histórico + formulário acessíveis via Perfil e card no Dashboard
- [x] Testes: fórmulas de métricas, mapper e linker de despesa

## Onda 5 — entregue

- [x] CRUD de manutenções por veículo (tipo, custo, data, próximo km/data)
- [x] `MaintenanceDueChecker` com status em dia / próximo / atrasado
- [x] Lembretes locais via `flutter_local_notifications` na data de vencimento
- [x] Badge de alerta no Dashboard quando há manutenção pendente
- [x] Acesso via Perfil e rotas `/maintenance/form` e `/maintenance/history`
- [x] Testes: lógica de vencimento e mapper

## Onda 6 — entregue

- [x] Metas diária, semanal, mensal e anual (upsert 1 row por usuário)
- [x] `GoalProgressCalculator` compara lucro real (ganhos − despesas) vs meta
- [x] Tela `/goals` com cards de progresso linear e formulário de configuração
- [x] Chip "Meta diária" no Dashboard com dados reais e atalho para metas
- [x] Testes: percentual, projeção "faltam R$ X" e meta não configurada

## Onda 7 — entregue

- [x] `ProfitCalculator` e `DashboardAggregator` consolidam ganhos, despesas e combustível
- [x] Dashboard com card "Hoje", gráfico semanal de lucro e resumo do mês
- [x] Aba Relatórios com filtros diário/semanal/mensal/anual e indicadores completos
- [x] Exportação PDF e CSV branded via `share_plus`
- [x] Testes: agregações, lucro/hora, lucro/km e widget do card "Hoje"

## Onda 8 — entregue

- [x] Edge Function `ai-chat` com Groq, contexto dos últimos 90 dias e rate limit
- [x] JWT validado na função; `GROQ_API_KEY` apenas no servidor
- [x] Chat UI com bolhas, sugestões rápidas e histórico via `ai_history`
- [x] `AiContextBuilder` para preview local do contexto
- [x] Acesso via Perfil → Assistente DriveFlow (`/ai/chat`)
- [x] Testes: montagem de contexto e formatação de prompt

### Configurar IA (Supabase)

```bash
supabase secrets set GROQ_API_KEY=sua_chave_groq
supabase functions deploy ai-chat
```

## Onda 9 — entregue

- [x] Hive offline-first: boxes `earnings`, `expenses`, `fuel_logs`, `maintenance`, `goals`, `pending_sync_queue`
- [x] Write-through + fila de sync com retry exponencial (`SyncWorker`)
- [x] CRUD offline para ganhos e despesas; leitura cache para combustível, manutenção e metas
- [x] Banner offline / sincronizando no shell principal
- [x] Analytics (`earning_added`, `ai_question`, `report_exported`) + crash reporting (`runZonedGuarded`)
- [x] Pull-to-refresh, empty states ilustrados e skeleton loaders nas listas
- [x] Documentação: [docs/SUPABASE_ER.md](docs/SUPABASE_ER.md), [docs/RELEASE.md](docs/RELEASE.md)
- [x] Testes: storage offline, mappers draft round-trip, shell com overrides de sync

### Coverage

```bash
flutter test --coverage
# Meta: ≥ 70% em lib/features/*/domain e lib/features/*/data
```

## Onda 10 — entregue

- [x] Migration 002: `nickname`, `is_default`, `vehicle_id` em ganhos/despesas
- [x] CRUD de N veículos com veículo padrão e exclusão segura
- [x] Seletor de veículo (chip + bottom sheet) no Dashboard e Relatórios
- [x] `scopedVehicleIdProvider` filtra ganhos/despesas por veículo
- [x] Cache Hive + fila offline para veículos (`SyncWorker`)
- [x] Lista de veículos no Perfil com adicionar/editar/excluir/tornar padrão
- [x] Testes: mapper, `VehicleDefaultResolver`, `VehicleScopeFilter`

---

## Licença

Projeto privado — todos os direitos reservados.
