import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
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
        final data = response.data;
        if (data is Map && data['error'] != null) {
          throw ServerFailure(message: data['error'].toString());
        }
        throw ServerFailure(
          message: 'Assistente indisponível no momento.',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure(message: 'Resposta inválida do assistente');
      }
      return data;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] != null) {
        throw ServerFailure(message: details['error'].toString(), cause: e);
      }
      throw ServerFailure(message: e.reasonPhrase ?? e.toString(), cause: e);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> invokeAiForecast() async {
    try {
      final response = await _client.functions.invoke(
        AiFunctions.aiForecast,
        body: const {},
      );

      if (response.status != 200) {
        final data = response.data;
        if (data is Map && data['error'] != null) {
          throw ServerFailure(message: data['error'].toString());
        }
        throw ServerFailure(
          message: 'Previsão indisponível (${response.status})',
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure(message: 'Resposta inválida da previsão');
      }
      return data;
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] != null) {
        throw ServerFailure(message: details['error'].toString(), cause: e);
      }
      throw ServerFailure(message: e.reasonPhrase ?? e.toString(), cause: e);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }
}
