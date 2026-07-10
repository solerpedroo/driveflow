import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Oculta valores monetários nas telas (padrão Mescla — ícone de olho).
final valueVisibilityHiddenProvider = StateProvider<bool>((ref) => false);

String maskCurrency(String formatted, {required bool hidden}) {
  if (!hidden) return formatted;
  return 'R\$ ••••••';
}

String maskPlain(String value, {required bool hidden}) {
  if (!hidden) return value;
  return '•••';
}
