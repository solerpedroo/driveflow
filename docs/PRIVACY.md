# Privacidade e LGPD — DriveFlow

**Última atualização:** 20 de julho de 2026

## Dados coletados

| Categoria | Exemplos | Finalidade |
|-----------|----------|------------|
| Conta | e-mail, nome | Autenticação e perfil |
| Financeiros | ganhos, despesas, combustível | Dashboard, relatórios, metas |
| Operacionais | turnos, integrações OAuth | Sync de apps de corrida |
| IA (opt-in) | totais agregados dos últimos 90 dias | Assistente e previsões |

## Processamento por terceiros (IA)

O assistente de IA envia **apenas dados agregados** (totais, categorias, contagens) para a **Groq API**. Não enviamos:

- Descrições livres de despesas
- Endereços de corridas
- Tokens OAuth ou credenciais

**Consentimento:** o usuário deve aceitar explicitamente na primeira utilização do assistente (`profiles.ai_data_consent_at`). Sem consentimento, as edge functions `ai-chat` e `ai-forecast` retornam erro 403.

## Direitos do titular (LGPD)

- **Acesso:** exportação PDF/CSV na área de relatórios
- **Exclusão:** encerramento de conta remove dados via cascade no Supabase
- **Revogação IA:** entre em contato com suporte (consentimento não revogável in-app por integridade de auditoria; revogação manual via suporte)

## Retenção

- Dados financeiros: enquanto a conta estiver ativa
- Histórico de IA: conforme tabela `ai_history` (exclusão em cascade com usuário)
- Tokens OAuth: criptografados em repouso; removidos ao desconectar integração

## Segurança

- TLS obrigatório em produção (`SupabaseConfig.assertProductionSafe`)
- Pinning opcional de certificado via `SUPABASE_CERT_SHA256`
- Hive local criptografado com AES-256
- RLS em todas as tabelas de usuário

## Contato

Para solicitações LGPD: configure `PRIVACY_CONTACT_EMAIL` no README do projeto em produção.
