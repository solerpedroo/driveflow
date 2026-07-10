import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/integrations/domain/services/sync_conflict_resolver.dart';

void main() {
  group('SyncConflictResolver', () {
    test('preserva ganhos manuais', () {
      expect(SyncConflictResolver.shouldPreserveManual(source: 'manual'), isTrue);
      expect(SyncConflictResolver.shouldPreserveManual(source: null), isTrue);
    });

    test('permite overwrite de api_sync', () {
      expect(SyncConflictResolver.allowApiOverwrite(source: 'api_sync'), isTrue);
      expect(SyncConflictResolver.allowApiOverwrite(source: 'manual'), isFalse);
    });

    test('prioridade manual > api_sync > import', () {
      expect(
        SyncConflictResolver.sourcePriority('manual'),
        greaterThan(SyncConflictResolver.sourcePriority('api_sync')),
      );
    });
  });
}
