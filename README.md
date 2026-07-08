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

---

## Licença

Projeto privado — todos os direitos reservados.
