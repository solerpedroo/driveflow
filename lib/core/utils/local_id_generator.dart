import 'dart:math';

/// Gera IDs temporários para entidades criadas offline.
abstract final class LocalIdGenerator {
  static String create() {
    final random = Random();
    return 'local_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(999999)}';
  }

  static bool isLocal(String id) => id.startsWith('local_');
}
