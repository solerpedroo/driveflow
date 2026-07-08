import '../entities/ai_message_entity.dart';

abstract interface class AiRepository {
  Stream<List<AiMessageEntity>> watchHistory();

  Future<AiMessageEntity> ask(String question);
}
