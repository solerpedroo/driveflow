import 'package:flutter/material.dart';

/// Dialog de consentimento LGPD para uso do assistente de IA (Groq).
Future<bool> showAiDataConsentDialog(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Assistente de IA'),
        content: const SingleChildScrollView(
          child: Text(
            'Para responder suas perguntas, o DriveFlow envia totais '
            'agregados dos últimos 90 dias (ganhos, despesas por categoria, '
            'metas) para processamento via Groq API.\n\n'
            'Não enviamos descrições de despesas, endereços ou credenciais.\n\n'
            'Consulte docs/PRIVACY.md para detalhes sobre LGPD.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Concordo'),
          ),
        ],
      );
    },
  );
  return accepted ?? false;
}
