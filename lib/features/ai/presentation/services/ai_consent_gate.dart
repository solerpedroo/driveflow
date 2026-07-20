import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_providers.dart';
import '../widgets/ai_data_consent_dialog.dart';

/// Garante consentimento LGPD antes de chamadas de IA.
Future<bool> ensureAiDataConsent(BuildContext context, WidgetRef ref) async {
  final profile = ref.read(userProfileProvider).valueOrNull;
  if (profile?.hasAiDataConsent == true) return true;

  final accepted = await showAiDataConsentDialog(context);
  if (!context.mounted || !accepted) return false;

  final updated =
      await ref.read(profileControllerProvider.notifier).grantAiDataConsent();
  return updated != null;
}
