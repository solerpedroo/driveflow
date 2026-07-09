import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource leve para operações de importação (sessão remota).
class ImportRemoteDataSource {
  ImportRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  bool get isAuthenticated => currentUserId != null;
}
