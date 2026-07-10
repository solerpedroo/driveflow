abstract final class PlatformConnectionsSchema {
  static const table = 'platform_connections';

  static const id = 'id';
  static const userId = 'user_id';
  static const platform = 'platform';
  static const status = 'status';
  static const externalAccountId = 'external_account_id';
  static const lastSyncedAt = 'last_synced_at';
  static const lastSyncError = 'last_sync_error';
  static const syncCursor = 'sync_cursor';
  static const metadata = 'metadata';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
