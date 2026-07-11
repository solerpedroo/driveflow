# Integrações com apps de corrida (Uber, 99, InDrive)

Guia passo a passo para configurar a coleta automática de ganhos e corridas no DriveFlow.

## O que isso faz

Quando configurado corretamente, o motorista:

1. Toca **Conectar** em Perfil → Apps conectados
2. Autoriza no navegador (OAuth)
3. Volta ao app automaticamente
4. O servidor busca corridas na API da plataforma
5. Os dados entram em `platform_trips` e `earnings` (sync automático)
6. Dashboard, lucro, metas e analytics passam a usar esses ganhos

**Sem os secrets configurados, esse fluxo não funciona.** O app continua normal com lançamento manual e importação de extrato.

---

## Pré-requisitos

- [Supabase CLI](https://supabase.com/docs/guides/cli) instalada e logada (`supabase login`)
- Projeto Supabase criado (local ou na nuvem)
- App Flutter com `env.json` preenchido (`SUPABASE_URL` + `SUPABASE_ANON_KEY`)
- Migrations aplicadas (`supabase db push` ou `supabase start` local)
- Para **Uber**: conta aprovada na [Uber Driver API](https://developer.uber.com/docs/drivers) (acesso limitado — é preciso solicitar)
- Para **99** e **InDrive**: credenciais de **parceiro** fornecidas pelas próprias plataformas (não há API pública de motorista individual)

---

## Visão geral da arquitetura

```
App Flutter
    │  Conectar → abre navegador OAuth
    ▼
Edge Function: platform-oauth-start
    │  Gera URL de autorização
    ▼
Plataforma (Uber / 99 / InDrive)
    │  Usuário autoriza
    ▼
Edge Function: platform-oauth-callback
    │  Troca code por tokens → salva em platform_connections
    ▼
Deep link: io.supabase.driveflow://platform-oauth/?status=connected
    │  App reabre e dispara sync automático
    ▼
Edge Function: platform-sync
    │  Busca corridas → grava ganhos diários
    ▼
Dashboard / Ganhos / Metas
```

**Redirect URI registrado na plataforma (servidor):**

```
https://SEU_PROJETO.supabase.co/functions/v1/platform-oauth-callback
```

Substitua `SEU_PROJETO` pela URL do seu projeto Supabase.

---

## Passo 1 — Configurar o app Flutter

```bash
cp env.example.json env.json
```

Edite `env.json`:

```json
{
  "SUPABASE_URL": "https://xxxxxxxx.supabase.co",
  "SUPABASE_ANON_KEY": "sua-anon-key"
}
```

| Ambiente | `SUPABASE_URL` |
|----------|----------------|
| Supabase local | `http://127.0.0.1:54321` |
| Android emulador (local) | `http://10.0.2.2:54321` |
| Produção | `https://xxxxxxxx.supabase.co` |

Rode o app:

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

---

## Passo 2 — Linkar o projeto Supabase

Na raiz do repositório:

```bash
supabase link --project-ref SEU_PROJECT_REF
```

O `project-ref` aparece na URL do dashboard: `https://supabase.com/dashboard/project/SEU_PROJECT_REF`.

Para desenvolvimento **100% local**:

```bash
supabase start
```

---

## Passo 3 — Deploy das Edge Functions

```bash
supabase functions deploy platform-oauth-start
supabase functions deploy platform-oauth-callback
supabase functions deploy platform-sync
```

Opcionais (sync em background):

```bash
supabase functions deploy platform-sync-cron
supabase functions deploy platform-webhook
```

Em local, para testar sem deploy:

```bash
supabase functions serve
```

---

## Passo 4 — Configurar secrets no Supabase

Os secrets ficam **no servidor Supabase**, não no `env.json` do Flutter.

### Uber (obrigatório para conectar Uber)

```bash
supabase secrets set UBER_CLIENT_ID=seu_client_id_aqui
supabase secrets set UBER_CLIENT_SECRET=seu_client_secret_aqui
```

### 99 (somente com parceria + URLs fornecidas pela 99)

```bash
supabase secrets set NINETY_NINE_CLIENT_ID=...
supabase secrets set NINETY_NINE_CLIENT_SECRET=...
supabase secrets set NINETY_NINE_AUTHORIZE_URL=https://...
supabase secrets set NINETY_NINE_TOKEN_URL=https://...
supabase secrets set NINETY_NINE_TRIPS_URL=https://.../trips
```

Opcionais:

```bash
supabase secrets set NINETY_NINE_SCOPES="trips earnings"
supabase secrets set NINETY_NINE_API_BASE_URL=https://...
```

### InDrive (somente com parceria + URLs fornecidas pelo InDrive)

```bash
supabase secrets set INDRIVE_CLIENT_ID=...
supabase secrets set INDRIVE_CLIENT_SECRET=...
supabase secrets set INDRIVE_AUTHORIZE_URL=https://...
supabase secrets set INDRIVE_TOKEN_URL=https://...
supabase secrets set INDRIVE_TRIPS_URL=https://.../trips
```

Opcionais:

```bash
supabase secrets set INDRIVE_SCOPES="trips"
supabase secrets set INDRIVE_API_BASE_URL=https://...
```

### Secrets opcionais (cron, webhook, CORS)

```bash
supabase secrets set PLATFORM_CRON_SECRET=um_segredo_longo_aleatorio
supabase secrets set PLATFORM_WEBHOOK_SECRET=outro_segredo_longo
supabase secrets set ALLOWED_ORIGIN=https://seu-dominio.com
```

> `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY` já existem automaticamente no ambiente das Edge Functions.

### Listar secrets configurados

```bash
supabase secrets list
```

---

## Passo 5 — Configurar Uber Developer Dashboard

1. Acesse [developer.uber.com](https://developer.uber.com/) e crie um app
2. Solicite acesso à **Driver API** (aba Drivers / Partners)
3. Em **Auth**, adicione o redirect URI:

   ```
   https://SEU_PROJETO.supabase.co/functions/v1/platform-oauth-callback
   ```

4. Habilite os scopes:
   - `partner.accounts`
   - `partner.trips`
   - `partner.payments`

5. Copie **Client ID** e **Client Secret** para os secrets do Passo 4

Documentação oficial:
- [Autenticação](https://developer.uber.com/docs/drivers/guides/authentication)
- [GET /partners/trips](https://developer.uber.com/docs/drivers/references/api/v1/partners-trips-get)

---

## Passo 6 — Deep links (já configurados no projeto)

O app espera retornar via:

```
io.supabase.driveflow://platform-oauth/?status=connected&platform=uber
```

Isso já está no `AndroidManifest.xml` e no `Info.plist` (iOS). No Supabase Auth (`config.toml` local), o redirect também está em `additional_redirect_urls`.

Se usar projeto na nuvem, confira em **Authentication → URL Configuration** se `io.supabase.driveflow://platform-oauth/` está na lista de redirect URLs permitidas.

---

## Passo 7 — Testar o fluxo

1. Abra o app logado como motorista
2. Vá em **Perfil → Apps conectados** (ou `/integrations/platforms`)
3. Toque **Conectar** na Uber
4. Autorize no navegador com uma **conta de motorista Uber**
5. O app deve reabrir sozinho
6. Aguarde a mensagem de sync (corridas e ganhos importados)
7. Confira:
   - Aba **Ganhos** — registros com `source: api_sync`
   - **Dashboard** — lucro do mês atualizado
   - **Histórico de corridas** (`/integrations/trips`)

### Sync manual

Na tela de Apps conectados, use **Sincronizar** em cada plataforma ou **Sincronizar tudo**.

---

## Tabela resumo de secrets

| Secret | Obrigatório | Plataforma |
|--------|-------------|------------|
| `UBER_CLIENT_ID` | Sim (Uber) | Uber |
| `UBER_CLIENT_SECRET` | Sim (Uber) | Uber |
| `NINETY_NINE_CLIENT_ID` | Sim (99) | 99 |
| `NINETY_NINE_CLIENT_SECRET` | Sim (99) | 99 |
| `NINETY_NINE_AUTHORIZE_URL` | Sim (99) | 99 |
| `NINETY_NINE_TOKEN_URL` | Sim (99) | 99 |
| `NINETY_NINE_TRIPS_URL` | Sim (99) | 99 |
| `NINETY_NINE_SCOPES` | Não | 99 |
| `NINETY_NINE_API_BASE_URL` | Não | 99 |
| `INDRIVE_CLIENT_ID` | Sim (InDrive) | InDrive |
| `INDRIVE_CLIENT_SECRET` | Sim (InDrive) | InDrive |
| `INDRIVE_AUTHORIZE_URL` | Sim (InDrive) | InDrive |
| `INDRIVE_TOKEN_URL` | Sim (InDrive) | InDrive |
| `INDRIVE_TRIPS_URL` | Sim (InDrive) | InDrive |
| `INDRIVE_SCOPES` | Não | InDrive |
| `INDRIVE_API_BASE_URL` | Não | InDrive |
| `PLATFORM_CRON_SECRET` | Não | Cron |
| `PLATFORM_WEBHOOK_SECRET` | Não | Webhook |
| `ALLOWED_ORIGIN` | Não | CORS |

---

## Desenvolvimento local (resumo rápido)

```bash
# 1. Subir Supabase
supabase start

# 2. Aplicar migrations
supabase db reset   # ou db push

# 3. Secrets locais (arquivo .env na pasta supabase, se preferir)
supabase secrets set UBER_CLIENT_ID=...
supabase secrets set UBER_CLIENT_SECRET=...

# 4. Servir functions
supabase functions serve

# 5. App apontando para local
# env.json → SUPABASE_URL: http://10.0.2.2:54321 (Android emulador)
flutter run --dart-define-from-file=env.json
```

> OAuth com Uber em local exige que o redirect `http://127.0.0.1:54321/functions/v1/platform-oauth-callback` também esteja cadastrado no painel da Uber, ou testar direto em staging/produção.

---

## Solução de problemas

| Sintoma | Causa provável | O que fazer |
|---------|----------------|-------------|
| "Configure UBER_CLIENT_ID e UBER_CLIENT_SECRET" | Secrets ausentes | Passo 4 |
| Navegador abre mas dá erro na Uber | Redirect URI não cadastrado ou app não aprovado | Passo 5 |
| Autorizou mas app não reabre | Deep link não disparou | Reabra o app manualmente; confira AndroidManifest / URL no Supabase Auth |
| "Token expirado. Reconecte o app." | Refresh token inválido | Desconectar e conectar de novo |
| Sync retorna 0 corridas | Conta não é de motorista ou sem corridas no período | Use conta driver com corridas recentes |
| 99 / InDrive: "não configurada" | Sem parceria ou URLs OAuth vazias | Obter credenciais com a plataforma ou usar extrato/manual |
| Erro 401 na sync | Token revogado | Reconectar a plataforma |

### Ver logs das Edge Functions

```bash
supabase functions logs platform-oauth-callback
supabase functions logs platform-sync
```

### Conferir conexão no banco

No SQL Editor do Supabase:

```sql
select platform, status, last_synced_at, last_sync_error
from platform_connections
where user_id = 'UUID_DO_USUARIO';
```

---

## Alternativas sem API

Enquanto 99/InDrive não tiverem parceria, o motorista pode:

- **Lançar ganhos manualmente** (aba Ganhos → Novo ganho)
- **Importar extrato** (Nubank, Inter, OFX) em Perfil → Importar extrato

Esses fluxos alimentam o mesmo cálculo de lucro do dashboard.

---

## Referências no código

| Peça | Caminho |
|------|---------|
| Config OAuth por plataforma | `supabase/functions/_shared/platform_config.ts` |
| Troca e refresh de token | `supabase/functions/_shared/platform_oauth.ts` |
| Adapters de corridas | `supabase/functions/platform-sync/adapters.ts` |
| Sync + rollup de ganhos | `supabase/functions/platform-sync/index.ts` |
| Deep link no Flutter | `lib/core/services/platform_oauth_deep_link_listener.dart` |
| Tela de conexão | `lib/features/integrations/presentation/screens/platform_integrations_screen.dart` |
