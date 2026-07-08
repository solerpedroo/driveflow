# Diagrama ER — Supabase (DriveFlow)

Relacionamentos principais do MVP v1.0. Todas as tabelas têm RLS por `auth.uid() = user_id` (ou equivalente via veículo).

```mermaid
erDiagram
    profiles ||--o{ vehicles : owns
    profiles ||--o{ earnings : has
    profiles ||--o{ expenses : has
    profiles ||--o| goals : configures
    profiles ||--o{ ai_history : asks

    vehicles ||--o{ fuel_logs : tracks
    vehicles ||--o{ maintenance : schedules

    profiles {
        uuid id PK
        text name
        text avatar_url
        timestamptz created_at
    }

    vehicles {
        uuid id PK
        uuid user_id FK
        text brand
        text model
        int year
        text plate
        text fuel_type
        numeric odometer_km
    }

    earnings {
        uuid id PK
        uuid user_id FK
        text platform
        numeric amount
        int rides
        numeric worked_hours
        date date
    }

    expenses {
        uuid id PK
        uuid user_id FK
        text category
        numeric amount
        text description
        text receipt_url
        date date
    }

    fuel_logs {
        uuid id PK
        uuid user_id FK
        uuid vehicle_id FK
        text fuel_type
        numeric liters
        numeric total_amount
        numeric odometer_km
        numeric km_per_liter
        numeric cost_per_km
    }

    maintenance {
        uuid id PK
        uuid user_id FK
        uuid vehicle_id FK
        text type
        numeric cost
        date performed_at
        int next_km
        date next_date
    }

    goals {
        uuid id PK
        uuid user_id FK
        numeric daily
        numeric weekly
        numeric monthly
        numeric yearly
    }

    ai_history {
        uuid id PK
        uuid user_id FK
        text question
        text answer
        timestamptz created_at
    }
```

## Storage buckets

| Bucket    | Uso                          |
|-----------|------------------------------|
| `avatars` | Foto de perfil               |
| `receipts`| Comprovantes de despesas     |

## Edge Functions

| Função    | Descrição                    |
|-----------|------------------------------|
| `ai-chat` | Assistente Groq com contexto |

## Cache local (Hive — Onda 9)

Boxes espelham leitura offline: `earnings`, `expenses`, `fuel_logs`, `maintenance`, `goals`, `pending_sync_queue`.

Write-through com fila de sync para ganhos e despesas.
