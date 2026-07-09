import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_forecast_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../mappers/ai_mapper.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl({
    AiRemoteDataSource? remote,
    SupabaseClient? client,
  })  : _remote = remote ?? AiRemoteDataSource(client: client),
        _client = client ?? Supabase.instance.client;

  final AiRemoteDataSource _remote;
  final SupabaseClient _client;

  @override
  Stream<List<AiMessageEntity>> watchHistory() {
    return _remote.watchHistoryRows().map(
          (rows) => rows.map(AiMapper.fromRow).toList(growable: false),
        );
  }

  @override
  Future<AiMessageEntity> ask(String question) async {
    final response = await _remote.invokeAiChat(question: question);
    final userId = _client.auth.currentUser?.id ?? '';

    return AiMessageEntity(
      id: response['id'] as String,
      userId: userId,
      question: response['question'] as String? ?? question,
      answer: response['answer'] as String,
      createdAt: DateTime.tryParse(response['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  Future<AiForecastMessage> forecast() async {
    final response = await _remote.invokeAiForecast();

    return AiForecastMessage(
      id: response['id'] as String,
      summary: response['summary'] as String? ?? '',
      forecast7Days: (response['forecast7Days'] as num?)?.toDouble() ?? 0,
      forecast30Days: (response['forecast30Days'] as num?)?.toDouble() ?? 0,
      optimistic30Days:
          (response['optimistic30Days'] as num?)?.toDouble() ?? 0,
      pessimistic30Days:
          (response['pessimistic30Days'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(response['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
