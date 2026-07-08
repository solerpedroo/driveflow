# Checklist de release — DriveFlow MVP v1.0

## Pré-build

- [ ] `flutter analyze` sem issues
- [ ] `flutter test` passando
- [ ] Coverage domain/data ≥ 70% (`flutter test --coverage`)
- [ ] `env.json` preenchido (nunca commitar)
- [ ] Supabase produção: migrations aplicadas + RLS ativo
- [ ] Edge Function `ai-chat` deployada com `GROQ_API_KEY`

## Assets e branding

- [ ] Ícone do app (Android adaptive + iOS)
- [ ] Splash screen nativa
- [ ] Screenshots para lojas (5 abas + IA + offline banner)

## Android

- [ ] `minSdkVersion` ≥ 26 (Android 8+)
- [ ] Deep link OAuth: `io.supabase.driveflow://login-callback/`
- [ ] Permissões: câmera/galeria (comprovantes), notificações (manutenção)
- [ ] ProGuard/R8 rules se necessário
- [ ] Assinatura release (keystore seguro)

## iOS

- [ ] Deployment target iOS 15+
- [ ] URL scheme OAuth configurado
- [ ] Permissões Info.plist (câmera, fotos, notificações)
- [ ] Certificados + provisioning profile

## Observabilidade

- [ ] Crash reporting ativo (`DriveFlowCrashReporting` em `main.dart`)
- [ ] Eventos analytics: `earning_added`, `ai_question`, `report_exported`
- [ ] (Opcional) Integrar Firebase Analytics/Crashlytics via `DriveFlowAnalytics`

## Offline

- [ ] CRUD ganhos/despesas offline validado
- [ ] Banner offline/sincronizando visível no shell
- [ ] Reconexão drena fila `pending_sync_queue`

## Smoke test manual

- [ ] Login e-mail + Google
- [ ] Onboarding veículo
- [ ] Registrar ganho, despesa, abastecimento, manutenção
- [ ] Metas + dashboard + export PDF/CSV
- [ ] Chat IA (online)
- [ ] Modo avião: listar/editar ganhos → reconectar → sync

## Store listings (rascunho)

**Título:** DriveFlow — Lucro para motoristas  
**Descrição curta:** Controle ganhos, despesas, combustível e metas. IA integrada.  
**Palavras-chave:** motorista app, uber, ganhos, lucro, gestão financeira
