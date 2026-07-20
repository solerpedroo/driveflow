import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/remote_data_source_errors.dart';
import '../schema/ai_history_schema.dart';

class AiRemoteDataSource {
  AiRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchHistoryRows() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(AiHistorySchema.table)
        .stream(primaryKey: [AiHistorySchema.id])
        .eq(AiHistorySchema.userId, userId)
        .order(AiHistorySchema.createdAt, ascending: false);
  }

  Future<Map<String, dynamic>> invokeAiChat({required String question}) async {
    try {
      final response = await _client.functions.invoke(
        AiFunctions.aiChat,
        body: {'question': question},
      );

      if (response.status != 200) {
        throw const ServerFailure(
          message: 'Assistente indisponível no momento.',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure(message: 'Resposta inválida do assistente');
      }
      return data;
    } on FunctionException catch (e) {
      RemoteDataSourceErrors.rethrowFunction(e);
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }

  Future<Map<String, dynamic>> invokeAiForecast() async {
    try {
      final response = await _client.functions.invoke(
        AiFunctions.aiForecast,
        body: const {},
      );

      if (response.status != 200) {
        throw const ServerFailure(
          message: 'Previsão indisponível no momento.',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure(message: 'Resposta inválida da previsão');
      }
      return data;
    } on FunctionException catch (e) {
      RemoteDataSourceErrors.rethrowFunction(e);
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }
}
